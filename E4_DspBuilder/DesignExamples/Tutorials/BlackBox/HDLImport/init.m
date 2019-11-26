clc
clear
simtime =500;
Tsamp = 1;
 
coef_sc = [-34 677 3998 8191 8191 3998 677 -34];
 
% Generate impulse and chirp test data
t = 1:500;
chirp_input = chirp(t,0,500,0.5) * ((2^13-1));
y1=zeros(500,1)';
y2=zeros(40,1)';
impulsein=[y2 1 y1];
chirpin=[y2 chirp_input];


impulse_in = zeros(simtime,2);
chirp_in = zeros(simtime,2);
for i = 1:simtime
    impulse_in(i, 1) = i*Tsamp;
    impulse_in(i, 2) = impulsein(i);
    chirp_in(i, 1) = i*Tsamp;
    chirp_in(i, 2) = chirpin(i);
end





