/*
 * Project: CTC 
 * 
 * @Authors: zpan
 * Copyrights 2006 Altera Corporation. All rights reserved.
 * 
 * $Header: //acds/rel/13.1/dsp_builder/dsp_builder2/Documentation/ReferenceDesignsReference_Design/Turbo/ctc_harris/src/sw/altera/ipbu/flowbase/netlist/model/CTCUMTSModel.java#1 $
 */
package altera.ipbu.flowbase.netlist.model;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import altera.etc.dsp.util.DeviceRamTypeUtil;
import altera.ipbu.ctcumts.CTCUMTSConstants;
import altera.ipbu.flowbase.DATABASE;
import altera.ipbu.flowbase.FlowConstants;
import altera.ipbu.flowbase.MessageItem;
import altera.ipbu.flowbase.MessageManager;
import altera.ipbu.flowbase.SharedObjectsInterface;
import altera.ipbu.flowbase.exceptions.EntryNotFoundException;
import altera.ipbu.flowbase.exceptions.NetlistInvalidTypeException;
import altera.ipbu.flowbase.exceptions.NetlistInvalidWidthException;
import altera.ipbu.flowbase.exceptions.OutOfRangeException;
import altera.ipbu.flowbase.flowmanager.UserDataInterface;
import altera.ipbu.flowbase.flowmanager.events.ProcessEvent;
import altera.ipbu.flowbase.flowmanager.events.ProcessListener;
import altera.ipbu.flowbase.netlist.NetlistBaseInterface;
import altera.ipbu.flowbase.netlist.NetlistBasePrivateInterface;
import altera.ipbu.flowbase.netlist.NetlistConstant;
import altera.ipbu.flowbase.netlist.NetlistFile;
import altera.ipbu.flowbase.netlist.NetlistLibrary;
import altera.ipbu.flowbase.netlist.NetlistPort;
import altera.ipbu.flowbase.netlist.NetlistPrivate;
import altera.ipbu.flowbase.netlist.model.CTCUMTSModel.XIntegerPrivate;
import altera.ipbu.flowbase.netlist.model.ModelBaseClass.WriteableContinuousIntegerRange;

/**
 * This is a model class for your Wizard
 */
public class CTCUMTSModel extends ModelBaseClass implements ProcessListener
{
  public class XIntegerPrivate extends WriteableIntegerPrivate
  {
    public XIntegerPrivate(String name, int value)
    {
      super(name, value);
    }

    public XIntegerPrivate(String name, int value, Range range)
    {
      super(name, value, range);
    }

    public void setValue(String strValue) throws NullPointerException, IllegalArgumentException, OutOfRangeException
    {
      if (strValue == null)
      {
        throw new NullPointerException("Value passed to UsefulWriteableDoublePrivate must not be null");
      }
      if (m_szValue != null && m_szValue.equals(strValue))
      {
        return;
      }

      try
      {
        int value = Integer.parseInt(strValue);

	setValue(value);
      }
      catch (NumberFormatException e)
      {
          throwException();
      }
    }

    public void setValue(int value) throws OutOfRangeException, IllegalArgumentException
    {
      if (m_range != null)
      {
        if (!m_range.isInRange("" + value))
        {
        	throwException();
        }
      }
    	setValueSilent(value);
    	notifyListener(this);
    }

    public void setEnabled(boolean status)
    {
    	super.setEnabled(status);
    }
    
    private void throwException() throws OutOfRangeException
    {
          WriteableContinuousIntegerRange outputWidthRange = (WriteableContinuousIntegerRange) this.getRange();
          int r_max = outputWidthRange.getMax();
          int r_min = outputWidthRange.getMin();

          throw new OutOfRangeException("The valid range of \"" + m_szName + "\" is between " + r_min + " and " + r_max);
    }
  }

 
  
  public class XStringPrivate extends WriteableStringPrivate
  {
    public XStringPrivate(String name)
    {
      super(name);
    }

    public XStringPrivate(String name, String value)
    {
      super(name, value);
    }

