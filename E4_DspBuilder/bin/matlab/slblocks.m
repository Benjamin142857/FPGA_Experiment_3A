%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% DSP Builder (Version 7.1)
% Quartus II development tool and MATLAB/Simulink Interface
%
% Copyright © 2007 Altera Corporation. All rights reserved.
%
% Your  use of Altera Corporation's  design tools, logic functions  and other software
% and  tools, and its  AMPP partner logic  functions, and any  output files any of the
% foregoing  (including  device  programming or  simulation files), and any associated
% documentation  or information are  expressly  subject to the terms and conditions of
% the Altera  Program License Subscription Agreement, Altera MegaCore Function License
% Agreement, or  other  applicable  license  agreement, including, without limitation,
% that your use is for the sole  purpose of programming logic  devices manufactured by
% Altera  and sold by  Altera or  its  authorized  distributors. Please  refer to  the
% applicable agreement for further details.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function blkStruct = slblocks

%blkStruct.Name = ['Altera DSP Builder'];
blkStruct.Name = 'Altera Block Rewrite';
%blkStruct.OpenFcn = 'Altelink';
blkStruct.OpenFcn = 'Altelink2';
blkStruct.MaskDisplay = '';
%
% Define the Browser structure array, the first element contains the
% information for the Simulink block library and the second for the
% Simulink Extras block library.
%
Browser(1).Library = 'altelink2';
Browser(1).Name    = 'Altera DSP Builder Standard Blockset';
Browser(1).IsFlat  = 0;% Is this library "flat" (i.e. no subsystems)?

blkStruct.Browser = Browser;

% End of slblocks
