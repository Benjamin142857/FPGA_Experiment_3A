////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  $Header: //acds/rel/13.1/dsp_builder/dsp_builder2/Documentation/ReferenceDesignsReference_Design/Turbo/ctc_harris/src/sw/altera/ipbu/ctcumts/CTCUMTSConstants.java#1 $
//  $log: $
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

package altera.ipbu.ctcumts;

/**
 * CTC
 * Copyright (c) 2006, Altera Corporation
 * @author zpan
 * @version 1.0
 */

public class CTCUMTSConstants
{
	public static final String	CODEC_TYPE_TITLE = "Codec Type";

	public static final String  CODEC_TYPE_ENCODER	= "Encodor";
	public static final String  CODEC_TYPE_DECODER = "Decoder";
  	public static final String 	CODEC_TYPE_DEFAULT_VALUE =  CODEC_TYPE_DECODER;
	public static final String[] CODEC_TYPES = new String[] {CODEC_TYPE_ENCODER, CODEC_TYPE_DECODER};

	public static final String 	MAP_DECODING_NAME 	= "map_decoding";
	public static final String 	MAP_DECODING_TYPE_LOGMAP  = "Log-MAP";
	public static final String 	MAP_DECODING_TYPE_MAX_LOGMAP  = "Max-log-MAP";
	public static final String[] MAP_DECODING_TYPES = new String[] {MAP_DECODING_TYPE_MAX_LOGMAP,MAP_DECODING_TYPE_LOGMAP};

	public static final String[] 	REG_MAP_TYPES = {"Logic Element", "Memory"};

	// Supported memory types
	// Stratix: M512, M4K, MRAM
	// Stratix GX: M512, M4K
	// Stratix II: M512, M4K, MRAM
	// Stratix II GX: M512, M4K
	// Stratix III: M9K, M144K, MLAB,
	// Cyclone: M4K
	// Cyclone II: M4K
	// Cyclone III: M9K
	// HardCopy II: M512, M4K, MRAM

	public static final String 		MEM_M512 = "M512"; 		// Stratix, Stratix II
	public static final String 		MEM_M4K = "M4K";		// Stratix II, Cyclone II
	public static final String 		MEM_M9K = "M9K"; 		// Stratix III, Cyclone III
	public static final String 		MEM_M144K = "M144K";	// Stratix III
	public static final String 		MEM_MLAB = "MLAB"; 		// Stratix III
	public static final String 		MEM_MRAM = "MRAM"; 		// Stratix III
	public static final String 		MEM_AUTO = "AUTO";
	// Default one for Stratix II
	public static final String[] 	MEM_TYPES = new String[]{MEM_AUTO, MEM_M512, MEM_M4K};

	public static final String	RAM_TYPE_DEFAULT_VALUE = MEM_AUTO;

	public static final String	DEVICE_FAMILY_NAME = "Device Family";

	public static final String STRATIX 			= new String("Stratix");
	public static final String STRATIX_GX 		= new String("Stratix GX");
	public static final String CYCLONE 			= new String("Cyclone");
	public static final String STRATIX_II 		= new String("Stratix II");
	public static final String STRATIX_II_GX	= new String("Stratix II GX");
	public static final String STRATIX_II_GX_LT	= new String("Arria GX");
	public static final String CYCLONE_II 		= new String("Cyclone II");
	public static final String STRATIX_III		= new String("Stratix III");
	public static final String STRATIX_IV		= new String("Stratix IV");
	public static final String CYCLONE_III		= new String("Cyclone III");
	public static final String HARDCOPY_II		= new String("HardCopy II");
    public static final String CYCLONE_IV_GX    = new String("Cyclone IV GX");
    public static final String CYCLONE_IV_E		= new String("Cyclone IV E");


	public static final String	DEVICE_FAMILY_DEFAULT = STRATIX_IV;
	/**
	 * Range of supported device families
	 * You can add new entries here and those will be reflected all over the program
	 */
	public static final String[] DEVICE_FAMILIES = {STRATIX_IV, STRATIX_III, STRATIX_II_GX_LT, STRATIX_II_GX, STRATIX_II, STRATIX_GX, STRATIX, HARDCOPY_II, CYCLONE_IV_E, CYCLONE_IV_GX, CYCLONE_III, CYCLONE_II, CYCLONE};

