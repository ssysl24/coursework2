% The main challenges encountered during this project included:
%
% 1) Managing real-time data acquisition while maintaining precise timing
% for both LED control and temperature sampling. To blink LEDs at 
% different intervals while sampling temperature 
% every second requires careful loop structure design.
%
% 2) Coping with noisy temperature readings from the thermistor. 
%
% 3) Error handling and connection verification.
%
% Strengths:
%
% 1) Providing clear visual feedback through the LED indicators
%
% 2) Implementing predictive capabilities that could be useful in
% an aircraft cabin to solve comfort issues in the future
%
% 3) Maintaining clean data logging while operating 
%
% Limitations:
%
% 1) The temperature prediction assumes linear change, which may not
% be consistent with the actual temperature changes
%
% 2) The potential sensor failures may not be considered by the system
%
% 3) The current implementation uses a fixed 10-minute monitoring window,
% which might not be flexible enough for all operational scenarios.
%
% Future Improvements:
%
% 1) Implement a more complex temperature prediction using machine
% learning techniques that could learn from historical data
%
% 2) Add wireless capability to monitor multiple temperature sensors
% throughout the cabin simultaneously.
%
% 3) Develop an app to collect data for flight attendants to monitor
% temperature conditions.
%
% This project provided valuable experience in systems programming, 
% real-time data processing, and the practical challenges of
% hardware-software integration.
