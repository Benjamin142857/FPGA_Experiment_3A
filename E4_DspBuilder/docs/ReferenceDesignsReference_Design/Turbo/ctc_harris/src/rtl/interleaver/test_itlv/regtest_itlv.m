for i=40:41 
   reference(i, 1:i) = Create3GPP2Interleaver(i);
   system('vsim work.tb_auk_dspip_ctc_umts2_itlv -Gblk=' & i);
end

load ./result.txt