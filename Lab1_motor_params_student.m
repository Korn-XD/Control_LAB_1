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
% STEP PARAM
motor_Eff = 0.99866;
motor_Ke = 0.041524;
motor_J = 1.46E-05;
motor_B = 8.84E-05;

%%  RAMP PARAM

motor_Eff_Ramp = 0.973136667;
motor_Ke_Ramp = 0.037761333;
motor_J_Ramp = 0.000341863;
motor_B_Ramp = 1.07E-04;
%% SINE PI/2 PARAM

motor_Eff_SinPi_2 = 0.999073333;
motor_Ke_SinPi_2 = 0.045154;
motor_J_SinPi_2 = 1.26993E-05;
motor_B_SinPi_2 = 7.21E-05;
%% SINE PI PARAM

motor_Eff_SinPi = 0.99474;
motor_Ke_SinPi = 0.030033333;
motor_J_SinPi = 1.28492E-05;
motor_B_SinPi = 1.55E-04;
%% SINE 2PI PARAM

motor_Eff_Sin2Pi = 0.99932;
motor_Ke_Sin2Pi = 0.038645;
motor_J_Sin2Pi = 1.45203E-05;
motor_B_Sin2Pi = 1.23E-04;
%% Stair PARAM
motor_Eff_Stair = 0.999076667;
motor_Ke_Stair = 0.044075;
motor_J_Stair = 1.35E-05;
motor_B_Stair = 6.12303E-05;

%% Chirp PARAM
motor_Eff_Chirp = 0.992383333;
motor_Ke_Chirp = 0.070106333;
motor_J_Chirp = 1.12E-06;
motor_B_Chirp = 4.18E-04;


% % Extract collected data
%  Input = sig_volt.Data;
%  Time = sig_speed.Time;
%  speed_data = double(squeeze(sig_speed.Data));
%  Velo = speed_data;
% 
% % % Plot 
%  figure(Name='Motor velocity response')
%  plot(Time,Velo,Time,Input)
