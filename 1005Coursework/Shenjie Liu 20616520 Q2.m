function temp_monitor(a)
    % Pins configuration
    tempPin = 'A0';    % Temperature sensor pin
    redLED = 'D9';     
    yellowLED = 'D10';  
    greenLED = 'D11';   
    
    V0 = 0.5;          % Voltage at 0°C (V)
    TC = 0.01;         % Temperature coefficient (V/°C)
    
    % LED control parameters
    greenRange = [18, 24];  % Temperature range for green LED (°C)
    yellowBlinkInterval = 0.5; % Blink interval for yellow LED (s)
    redBlinkInterval = 0.25;   % Blink interval for red LED (s)
    
    % Initialize data storage
    maxDataPoints = 600;      %10 minutes
    tempData = zeros(1, maxDataPoints);
    timeData = zeros(1, maxDataPoints);
    dataCount = 0;
    
    % Initialize plot
    figure;
    hPlot = plot(NaN, NaN, 'b-', 'LineWidth', 2);
    title('Real-time Temperature Monitoring');
    xlabel('Time (s)');
    ylabel('Temperature (°C)');
    grid on;
    yLimits = [10, 30];  % Initial y-axis 
    ylim(yLimits);
    
    % Configure pins
    configurePin(a, redLED, 'DigitalOutput');
    configurePin(a, yellowLED, 'DigitalOutput');
    configurePin(a, greenLED, 'DigitalOutput');
    
    % Main monitoring loop
    tStart = tic;
    while true
        % Read and process temperature
        voltage = readVoltage(a, tempPin);
        temperature = (voltage - V0) / TC;
        elapsedTime = toc(tStart);
        
        % Update data arrays
        dataCount = dataCount + 1;
        if dataCount > maxDataPoints
            % Shift data when buffer is full
            tempData = [tempData(2:end), temperature];
            timeData = [timeData(2:end), elapsedTime];
        else
            tempData(dataCount) = temperature;
            timeData(dataCount) = elapsedTime;
        end
        
        % Update plot
        set(hPlot, 'XData', timeData(1:dataCount), 'YData', tempData(1:dataCount));
        yLimits = [min([tempData(1:dataCount), yLimits(1)])-2, ...
                 max([tempData(1:dataCount), yLimits(2)])+2];
        ylim(yLimits);
        xlim([max(0, elapsedTime-60), elapsedTime+1]);
        drawnow;
        
        % Control LEDs based on temperature range
        if temperature >= greenRange(1) && temperature <= greenRange(2)
            % Comfort range - solid green
            writeDigitalPin(a, greenLED, 1);
            writeDigitalPin(a, yellowLED, 0);
            writeDigitalPin(a, redLED, 0);
            pause(1);
        elseif temperature < greenRange(1)
            % Below range - blinking yellow
            controlLED(a, yellowLED, yellowBlinkInterval, 1);
        else
            % Above range - blinking red
            controlLED(a, redLED, redBlinkInterval, 1);
        end
    end
end

% Helper function for LED blinking
function controlLED(a, ledPin, interval, duration)
    tStart = tic;
    while toc(tStart) < duration
        writeDigitalPin(a, ledPin, 1);
        pause(interval/2);
        writeDigitalPin(a, ledPin, 0);
        pause(interval/2);
    end
end