    public XStringPrivate(String name, String value, Range range)
    {
      super(name, value, range);
    }
    public void addRangeItem(String value)
    {
      WriteableDiscreteStringRange range = (WriteableDiscreteStringRange)this.getRange();
      List<String> items = new ArrayList<String>(Arrays.asList(range.getValidValues()));

      if (!items.contains(value))
      {
        items.add(value);
      }
      range.setValidValues(items.toArray(new String[0]));
    }

    public void removeRangeItem(String value)
    {
      WriteableDiscreteStringRange range = (WriteableDiscreteStringRange)this.getRange();
      List<String> items = new ArrayList<String>(Arrays.asList(range.getValidValues()));

      if (items.contains(value))
      {
        items.remove(value);
      }
      range.setValidValues(items.toArray(new String[0]));
    }
    public void setEnabled(boolean enabled)
    {
      super.setEnabled(enabled);
    }

    public void setValue(String strValue) throws OutOfRangeException
    {
      if (strValue == null)
      {
        throw new NullPointerException("Value passed to UsefulWriteableStringPrivate must not be null");
      }
      if (m_szValue != null && m_szValue.equals(strValue))
      {
        return;
      }
      if (hasRange())
      {
        if (!m_range.isInRange(strValue))
        {
        	throw new OutOfRangeException("-----" + strValue + " is out of range+");
        }
      }
      setValueSilent(strValue);
      notifyListener(this);
    }
    }

  public class XBooleanPrivate extends WriteableBooleanPrivate
  {
    public XBooleanPrivate(String name, boolean value)
    {
      super(name, value);
    }

    public void setValueSilent(String value)
    {
      super.setValueSilent(value);
    }

    public void setEnabled(boolean enabled)
    {
      super.setEnabled(enabled);
    }

    public void setValue(String value)
    {
      if (value == null)
      {
        throw new NullPointerException("Value passed to setValue cannot be null");
      }

      if (value.equals("rising")){ value = "true";} else
      if (value.equals("falling")){ value = "false";}

      if (hasRange())
      {
        if (!getRange().isInRange(value))
        {
          System.out.println(value + " is out of range for " + m_szName);
        }
      }
      try
      {
        modifyValue(value);
        notifyListener(this);
      } catch (OutOfRangeException e){e.printStackTrace();}
    }
  }

  XStringPrivate	  deviceFamily;
//	XStringPrivate codecType;
	XIntegerPrivate codecType;
	XIntegerPrivate numOfEngines;
	XIntegerPrivate numOfInputBits;
	XIntegerPrivate numOfOutputBits;
	XStringPrivate  mapDecodingOp;
	XIntegerPrivate coreInDebug;
	XStringPrivate  ramType;

	int block_size_width = 13;
	int iteration_width = 5;
	boolean encoderOnly = false;


  /**
   * Tracks if restore is in progress
   */
  protected boolean m_bRestoreInProgress = false;
  MessageManager messager;

  public void serialize(UserDataInterface udi, byte action, SharedObjectsInterface sharedObjects) throws Exception
  {
    super.serialize(udi, action, sharedObjects);
    initialise();

	//	Get devicefamily Private from global setting
	try
	{
	    String device_family = m_netlist.getPrivateSection().getStringValue("devicefamily");

		if(!deviceFamily.getValue().equalsIgnoreCase(device_family))
	    {
	    	System.out.println("MSG FMC-01: Setting device family to " + device_family);
	    	deviceFamily.setValue(device_family);
	    }

		String msg = "Device family " + deviceFamily.getValue() + " is targeted";
		messager.addMessage(new MessageItem(msg, "description", FlowConstants.WARNING_MESSAGE, "msg_devicefamily"));

		// Device family has been set globally. Disable deviceFamily
		deviceFamily.setEnabled(false);
	}
	catch(Exception e)
	{
		System.out.println("MSG FMC-01: " +e.toString() + " from global setting, use the local setting");
	}
}

  private void initialise()
  {
	  if (Integer.parseInt(codecType.getValue()) == 0)
	  {
		numOfEngines.setEnabled(false);
		numOfInputBits.setEnabled(false);
		mapDecodingOp.setEnabled(false);
		numOfOutputBits.setEnabled(false);
	  }
  }