	public static final String 	NUM_OF_PROCESSORS_NAME = "Number of Engines";
	public static final int    	NUM_OF_PROCESSORS_DEFAULT_VALUE = 4;
	public static final int[]  	NUM_OF_PROCESSORS = {2, 4};

	public static final String 	NUM_OF_INPUT_BITS_NAME = "Number of Input Bits";
	public static final int    	NUM_OF_INPUT_BITS_DEFAULT_VALUE = 8;
	public static final int[]  	NUM_OF_INPUT_BITS = {4,5,6,7,8};

	public static final String 	NUM_OF_OUTPUT_BITS_NAME = "Number of Output Bits";
	public static final int    	NUM_OF_OUTPUT_BITS_DEFAULT_VALUE = 1;
	public static final int[]  	NUM_OF_OUTPUT_BITS = {1};

	public static final String 	CORE_IN_DEBUG_MODE_NAME = "core in debug mode";
	public static final String 	RAM_TYPE_NAME = "ram type"; // "AUTO", "MLAB", ...
	public static final String []  RAM_TYPES = new String[]{MEM_AUTO, MEM_MLAB};
	public static final String  RAM_TYPE_DEFAULT = MEM_AUTO;

	public static final short 	PRODUCT_ID = (short)0x00cd;

	public static final String  CORE_LABEL = "CTCUMTS";
	public static final String  RELEASE_DATE = "2010.1";
	public static final short   VENDOR_ID = (short)0x6af7; // Altera ID;
	public static final String[] DEVICE_PERMS = new String[]{"-f", "a086000", "-m", "-f", "34000000", "-w2", "-m"};

