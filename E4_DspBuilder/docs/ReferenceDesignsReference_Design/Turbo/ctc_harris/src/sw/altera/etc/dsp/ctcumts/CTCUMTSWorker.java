package altera.etc.dsp.ctcumts;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.io.RandomAccessFile;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.Properties;

import org.apache.velocity.exception.ParseErrorException;
import org.apache.velocity.exception.ResourceNotFoundException;
import org.apache.velocity.runtime.exception.ReferenceException;
import org.apache.velocity.tools.generic.DateTool;
import org.apache.velocity.tools.generic.MathTool;

import altera.etc.dsp.velocity.VelocityCoder;
import altera.ipbu.ctcumts.CTCUMTSConstants;
import altera.ipbu.flowbase.DATABASE;
import altera.ipbu.flowbase.exceptions.EntryNotFoundException;
import altera.ipbu.flowbase.exceptions.OutOfRangeException;
import altera.ipbu.flowbase.flowmanager.UserDataInterface;
import altera.ipbu.flowbase.flowmanager.events.ProcessEvent;
import altera.ipbu.flowbase.flowmanager.events.ProcessListener;
import altera.ipbu.flowbase.license.eLicense;
import altera.ipbu.flowbase.netlist.NetlistFile;
import altera.ipbu.flowbase.netlist.NetlistLibrary;
import altera.ipbu.flowbase.netlist.model.CTCUMTSModel;
import altera.ipbu.flowbase.plugin.BasePluginWorkerObject;

/**
 * This class generates the core files based on the user parameters
 * @author zpan
 *
 * $Header: //acds/rel/13.1/dsp_builder/dsp_builder2/Documentation/ReferenceDesignsReference_Design/Turbo/ctc_harris/src/sw/altera/etc/dsp/ctcumts/CTCUMTSWorker.java#1 $
 */

public class CTCUMTSWorker extends BasePluginWorkerObject implements ProcessListener
{
	private String codecTypeString;

	// Number of num_engines
	private int num_engines;

	private int codecType;

	// Output File name
	private String outFileName;

	// Entity name
	private String entityName;
	private String topLevelName;

	private String hdlType;
	
	private int inputWidth;
	private int outputWidth;
	private int core_in_debug_mode;
	private String ramType;

	String deviceFamily;

	/**
	 * A variable to control if the source should be encrypted
	 */
	boolean encryptVHDL = false;
	
	String templateFile;

	private CTCUMTSModel model;
	private Hashtable<String,Object> vars;

	protected void plugin_initialize() throws Exception
	{
		model = (CTCUMTSModel)OBJBASE().getModel();
		topLevelName = model.getTopUniqueName();
		hdlType = FLOW_MANAGER().getHdlType();
	}

