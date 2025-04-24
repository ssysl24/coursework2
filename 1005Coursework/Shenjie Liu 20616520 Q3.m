% temp_prediction.m to predict future values
%
% Usage:
%   temp_prediction(a) -'a' is the Arduino connection object
%   - Green LED: Temperature stable in comfort range (18-24°C)
%   - Red LED: Temperature increasing >4°C/min
%   - Yellow LED: Temperature decreasing >4°C/min

function temp_prediction(a)
    % Initialize variables
    timeInterval = 1; % seconds between readings
    predictionWindow = 300; % 5 minutes in seconds
    maxDuration = 600; % maximum monitoring duration (10 minutes)
    startTime = datetime('now');
    
    % LED pin assignments
    redPin = 'D9';
    yellowPin = 'D10';
    greenPin = 'D11';
    
    % Configure pins as digital outputs
    configurePin(a, redPin, 'DigitalOutput');
    configurePin(a, yellowPin, 'DigitalOutput');
    configurePin(a, greenPin, 'DigitalOutput');
    
    % Initialize data storage
    timeData = [];
    tempData = [];
    prevTemp = NaN;
    
    % Main monitoring loop
    while seconds(datetime('now')-seconds(startTime)) < maxDuration
        % Read current temperature
        voltage = readVoltage(a, 'A0');
        currentTemp = (voltage - 0.5) * 100; % Conversion for MCP9700A
        currentTime = seconds(datetime('now')-seconds(startTime));
        
        % Store data
        timeData = [timeData; currentTime];
        tempData = [tempData; currentTemp];
        
        % Calculate rate of change (smoothed over last 5 readings)
        if length(tempData)>= 5
            tempChanges=diff(tempData(end-4:end));
            timeChanges=diff(timeData(end-4:end));
            rateChange=mean(tempChanges ./ timeChanges); % °C per second
            rateChangePerMin = rateChange *60; % Convert to °C per mimute
        else
            rateChangePerMin = 0;
        end
        
        % Calculate predicted temperature in 5 minutes
        predictedTemp = currentTemp+(rateChange*predictionWindow);
        
        % Display information
        clc; % Clear console for cleaner display
        fprintf('Current Temperature: %.2f°C\n', currentTemp);
        fprintf('Rate of Change: %.2f°C/min\n', rateChangePerMin);
        fprintf('Predicted Temp in 5min: %.2f°C\n\n', predictedTemp);
        
        % Control LEDs based on rate of change
        if currentTemp >= 18 && currentTemp <= 24 && abs(rateChangePerMin) <= 4
            % Stable in comfort range - green LED on
            writeDigitalPin(a, greenPin, 1);
            writeDigitalPin(a, yellowPin, 0);
            writeDigitalPin(a, redPin, 0);
        elseif rateChangePerMin > 4
            % Increasing too fast - red LED on
            writeDigitalPin(a, greenPin, 0);
            writeDigitalPin(a, yellowPin, 0);
            writeDigitalPin(a, redPin, 1);
        elseif rateChangePerMin < -4
            % Decreasing too fast - yellow LED on
            writeDigitalPin(a, greenPin, 0);
            writeDigitalPin(a, yellowPin, 1);
            writeDigitalPin(a, redPin, 0);
        else
            % No alert condition - all LEDs off
            writeDigitalPin(a, greenPin, 0);
            writeDigitalPin(a, yellowPin, 0);
            writeDigitalPin(a, redPin, 0);
        end
        
        % Wait for next reading
        pause(timeInterval);
    end
    
    % Turn off all LEDs when done
    writeDigitalPin(a, greenPin, 0);
    writeDigitalPin(a, yellowPin, 0);
    writeDigitalPin(a, redPin, 0);
end