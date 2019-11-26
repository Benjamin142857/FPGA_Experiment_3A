%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: setup_MixedBlocksetDesign.m
% Description: Script to set variables in Matlab workspace to configure demo_AD9856 model
% Version: $Id: //acds/rel/9.0/ip/aion/modelip/Models/setup_MixedBlocksetDesign.m#1 $
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright © 2008 Altera Corporation. All rights reserved.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Configuration Parameters
 ChanCount	= 2;
 ClockRate	= 200.00;
 ClockMargin= 0.0;
 SampleRate	= 2.5;
 Period		= ClockRate / SampleRate;
 SampleTime = 1;
%SampleTime = 1 / (ClockRate * 1e6);   % Uncomment this line to simulate the model with real-world time 

disp(['Parameters: ChanCount = ' num2str(ChanCount) '; ClockRate = ' num2str(ClockRate) '; ClockMargin = ' num2str(ClockMargin) '; SampleRate = ' num2str(SampleRate) '; SampleTime = ' num2str(SampleTime) ';']);