	private static final String AUK_DSPIP_CTC_UMTS_DECODER_TOP_VHD = new String("auk_dspip_ctc_umts_decoder_top.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_INPUT_VHD = new String("auk_dspip_ctc_umts_input.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_INPUT_RAM_VHD = new String("auk_dspip_ctc_umts_input_ram.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_LIB_PKG_VHD = new String("auk_dspip_ctc_umts_lib_pkg.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_MAP_ALPHA_VHD = new String("auk_dspip_ctc_umts_map_alpha.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_MAP_BETA_VHD= new String("auk_dspip_ctc_umts_map_beta.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_MAP_CONSTLOGMAP_VHD = new String("auk_dspip_ctc_umts_map_constlogmap.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_MAP_CONSTLOGMAP_PIPELINED_VHD = new String("auk_dspip_ctc_umts_map_constlogmap_pipelined.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_MAP_DECODER_VHD = new String("auk_dspip_ctc_umts_map_decoder.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_MAP_GAMMA_VHD = new String("auk_dspip_ctc_umts_map_gamma.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_MAP_LLR_VHD = new String("auk_dspip_ctc_umts_map_llr.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_MAP_LOGMAP_VHD = new String("auk_dspip_ctc_umts_map_logmap.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_MAP_MAXLOGMAP_VHD = new String("auk_dspip_ctc_umts_map_maxlogmap.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_MAP_MAXLOGMAP_PIPELINED_VHD = new String("auk_dspip_ctc_umts_map_maxlogmap_pipelined.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_OUTPUT_VHD = new String("auk_dspip_ctc_umts_output.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_OUT_MEM_VHD = new String("auk_dspip_ctc_umts_out_mem.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_RAM_VHD = new String("auk_dspip_ctc_umts_ram.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_SISO_VHD = new String("auk_dspip_ctc_umts_siso.vhd");
	private static final String AUK_DSPIP_DELAY_VHD = new String("auk_dspip_delay.vhd");
	private static final String AUK_DSPIP_LIB_PKG_VHD = new String("auk_dspip_lib_pkg.vhd");
	private static final String AUK_DSPIP_MATH_PKG_VHD = new String("auk_dspip_math_pkg.vhd");
	private static final String AUK_DSPIP_ROUNDSAT_VHD = new String("auk_dspip_roundsat.vhd");
	private static final String AUK_DSPIP_TEXT_PKG_VHD = new String("auk_dspip_text_pkg.vhd");
//	private static final String AUK_DSPIP_AVALON_STREAMING_SOURCE_MODEL_VHD = new String("auk_dspip_avalon_streaming_source_model.vhd");
//	private static final String AUK_DSPIP_AVALON_STREAMING_SINK_MODEL_VHD = new String("auk_dspip_avalon_streaming_sink_model.vhd");
	private static final String AUK_DSPIP_CTC_UMTSITLV_MULTMOD_VHD = new String("auk_dspip_ctc_umtsitlv_multmod.vhd");
	private static final String AUK_DSPIP_CTC_UMTSITLV_MULT_SEQ_GEN_VHD = new String("auk_dspip_ctc_umtsitlv_mult_seq_gen.vhd");
	private static final String AUK_DSPIP_CTC_UMTSITLV_MUL_PIPE_VHD = new String("auk_dspip_ctc_umtsitlv_mul_pipe.vhd");
	private static final String AUK_DSPIP_CTC_UMTSITLV_PAPBPC_TABLE_VHD = new String("auk_dspip_ctc_umtsitlv_papbpc_table.vhd");
	private static final String AUK_DSPIP_CTC_UMTSITLV_PRIME_ROM_VHD = new String("auk_dspip_ctc_umtsitlv_prime_rom.vhd");
	private static final String AUK_DSPIP_CTC_UMTSITLV_SETUP_CONTROL_VHD = new String("auk_dspip_ctc_umtsitlv_setup_control.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_AST_SINK_VHD = new String("auk_dspip_ctc_umts_ast_sink.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_DITLV_SEQ_GEN_VHD = new String("auk_dspip_ctc_umts_ditlv_seq_gen.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_FIFO_VHD = new String("auk_dspip_ctc_umts_fifo.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_ITLV2_VHD = new String("auk_dspip_ctc_umts2_itlv.vhd");  // swap original for v2
    private static final String AUK_DSPIP_CTC_UMTS_ITLV2_LUT_VHD = new String("auk_dspip_ctc_umtsitlv2_lut.vhd");  // swap original for v2
	private static final String AUK_DSPIP_CTC_UMTS_ITLVR_RAM_VHD = new String("auk_dspip_ctc_umts_itlvr_ram.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_MEM_VHD = new String("auk_dspip_ctc_umts_mem.vhd");

	private static final String AUK_DSPIP_CTC_UMTS_CONV_ENCODE_VHD         = new String("auk_dspip_ctc_umts_conv_encode.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_ENCODE_VHD              = new String("auk_dspip_ctc_umts_encode.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_ENCODER_VHD             = new String("auk_dspip_ctc_umts_encoder.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_ENCODER_TOP_VHD         = new String("auk_dspip_ctc_umts_encoder_top.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_ENC_AST_BLOCK_SINK_VHD  = new String("auk_dspip_ctc_umts_enc_ast_block_sink.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_ENC_AST_BLOCK_SRC_VHD   = new String("auk_dspip_ctc_umts_enc_ast_block_src.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_ENC_INPUT_VHD           = new String("auk_dspip_ctc_umts_enc_input.vhd");
	private static final String AUK_DSPIP_CTC_UMTS_ENC_INPUT_RAM_VHD       = new String("auk_dspip_ctc_umts_enc_input_ram.vhd");

	public static final String[] CTCUMTSDecoderLibraryFiles = new String[] {
		 AUK_DSPIP_CTC_UMTS_DECODER_TOP_VHD,
		 AUK_DSPIP_CTC_UMTS_INPUT_VHD,
		 AUK_DSPIP_CTC_UMTS_INPUT_RAM_VHD,
		 AUK_DSPIP_CTC_UMTS_LIB_PKG_VHD,
		 AUK_DSPIP_CTC_UMTS_MAP_ALPHA_VHD,
		 AUK_DSPIP_CTC_UMTS_MAP_BETA_VHD,
		 AUK_DSPIP_CTC_UMTS_MAP_CONSTLOGMAP_VHD,
		 AUK_DSPIP_CTC_UMTS_MAP_CONSTLOGMAP_PIPELINED_VHD,
		 AUK_DSPIP_CTC_UMTS_MAP_DECODER_VHD,
		 AUK_DSPIP_CTC_UMTS_MAP_GAMMA_VHD,
		 AUK_DSPIP_CTC_UMTS_MAP_LLR_VHD,
		 AUK_DSPIP_CTC_UMTS_MAP_LOGMAP_VHD,
		 AUK_DSPIP_CTC_UMTS_MAP_MAXLOGMAP_VHD,
		 AUK_DSPIP_CTC_UMTS_MAP_MAXLOGMAP_PIPELINED_VHD,
		 AUK_DSPIP_CTC_UMTS_OUTPUT_VHD,
		 AUK_DSPIP_CTC_UMTS_OUT_MEM_VHD,
		 AUK_DSPIP_CTC_UMTS_RAM_VHD,
		 AUK_DSPIP_CTC_UMTS_SISO_VHD,
		 AUK_DSPIP_CTC_UMTSITLV_MULTMOD_VHD,
		 AUK_DSPIP_CTC_UMTSITLV_MULT_SEQ_GEN_VHD,
		 AUK_DSPIP_CTC_UMTSITLV_MUL_PIPE_VHD,
		 AUK_DSPIP_CTC_UMTSITLV_PAPBPC_TABLE_VHD,
		 AUK_DSPIP_CTC_UMTSITLV_PRIME_ROM_VHD,
		 AUK_DSPIP_CTC_UMTSITLV_SETUP_CONTROL_VHD,
		 AUK_DSPIP_CTC_UMTS_AST_SINK_VHD,
		 AUK_DSPIP_CTC_UMTS_DITLV_SEQ_GEN_VHD,
		 AUK_DSPIP_CTC_UMTS_FIFO_VHD,
		 AUK_DSPIP_CTC_UMTS_ITLV2_VHD,
         AUK_DSPIP_CTC_UMTS_ITLV2_LUT_VHD,
		 AUK_DSPIP_CTC_UMTS_ITLVR_RAM_VHD,
		 AUK_DSPIP_CTC_UMTS_MEM_VHD,
		 AUK_DSPIP_DELAY_VHD,
		 AUK_DSPIP_LIB_PKG_VHD,
		 AUK_DSPIP_MATH_PKG_VHD,
		 AUK_DSPIP_ROUNDSAT_VHD,
		 AUK_DSPIP_TEXT_PKG_VHD
	};

	public static final String[] CTCUMTSEncoderLibraryFiles = new String[] {
		 AUK_DSPIP_CTC_UMTS_LIB_PKG_VHD,
		 AUK_DSPIP_CTC_UMTSITLV_MULTMOD_VHD,
		 AUK_DSPIP_CTC_UMTSITLV_MULT_SEQ_GEN_VHD,
		 AUK_DSPIP_CTC_UMTSITLV_MUL_PIPE_VHD,
		 AUK_DSPIP_CTC_UMTSITLV_PAPBPC_TABLE_VHD,
		 AUK_DSPIP_CTC_UMTSITLV_PRIME_ROM_VHD,
		 AUK_DSPIP_CTC_UMTSITLV_SETUP_CONTROL_VHD,
		 AUK_DSPIP_CTC_UMTS_AST_SINK_VHD,
		 AUK_DSPIP_CTC_UMTS_DITLV_SEQ_GEN_VHD,
		 AUK_DSPIP_CTC_UMTS_FIFO_VHD,
		 AUK_DSPIP_CTC_UMTS_ITLV2_VHD,
        AUK_DSPIP_CTC_UMTS_ITLV2_LUT_VHD,
		 AUK_DSPIP_CTC_UMTS_ITLVR_RAM_VHD,
		 AUK_DSPIP_CTC_UMTS_MEM_VHD,
		 AUK_DSPIP_DELAY_VHD,
		 AUK_DSPIP_LIB_PKG_VHD,
		 AUK_DSPIP_MATH_PKG_VHD,
		 AUK_DSPIP_CTC_UMTS_CONV_ENCODE_VHD,
		 AUK_DSPIP_CTC_UMTS_ENCODE_VHD,
		 AUK_DSPIP_CTC_UMTS_ENCODER_VHD,
		 AUK_DSPIP_CTC_UMTS_ENCODER_TOP_VHD,
		 AUK_DSPIP_CTC_UMTS_ENC_AST_BLOCK_SINK_VHD,
		 AUK_DSPIP_CTC_UMTS_ENC_AST_BLOCK_SRC_VHD,
		 AUK_DSPIP_CTC_UMTS_ENC_INPUT_VHD,
		 AUK_DSPIP_CTC_UMTS_ENC_INPUT_RAM_VHD
	};

}