	protected void plugin_prepare() throws Exception
	{
		/**
		 * Initialize the Hashtable
		 */
		vars = new Hashtable<String,Object>();

		/**
		 * Get user parameters from GUI
		 */
		deviceFamily = getPrivateValue(CTCUMTSConstants.DEVICE_FAMILY_NAME);
		num_engines = Integer.parseInt(getPrivateValue(CTCUMTSConstants.NUM_OF_PROCESSORS_NAME));
		codecType = Integer.parseInt(getPrivateValue(CTCUMTSConstants.CODEC_TYPE_TITLE));

		core_in_debug_mode = Integer.parseInt(getPrivateValue(CTCUMTSConstants.CORE_IN_DEBUG_MODE_NAME));
		switch (codecType)
		{
		case 0:
			codecTypeString = CTCUMTSConstants.CODEC_TYPE_ENCODER;
			break;
		case 1:
			codecTypeString = CTCUMTSConstants.CODEC_TYPE_DECODER;
			break;
		default:
			throw new Exception("Codec type isn't supported yet");
		}

		entityName = model.getModuleName();

		UserDataInterface udiPtf = OBJBASE().getFlowManager().getStateMachine().getWizardDataObject(); //Note that UserDataInterface is a wrapper API over jptf.
		String tool = udiPtf.get_data_by_path(DATABASE.WIZARD_MAIN + "/title"); //you can also use “title? to get the full name
		String version = udiPtf.get_data_by_path(DATABASE.WIZARD_MAIN + "/version"); //format ?6.1?
		String build = udiPtf.get_data_by_path(DATABASE.WIZARD_MAIN + "/build"); //format ?11?
		String releaseDate = udiPtf.get_data_by_path(DATABASE.WIZARD_MAIN + "/release_date"); //format “April, 2006?
		String nameTag = ""; //"_ctc_" + version.replace(".","");

		inputWidth = Integer.parseInt(getPrivateValue(CTCUMTSConstants.NUM_OF_INPUT_BITS_NAME));
		outputWidth = Integer.parseInt(getPrivateValue(CTCUMTSConstants.NUM_OF_OUTPUT_BITS_NAME));
		
		/**
		 * Prepare variables for Velocity
		 */
		vars.put("tool",tool + " " + version + " Build " + build + " "+ releaseDate);
		vars.put("date",new DateTool());
		vars.put("math",new MathTool());

		vars.put("tag", nameTag);
		vars.put("codec_type",codecType);
		vars.put("num_engines",num_engines);
		vars.put("VariationName",topLevelName);
		vars.put("InWidth",inputWidth);
		vars.put("OutWidth",outputWidth);
		vars.put("generator",this);
		vars.put("hdltype",hdlType);
		vars.put("model",model);
		vars.put("device_family",deviceFamily);
		vars.put("codectype",codecType);
		vars.put("inDebug", core_in_debug_mode);

		this.setupVelocity();

		String ocpFile = entityName + ".ocp";
		String ctcCoreFile = entityName + ".vhd";
		String quartusTclFile = topLevelName + "_quartus.tcl";
		String sopcVhdlFile = topLevelName + "_sopc.v";
		String sopcHwTclFile = topLevelName + "_hw.tcl";

		/**
		 * Provide info for the generation report and warnings about file overwrite/conflict
		 *
		 */
//		PLUGIN_MANAGER().addGenerateTimeFile(ctcCoreFile, "Encrypted VHDL file for core component.");
//		PLUGIN_MANAGER().addGenerateTimeFile(ocpFile, "Encrypted OpenCore Plus file.");
		PLUGIN_MANAGER().addGenerateTimeFile(quartusTclFile, "TCL script for running Quartus compilation.");
//		PLUGIN_MANAGER().addGenerateTimeFile(sopcVhdlFile, "SOPC Builder compatible top level Verilog file.");
//		PLUGIN_MANAGER().addGenerateTimeFile(sopcHwTclFile, "SOPC Builder HW TCL file.");
	}

	protected void plugin_start() throws Exception
	{
		String outDir = FLOW_MANAGER().getProjectDirectory();
		String quartusRootDir = FLOW_MANAGER().getQuartusRootDir();

		int i;
		ArrayList<String> files = new ArrayList<String>();

		// Generate the CTCUMTS core model in VHDL
		outFileName = outDir + File.separator + entityName + ".vhd";
//		generateVHDLModel(outFileName);

		NetlistFile[] ctcFiles = model.getFiles();
		String corelibDir = FLOW_MANAGER().getLibDirectory() + File.separator;
		for(i = 0; i < ctcFiles.length; i++)
		{
			// Get the file name and replace "\\" by "/" for the TCL script
			if(ctcFiles[i].getFileLocation() == NetlistFile.LIBRARY)
			{
				String libFilename = corelibDir + ctcFiles[i].getName();
				files.add(libFilename.replace('\\','/'));
			}
			else
			{
				files.add(ctcFiles[i].getName().replace('\\','/'));
			}
		}


 		ArrayList<String> libDirs = new ArrayList<String>();
		NetlistLibrary[] libs = model.getLibraries();
		for(i = 0; libs != null && i < libs.length; i++)
		{
			libDirs.add(libs[i].getLibrary().replace('\\','/'));
		}

		vars.put("toplevel_name",topLevelName);
		vars.put("files",files);
		vars.put("libs",libDirs);
		vars.put("corelibdir",corelibDir.replace('\\','/'));
		vars.put("quartus_rootdir",quartusRootDir.replace('\\','/'));

		/**
		 * Generate Quartus TCL script
		 */
		String qTclFilename = outDir + File.separator + topLevelName +"_quartus.tcl";
		generateQuartusTclScript(qTclFilename);

		/**
		 * Generate NativeLink TCL script
		 */
		String nativelinkTclFilename = outDir + File.separator + topLevelName +"_nativelink.tcl";
		generateNativelinkScript(nativelinkTclFilename);

		/**
		 * Write out TestBenchs
		 */
		if (hdlType.equalsIgnoreCase("VHDL"))
		{
			String testbenchFile = outDir + File.separator + topLevelName +"_tb.vhd";
			writeVHDLTestBench(testbenchFile);
		}
		else // if (hdlType.equalsIgnoreCase("Verilog"))
		{
			String testbenchFile = outDir + File.separator + topLevelName +"_tb.v";
			writeVerilogTestBench(testbenchFile);
		}
	    //generate SOPC Builder files
		String SOPCHwTclFilename = outDir + File.separator + topLevelName +"_hw.tcl";
		String SOPCVhdlFilename = outDir + File.separator + topLevelName +"_sopc.v";
//		generateSOPCBuilderFiles(SOPCHwTclFilename,SOPCVhdlFilename);
		// Generate OpenCore Plus file
//		generateAndEncryptOCPFile();
	}

