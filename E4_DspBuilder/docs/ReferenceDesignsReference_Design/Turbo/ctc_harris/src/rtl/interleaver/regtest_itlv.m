clear variables;

% set up CML
cd ./../../../cml;
CmlStartup;
cd ./../src/rtl/interleaver;

% set up simulation
if (exist('work'))
  system('vdel -all');
end;
system('vlib work');
system('vmap work work');
%system('vcom -work work ./../auk_dspip_ctc_umts_lib_pkg.vhd');
system('vcom -work work auk_dspip_ctc_umtsitlv2_lut.vhd');
system('vcom -work work auk_dspip_ctc_umts2_itlv.vhd');
system('vcom -work work tb_auk_dspip_ctc_umts2_itlv.vhd');

fileID = fopen('log.txt', 'a')
passes = 0;
fails = 0;

%forced_values = [1216 1840 3680 3120 4688 4704 5024 3776 5040 3520 3536 4240];
%forced_values = [63 127 255 511 1023 2047 4095];
forced_values = [4300 4296 4281 4277];

% run simulation for all block sizes
for i= forced_values %[40:5114]
    
   reference = Create3GPP2Interleaver(i);
   system(['vsim work.tb_auk_dspip_ctc_umts2_itlv  -do "run -all; quit -f" -wlfdeleteonquit -Gblk=', int2str(i)]);
   %use the line below instead for debugging
   %system(['vsim work.tb_auk_dspip_ctc_umts2_itlv  -gui -do "do allwave.do; run -all" -wlfdeleteonquit -Gblk=', int2str(i)])
hdl = load(['result_', int2str(i), '.txt']);
    
   if isequal(reference, hdl)
       fprintf(fileID, 'pass for block size %d\n\n ', i);
       fprintf('pass for block size %d\n\n ', i);
       %system(['rm -f result_', int2str(i), '.txt']); % only keep hdl result when there is a mismatch
       passes = passes+1;
   else
       fprintf(fileID, 'fail for block size %d\n\n', i);
       fprintf('fail for block size %d\n\n', i);
       reference
       hdl
       fails = fails+1;
   end
   fprintf('\n\n***** %d passes and %d fails so far ...\n\n', passes, fails)
   
end

fclose(fileID);

fprintf('\n\nFinished.  %d passes and %d fails.  You can check the results in log.txt.\n\n', passes, fails);


