%{  
This script for prepare data and parameters for parameter estimator.
1. Load your collected data to MATLAB workspace.
2. Run this script.
3. Follow parameter estimator instruction.
%}

% R and L from experiment
motor_R = 3.824;
motor_L = 0.002919699;
% Optimization's parameters
motor_Eff = 0.999983333;
motor_Ke = 1.35E-04;
motor_J = 0.000075201;
motor_B = 0.040085;




% % Extract collected data
Input = sig_volt.Data;
Time = sig_speed.Time;
 
speed_data = double(squeeze(sig_speed.Data));
Velo = speed_data;
% % Plot 
figure(Name='Motor velocity response')
plot(Time,Velo,Time,Input)