	protected void plugin_uninitialize() throws Exception
	{
	}

	public void dataReceived(ProcessEvent pe)
	{
	    while (pe.hasMoreTokens()) {
	    }
	}

	public CTCUMTSWorker()
	{
	}

	private void setupVelocity() throws Exception
	{
    	Properties velocityProp = new Properties();

		String templateDir = FLOW_MANAGER().getLibDirectory() + File.separator + "template,.";

    	velocityProp.put("resource.loader","file,jar,class");
    	velocityProp.put("file.resource.loader.class","org.apache.velocity.runtime.resource.loader.FileResourceLoader");
    	velocityProp.put("class.resource.loader.class","org.apache.velocity.runtime.resource.loader.ClasspathResourceLoader");
    	velocityProp.put("jar.resource.loader.class","org.apache.velocity.runtime.resource.loader.JarResourceLoader");
    	velocityProp.put("file.resource.loader.path", templateDir);
    	velocityProp.put("runtime.log", topLevelName + ".log");

        VelocityCoder.getInstance().init(velocityProp);
	}

	private void generateVHDLModel(String outputFilename) throws Exception,
		ResourceNotFoundException,ParseErrorException,ReferenceException
	{
        /**
         * decide on which template file to read
         */
        if (codecTypeString.equalsIgnoreCase(CTCUMTSConstants.CODEC_TYPE_DECODER))
    	{
   			templateFile = "ctcumts_decoder_vhdl_template.vm";
    	}
    	else /** codecType is ENCODER */
    	{
   			templateFile = "ctcumts_encoder_vhdl_template.vm";
    	}

        if(encryptVHDL)
        {
    		UserDataInterface udiPtf = OBJBASE().getFlowManager().getStateMachine().getWizardDataObject(); //Note that UserDataInterface is a wrapper API over jptf.
    		String core_label = udiPtf.get_data_by_path(DATABASE.WIZARD_MAIN + "/short_title"); //you can also use “short_title? to get the full name
    		String release4Year2Month = getRelease4Year2Month();
        	VelocityCoder.getInstance().generateEncryptedFile(vars,templateFile, outputFilename,
        							CTCUMTSConstants.PRODUCT_ID,
        							core_label, // CTCUMTSConstants.CORE_LABEL,
        							release4Year2Month, //CTCUMTSConstants.RELEASE_DATE,
        							CTCUMTSConstants.VENDOR_ID,
				        			CTCUMTSConstants.DEVICE_PERMS);
        }
        else
        {
        	VelocityCoder.getInstance().generateFile(vars, templateFile, outputFilename);
        }
	}

	private void generateQuartusTclScript(String outputFilename) throws Exception,
	ResourceNotFoundException,ParseErrorException,ReferenceException
	{
		templateFile = "run_quartus_tcl.vm";

	   	VelocityCoder.getInstance().generateFile(vars, templateFile, outputFilename);
	}

	private void generateSOPCBuilderFiles(String hwTclFilename,String VhdlFilename ) throws Exception,
		ResourceNotFoundException,ParseErrorException,ReferenceException
	{
		if (codecTypeString.equalsIgnoreCase(CTCUMTSConstants.CODEC_TYPE_DECODER))
		{
			templateFile = "ctc_et_sopc_hw_tcl.vm";
			VelocityCoder.getInstance().generateFile(vars, templateFile, hwTclFilename);

			templateFile = "ctc_et_sopc_v.vm";
			VelocityCoder.getInstance().generateFile(vars, templateFile, VhdlFilename);
		}
		else
		{
			// TODO: add support to SOPC Builder file generation
		}
	}


	private void generateTBInputFile(boolean isInterpolator)
	{
	}

	private void writeVHDLTestBench(String outputFilename) throws Exception,
	ResourceNotFoundException,ParseErrorException,ReferenceException
	{
        if (codecTypeString.equalsIgnoreCase(CTCUMTSConstants.CODEC_TYPE_DECODER))
        {
        	templateFile = "ctcumts_decoder_vhdl_tb.vm";
        	generateTBInputFile(false);
        }
        else
        {
        	templateFile = "ctcumts_encoder_vhdl_tb.vm";
        	generateTBInputFile(false);
        }

	   	VelocityCoder.getInstance().generateFile(vars, templateFile, outputFilename);
	}