  protected void notifyListener(NetlistPrivate source) throws OutOfRangeException
  {
    onNotifyListener(source);
    super.notifyListener();
  }

  public void createDerivedPrivates()
  {

	deviceFamily = new XStringPrivate  (CTCUMTSConstants.DEVICE_FAMILY_NAME,
		            CTCUMTSConstants.DEVICE_FAMILY_DEFAULT,
		            new WriteableDiscreteStringRange(CTCUMTSConstants.DEVICE_FAMILIES));

    codecType = new XIntegerPrivate (CTCUMTSConstants.CODEC_TYPE_TITLE,
			0, new WriteableContinuousIntegerRange(0,1));

	numOfEngines = new XIntegerPrivate (CTCUMTSConstants.NUM_OF_PROCESSORS_NAME,
            CTCUMTSConstants.NUM_OF_PROCESSORS_DEFAULT_VALUE,
            new WriteableDiscreteIntegerRange(CTCUMTSConstants.NUM_OF_PROCESSORS));

    mapDecodingOp = new XStringPrivate  (CTCUMTSConstants.MAP_DECODING_NAME,
    				CTCUMTSConstants.MAP_DECODING_TYPE_MAX_LOGMAP,
    				new WriteableDiscreteStringRange(CTCUMTSConstants.MAP_DECODING_TYPES));


    numOfInputBits = new XIntegerPrivate (CTCUMTSConstants.NUM_OF_INPUT_BITS_NAME,
    				CTCUMTSConstants.NUM_OF_INPUT_BITS_DEFAULT_VALUE, 
    				new WriteableDiscreteIntegerRange(CTCUMTSConstants.NUM_OF_INPUT_BITS));

    numOfOutputBits = new XIntegerPrivate (CTCUMTSConstants.NUM_OF_OUTPUT_BITS_NAME,
			CTCUMTSConstants.NUM_OF_OUTPUT_BITS_DEFAULT_VALUE, 
			new WriteableDiscreteIntegerRange(CTCUMTSConstants.NUM_OF_OUTPUT_BITS));

    coreInDebug = new XIntegerPrivate (CTCUMTSConstants.CORE_IN_DEBUG_MODE_NAME,
			    	0, new WriteableContinuousIntegerRange(0,1));

    ramType = new XStringPrivate  (CTCUMTSConstants.RAM_TYPE_NAME,
			CTCUMTSConstants.RAM_TYPE_DEFAULT,
			new WriteableDiscreteStringRange(CTCUMTSConstants.RAM_TYPES));

    messager = getMessageManager();
//    createMessages();
    super.storePrivates();
    initialise();
  }

  /**
   * Overloaded version of <code>onNotifyListener</code>
   * which takes as an argument the private associated
   * with the initiating component
   * @param source The source private
   */
  public void onNotifyListener(NetlistPrivate source) throws OutOfRangeException
  {
	if (Integer.parseInt(codecType.getValue()) == 0)
	{
		numOfEngines.setEnabled(false);
		numOfInputBits.setEnabled(false);
		mapDecodingOp.setEnabled(false);
		numOfOutputBits.setEnabled(false);
	}
	else
	{
		if (encoderOnly)
		{
			codecType.setValue(0);
			throw new OutOfRangeException("Decoder is not supported in this build. Please contact Altera for more information.");
		}
		else
		{
			numOfEngines.setEnabled(true);
			numOfInputBits.setEnabled(true);
			mapDecodingOp.setEnabled(true);
			numOfOutputBits.setEnabled(true);
		}
	}
}

  public void dataReceived(ProcessEvent processEvent)
  {
  }

