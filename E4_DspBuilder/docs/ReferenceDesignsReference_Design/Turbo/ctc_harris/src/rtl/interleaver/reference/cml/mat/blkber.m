load -ascii c:\altera\megacore\turbo_for_umts\test\ctc_encoder_input.txt
load -ascii c:\altera\megacore\turbo_for_umts\test\ctc_decoded_output_gold.txt
plot(ctc_encoder_input - ctc_decoded_output_gold);