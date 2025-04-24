% Temperature Data Logging Script

% Clear workspace and close figures
clear ;
close all;
clc;

% Initialize 
try
    a = arduino("COM5","Uno");
    disp('Arduino connected successfully');
catch
    error('Could not connect to Arduino. Please check connection.');
end

% Sensor parameters 
Tc = 0.01; % Temperature coefficient 
V_ref = 0.5; % Voltage at 0°C 
analogPin = 'A0'; % Analog pin connected to sensor

% Task parameters
acquisitionTime = 600; % 10 minutes
sampleInterval = 1; % 1 second between samples
numSamples = acquisitionTime / sampleInterval;

% Initialize data arrays
timeData = zeros(numSamples, 1);
voltageData = zeros(numSamples, 1);
tempData = zeros(numSamples, 1);

% Data acquisition loop
disp('Starting data acquisition...');
for i = 1:numSamples
    % Read voltage from sensor
    voltageData(i) = readVoltage(a, analogPin);
    
    % Convert voltage to temperature
    tempData(i) = (voltageData(i) - V_ref) / Tc;
    
    % Record time
    timeData(i) = (i-1) * sampleInterval;
    
    % Wait for next sample
    pause(sampleInterval);
end
disp('Data acquisition complete.');

% Calculate statistics
minTemp = min(tempData);
maxTemp = max(tempData);
avgTemp = mean(tempData);

% Create time/temperature plot
figure;
plot(timeData/60, tempData, 'b-', 'LineWidth', 1.5);
xlabel('Time (minutes)');
ylabel('Temperature (°C)');
title('Temperature vs Time');
grid on;

% Display data in console
disp(' ');
disp(['Data logging initiated -', datestr(now, 'dd/mm/yyyy')]);
disp('Location - Nottingham');
disp(' ');

% Print temperature data every minute
for minute = 0:10
    idx = minute * 60 + 1; % +1 because MATLAB is 1-indexed
    if idx > numSamples
        break;
    end
    disp(['Minute', num2str(minute)]);
    disp(['Temperature', sprintf('%.2f', tempData(idx)), 'C']);
    disp(' ');
end

% Print statistics
disp(['Max temp', sprintf('%.2f', maxTemp), 'C']);
disp(['Min temp', sprintf('%.2f', minTemp), 'C']);
disp(['Average temp', sprintf('%.2f', avgTemp), 'C']);
disp(' ');
disp('Data logging terminated');

% Write data to log file
logFileName = 'cabin_temperature.txt';
fileID = fopen(logFileName, 'w');

if fileID == -1
    error('Could not open log file for writing.');
end

% Write header
fprintf(fileID, 'Data logging initiated - %s\n', datestr(now, 'dd/mm/yyyy'));
fprintf(fileID, 'Location - Nottingham\n\n');

% Write temperature data
for minute = 0:10
    idx = minute * 60 + 1;
    if idx > numSamples
        break;
    end
    fprintf(fileID, 'Minute %d\n', minute);
    fprintf(fileID, 'Temperature %.2f C\n\n', tempData(idx));
end

% Write statistics
fprintf(fileID, 'Max temp %.2f C\n', maxTemp);
fprintf(fileID, 'Min temp %.2f C\n', minTemp);
fprintf(fileID, 'Average temp %.2f C\n\n', avgTemp);
fprintf(fileID, 'Data logging terminated\n');

% Close file
fclose(fileID);

% Clean up
clear a;