  public NetlistPort[] getPorts()
  {
    List<NetlistPort> portList = new ArrayList<NetlistPort>();

    try
    {
		portList.add(new NetlistPort("clk", NetlistPort.INPUT, 1));
		portList.add(new NetlistPort("reset_n", NetlistPort.INPUT, 1));
		portList.add(new NetlistPort("sink_sop", NetlistPort.INPUT, 1));
		portList.add(new NetlistPort("sink_eop", NetlistPort.INPUT, 1));
		portList.add(new NetlistPort("sink_valid", NetlistPort.INPUT, 1));
		portList.add(new NetlistPort("source_ready", NetlistPort.INPUT, 1));

		portList.add(new NetlistPort("sink_error", NetlistPort.INPUT, 2));

		portList.add(new NetlistPort("source_sop", NetlistPort.OUTPUT, 1));
		portList.add(new NetlistPort("source_eop", NetlistPort.OUTPUT, 1));
		portList.add(new NetlistPort("source_valid", NetlistPort.OUTPUT, 1));
		portList.add(new NetlistPort("sink_ready", NetlistPort.OUTPUT, 1));
		portList.add(new NetlistPort("source_error", NetlistPort.OUTPUT, 2));
		portList.add(new NetlistPort("source_blk_size", NetlistPort.OUTPUT,	block_size_width));

		portList.add(new NetlistPort("sink_blk_size",NetlistPort.INPUT, block_size_width));

		if (Integer.parseInt(codecType.getValue()) == 0) // encoder
		{
			portList.add(new NetlistPort("sink_data", NetlistPort.INPUT, 1));
			portList.add(new NetlistPort("source_data", NetlistPort.OUTPUT, 3));
		}
		else 
		{
			assert (Integer.parseInt(codecType.getValue()) == 1); // decoder

			int num_of_engines = numOfEngines.getIntegerValue();
			int num_of_in_bits = numOfInputBits.getIntegerValue();
			int num_of_out_bits = numOfOutputBits.getIntegerValue();

			portList.add(new NetlistPort("sink_data", NetlistPort.INPUT, 3 * num_of_in_bits));
			portList.add(new NetlistPort("source_data", NetlistPort.OUTPUT, num_of_out_bits));

			portList.add(new NetlistPort("sink_iter", NetlistPort.INPUT, iteration_width));

			
//			if (Integer.parseInt(coreInDebug.getValue()) == 1) // debug is turned on
//			{
//				portList.add(new NetlistPort("source_debug", NetlistPort.OUTPUT, 16));
//			}
		}
    }
    catch (NetlistInvalidWidthException e)
    {
      e.printStackTrace();
    }
    catch (NetlistInvalidTypeException e)
    {
      e.printStackTrace();
    }

      return portList.toArray(new NetlistPort[portList.size()]);
  }
  /**
   * This function returns the top-level module or interface name
   *
   */
   	public String getModuleName()
   	{
		String moduleName;

		if (Integer.parseInt(codecType.getValue()) == 0) {
			moduleName = "auk_dspip_ctc_umts_encoder_top";
		} else {
			// Decoder
			assert (Integer.parseInt(codecType.getValue()) == 1);
			moduleName = "auk_dspip_ctc_umts_decoder_top";
		}
		return moduleName;
	}

	public String getTopUniqueName() {
		return OBJBASE().getFlowManager().getNetlistTop();
	}

  /**
   * Return defparams/generics of megafunction interface
   */
  public NetlistConstant[] getConstants()
  {
		if (Integer.parseInt(codecType.getValue()) == 0) //encoder
		{
			NetlistConstant use_memory_for_rom_g = new NetlistConstant("USE_MEMORY_FOR_ROM_g", 0);

			return new NetlistConstant[] { };
		} 
		else
		{
			assert (Integer.parseInt(codecType.getValue()) == 1);

			int num_of_in_bits = numOfInputBits.getIntegerValue();
			int num_of_out_bits = numOfOutputBits.getIntegerValue();
			int num_of_engines = numOfEngines.getIntegerValue();
			String ram_type = ramType.getValue();

			NetlistConstant input_width_g = new NetlistConstant("IN_WIDTH_g", num_of_in_bits);
			NetlistConstant output_width_g = new NetlistConstant("OUT_WIDTH_g", num_of_out_bits);
			NetlistConstant nprocessors_g = new NetlistConstant("NENGINES_g", num_of_engines);
		//	NetlistConstant soft_width_g = new NetlistConstant("SOFT_WIDTH_g", num_of_in_bits+3);
			NetlistConstant decoder_type_g = new NetlistConstant("DECODER_TYPE_g", "MAXLOGMAP");

			NetlistConstant ram_type_g = new NetlistConstant("RAM_TYPE_g", ram_type);
			return new NetlistConstant[]{input_width_g,output_width_g, ram_type_g, 
				nprocessors_g,decoder_type_g };
  	}
  }
  /**
   * Return individual Synthesis or simulation file info
   * @param szFileName
   */
  public NetlistFile getFile(String szFileName) throws EntryNotFoundException, NullPointerException
  {
    if(szFileName == null || szFileName.length()<1)
      throw new NullPointerException("Null or Empty string for NetlistFile name");
    NetlistFile[] files = getFiles();

    /**
     * TODO  a better way than finding the file linearly!
     */
    if(files != null)
    {
      for(int i=0; i<files.length; i++)
      {
        if(files[i].getName().equalsIgnoreCase(szFileName))
          return files[i];
      }
    }
    throw new EntryNotFoundException("Entry " + szFileName + " not found in NetlistFile list");
  }

