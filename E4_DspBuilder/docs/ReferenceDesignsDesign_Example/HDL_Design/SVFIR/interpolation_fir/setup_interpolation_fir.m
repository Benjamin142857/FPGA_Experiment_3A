clear variables
close all
ChanCount=4;
ClockRate=245.76;
ClockMargin = 0.0;
SampleRate=15.36;
Period=ClockRate / SampleRate;
FilterLength=128;
interpolation = 4;
SampleTime = 1;
%SampleTime = 1/(ClockRate * 1e6);   % uncomment this line to simulate the model with realworld time

disp(['Parameters set from setup_demo_fird.m: FilterLength=' num2str(FilterLength) '; ChanCount = ' num2str(ChanCount) '; ClockRate = ' num2str(ClockRate) '; ClockMargin = ' num2str(ClockMargin) '; SampleRate = ' num2str(SampleRate) '; interpolation = ' num2str(interpolation) ';']);

% Derived Parameters 
% WARNING - DO NOT MODIFY!!!
ChanWireCount=ceil(ChanCount/Period);
ChanCycleCount=ceil(ChanCount/ChanWireCount);

load sine_interpolation_fir_input.txt;
% load interpolation_fir_output.txt;
period_out = Period/interpolation;

% make up for the 1st lost output data
% interpolation_fir_output = [0; interpolation_fir_output];

out_data_file = fopen('interpolation_fir_output.txt');
d = fscanf(out_data_file, '%s'); % a long string

N = 15; % 15 hexidecimal digitals per output
L = length(d);

for k=1:L/N
    a = d((k-1)*N+1 : k*N);
    b = hex2dec(a);
    if b > power(2, N*4-1)
        c = b-power(2,N*4);
    else
        c = b;
    end
%     pause
    tmp(k) = c;
end;

fclose(out_data_file);
dout = tmp;
plot(dout)