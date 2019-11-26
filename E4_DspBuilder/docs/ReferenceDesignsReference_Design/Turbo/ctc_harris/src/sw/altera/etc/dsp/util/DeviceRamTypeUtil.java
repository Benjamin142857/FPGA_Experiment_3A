/**
 * Utility for checking valid RAM types on Altera device families
 *
 * @author: zpan
 *
 * $Header: //acds/rel/13.1/dsp_builder/dsp_builder2/Documentation/ReferenceDesignsReference_Design/Turbo/ctc_harris/src/sw/altera/etc/dsp/util/DeviceRamTypeUtil.java#1 $
 *
 * $Log: DeviceRamTypeUtil.java,v $
 * Revision 1.5  2008/02/04 15:14:57  zpan
 * Corrected the comments
 *
 * Revision 1.4  2008/01/25 10:18:07  lrigby
 * Updated for new device support in Quartus 8.0 - Stratix IV, Hardcopy III
 *
 * Corrected Stratix III Memory type (MRAM is not supported!)
 *
 * Revision 1.3  2007/11/19 10:20:20  zpan
 * added ArrivaGX support
 *
 * Revision 1.2  2007/01/19 11:57:41  zpan
 * added support to Stratix II GX Lite
 *
 * Revision 1.1  2006/12/15 15:21:43  zpan
 * first revision
 *
 *
 */
package altera.etc.dsp.util;

import java.util.regex.*;
import java.util.regex.Pattern;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class DeviceRamTypeUtil
{
	// Supported memory types
	// Stratix: M512, M4K, MRAM
	// Stratix GX: M512, M4K, MRAM
	// Stratix II: M512, M4K, MRAM
	// Stratix II GX: M512, M4K, MRAM
	// Stratix II GX Lite: M512, M4K, MRAM -- it has been renamed to "Arria GX"
	// Stratix III: M9K, M144K, MLAB
	// Stratix IV: M9K, M144K, MLAB
	// Cyclone: M4K
	// Cyclone II: M4K
	// Cyclone III: M9K
	// HardCopy II: M512, M4K, MRAM
	// HardCopy III: M9K, M144K, MLAB

	public static final String 		MEM_M512 = "M512"; 		// Stratix, Stratix II
	public static final String 		MEM_M4K = "M4K";		// Stratix II, Cyclone II
	public static final String 		MEM_M9K = "M9K"; 		// Stratix III, Cyclone III
	public static final String 		MEM_M144K = "M144K";	// Stratix III
	public static final String 		MEM_MLAB = "MLAB"; 		// Stratix III
	public static final String 		MEM_MRAM = "MRAM"; 		// Stratix II
	public static final String 		MEM_AUTO = "AUTO";
	public static final String[] 	MEM_TYPES_STRATIX = new String[]{MEM_AUTO, MEM_M512, MEM_M4K, MEM_MRAM};
	public static final String[] 	MEM_TYPES_STRATIX_II = new String[]{MEM_AUTO, MEM_M512, MEM_M4K, MEM_MRAM};
	public static final String[] 	MEM_TYPES_STRATIX_III = new String[]{MEM_AUTO, MEM_M9K, MEM_M144K, MEM_MLAB};
	public static final String[] 	MEM_TYPES_CYCLONE = new String[]{MEM_AUTO, MEM_M4K};
	public static final String[] 	MEM_TYPES_CYCLONE_II = new String[]{MEM_AUTO, MEM_M4K};
	public static final String[] 	MEM_TYPES_CYCLONE_III = new String[]{MEM_AUTO, MEM_M9K};

	public DeviceRamTypeUtil()
	{
    }

	/**
	 * Get the Copy file fromFileName to toFileName. Overwrite the file if toFileName exists.
	 * @param fromFileName
	 * @param toFileName
	 * @throws Exception
	 */
	public String[] getRamTypeString(String devFamily)
	{
		// Remove spaces in devFamily
		String family = new String(devFamily.replaceAll("\\s", ""));

		if (family.equalsIgnoreCase("Stratix") ||
			family.equalsIgnoreCase("StratixGX"))
		{
			return MEM_TYPES_STRATIX;
		}
		else if(family.equalsIgnoreCase("StratixII") ||
				family.equalsIgnoreCase("StratixIIGX") ||
				family.equalsIgnoreCase("StratixIIGXLite") || // StratixIIGXLite = ArriaGX
				family.equalsIgnoreCase("ArriaGX") ||
				family.equalsIgnoreCase("HardcopyII"))
		{
			return MEM_TYPES_STRATIX_II;
		}
		else if(family.equalsIgnoreCase("StratixIII") ||
				family.equalsIgnoreCase("StratixIIIGX") ||
				family.equalsIgnoreCase("StratixIV") ||
				family.equalsIgnoreCase("HardcopyIII"))
		{
			return MEM_TYPES_STRATIX_III;
		}
		else if(family.equalsIgnoreCase("Cyclone"))
		{
			return MEM_TYPES_CYCLONE;
		}
		else if(family.equalsIgnoreCase("CycloneII"))
		{
			return MEM_TYPES_CYCLONE_II;
		}
		else if(family.equalsIgnoreCase("CycloneIII"))
		{
			return MEM_TYPES_CYCLONE_III;
		}
		else
		{
			// New supported device? Allow AUTO only!
			return new String[]{MEM_AUTO};
		}
	}

	public boolean isRamTypeValid(String devFamily, String ramType)
	{
		String [] RamTypes = this.getRamTypeString(devFamily);

		List<String> items = new ArrayList<String>(Arrays.asList(RamTypes));

	    return (items.contains(ramType));
	}
}