	/**
	 * Returns a list of files for the project
	 */
	public NetlistFile[] getFiles()
	{
		int numOfLibFiles = CTCUMTSConstants.CTCUMTSDecoderLibraryFiles.length;

		if (Integer.parseInt(codecType.getValue()) == 0) {
			numOfLibFiles = CTCUMTSConstants.CTCUMTSEncoderLibraryFiles.length;
		}

		NetlistFile wrapperFiles[] = new NetlistFile[numOfLibFiles + 1];
		System.out.println("Get netlist files ...");

		try
		{
			/**
			 * Wrapper Variation File
			 */
			if (OBJBASE().getFlowManager().getHdlType().equalsIgnoreCase("VHDL"))
			{
				wrapperFiles[0] = new NetlistFile(getTopUniqueName() + ".vhd", NetlistFile.PROJECT);
			}
			else
			{
				wrapperFiles[0] = new NetlistFile(getTopUniqueName() + ".v", NetlistFile.PROJECT);
			}
//			wrapperFiles[1] = new NetlistFile(getModuleName() + ".vhd", NetlistFile.PROJECT);

			String libFilename;
			for (int i = 0; i < numOfLibFiles; i++) {
				// Append coreName + "_" + version + "_" to the file names
//				libFilename = CTCConstants.CTCLibraryFiles[i].replace(".","_" + coreName + "_" + version + ".");

				if (Integer.parseInt(codecType.getValue()) == 0) {
					libFilename = CTCUMTSConstants.CTCUMTSEncoderLibraryFiles[i];
				} else {
					libFilename = CTCUMTSConstants.CTCUMTSDecoderLibraryFiles[i];
				}
				wrapperFiles[i+1] = new NetlistFile(libFilename, NetlistFile.LIBRARY);
			}

/*			for (int i = 0; i < numOfSharedLibFiles; i++) {
				wrapperFiles[i+numOfLibFiles+2] = new NetlistFile(CTCConstants.sharedLibraryFiles[i], NetlistFile.PROJECT);
			}
*/
		}
		catch (Exception e)
		{
			throw (new RuntimeException("Error: Exception getting file: " + e.getMessage()));
		}

		return wrapperFiles;
	}
    /** Get an array of VHDL libraries.
	 * Derived class may overwrite to create parallel/composite implementation.
	 * Base class delegate this call to m_baseModelLibraries
	 * @return an array of the libraries required by the current module.
	 */
    public NetlistLibrary[] getLibraries()
    {
    	return super.getLibraries();
    }

	protected boolean isRestoreInProgress()
	{
		return m_bRestoreInProgress;
	}

	/**
	 * Required to reinitilize dervied parameters to the main list
	 */
	protected void restore(Object archiveId, NetlistBaseInterface dataType)
	{
		m_bRestoreInProgress = true;
		super.restore(archiveId, dataType);
		if(dataType instanceof NetlistBasePrivateInterface)
		{
			createDerivedPrivates();
			notifyListener();
		}
		m_bRestoreInProgress = false;
	}

}
