%
% IIR Order 2
%
[Num,Den] = butter(2,0.4);
figure(1);
freqz(Num,Den);
figure(2);
grpdelay(Num,Den);

% Pass coefficient to the Simulink System topiir
close_system;
open('topiir');
set_param('topiir/B1','vgain','Den(2)');
set_param('topiir/B2','vgain','Den(3)');
set_param('topiir/A0','vgain','Num(1)');
set_param('topiir/A1','vgain','Num(2)');
set_param('topiir/A2','vgain','Num(3)');
save_system('topiir');