	private void writeVerilogTestBench(String outputFilename) throws Exception,
	ResourceNotFoundException,ParseErrorException,ReferenceException
	{
        if (codecTypeString.equalsIgnoreCase(CTCUMTSConstants.CODEC_TYPE_DECODER))
        {
        	templateFile = "ctcumts_decoder_verilog_tb.vm";
        	generateTBInputFile(true);
        }
        else
        {
        	templateFile = "ctcumts_encoder_verilog_tb.vm";
        	generateTBInputFile(false);
        }

	   	VelocityCoder.getInstance().generateFile(vars, templateFile, outputFilename);
	}

	/**
	 * A method to generate NativeLink TCL script
	 */
	private void generateNativelinkScript(String outputFilename) throws Exception,
	ResourceNotFoundException,ParseErrorException,ReferenceException
	{
		templateFile = "ctcumts_nativelink_tcl.vm";

	   	VelocityCoder.getInstance().generateFile(vars, templateFile, outputFilename);
	}

	/**
	   * @param strName String the name of the wanted Private
	   * @return String which represent the value of the wanted Private
	   */
	private String getPrivateValue(String strName)
	{
	    String value = null;
	    try {
	      value = model.getPrivate(strName).getValue();
	    }
	    catch (EntryNotFoundException e) {
	      e.printStackTrace();
	    }
	    return value;
	}

	private void generateAndEncryptOCPFile() throws OutOfRangeException
	{
		String projectDir = OBJBASE().getFlowManager().getProjectDirectory();
		String ocpFileName = projectDir + File.separator + entityName + ".ocp";
		UserDataInterface udiPtf = OBJBASE().getFlowManager().getStateMachine().getWizardDataObject(); //Note that UserDataInterface is a wrapper API over jptf.
		String coreLabel = udiPtf.get_data_by_path(DATABASE.WIZARD_MAIN + "/short_title"); //you can also use “short_title? to get the full name
		// Release date “April, 2006? => "2006.04"
		String release4Year2Month = getRelease4Year2Month();

		StringBuffer fileContentsBuffer = new StringBuffer();
		fileContentsBuffer.append("// IP Toolbench Generated File.\n");
		fileContentsBuffer.append("timeout = 1 hour;\n");
		fileContentsBuffer.append("soft_timeout = 0;\n");
        fileContentsBuffer.append("entity = ").append(entityName).append(";\n");
        fileContentsBuffer.append("core_name = '").append(coreLabel).append("';\n");
        fileContentsBuffer.append("message = '").append(coreLabel).append(" MegaCore will be disabled after the timeout is reached';\n");
		fileContentsBuffer.append("// Time-out ports\n");
		fileContentsBuffer.append("input reset_n = 1'b0;");
		fileContentsBuffer.append("output source_data = all'b0;");

		eLicense.createEncryptedFile(fileContentsBuffer.toString(), ocpFileName,
				CTCUMTSConstants.PRODUCT_ID,
				coreLabel,
				release4Year2Month,
				CTCUMTSConstants.VENDOR_ID,
				CTCUMTSConstants.DEVICE_PERMS);
	}

	/**
	 * Method to get the release4Year2Month in the format of "2007.05"
	 * for release date defined in ptf as "May, 2007"
	 * @return
	 */
	private String getRelease4Year2Month() throws OutOfRangeException
	{
		UserDataInterface udiPtf = OBJBASE().getFlowManager().getStateMachine().getWizardDataObject(); //Note that UserDataInterface is a wrapper API over jptf.
		String release_Date = udiPtf.get_data_by_path(DATABASE.WIZARD_MAIN + "/release_date"); //format “April, 2006?
		
		// Remove spaces in the string
		String releaseDate = release_Date.replaceAll("\\s", "");

		// Split "May,2007" to {"May","2007"}
		String[] str = releaseDate.split(",");

		// Following code doesn't work on non-English operating systems. So I have to list the months instead.
		// (SPR 236923)
		//
		// DateFormatSymbols dfsymbols = new DateFormatSymbols();
		// String[] months = dfsymbols.getMonths();
		String[] months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};

		int i;
		for (i = 0; i < months.length; i++)
		{
			if (str[0].equalsIgnoreCase(months[i]))
			{
				break;
			}
		}

		if (i >= months.length)
		{
			throw new OutOfRangeException("Invalid date: " + release_Date);
		}

        return String.format("%1$4s.%2$02d",str[1],i+1);
	}
}
