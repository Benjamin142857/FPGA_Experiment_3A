/**
 * Utility for copying files
 * 
 * @author zpan
 *
 * $Hearer: $
 * 
 * $Log: FileCopyUtil.java,v $
 * Revision 1.1  2006/11/22 17:12:58  zpan
 * first revision
 *
 */
package altera.etc.dsp.util;

import java.io.*;
import java.nio.channels.*;

public class FileCopyUtil
{
    public FileCopyUtil() {
    }
	/**
	 * Copy file fromFileName to toFileName. Overwrite the file if toFileName exists.
	 * @param fromFileName
	 * @param toFileName
	 * @throws Exception
	 */
	public void copyFile(String fromFileName, String toFileName) throws Exception 
	{
	    File fromFile = new File(fromFileName);
	    File toFile = new File(toFileName);

	    /**
	     * Make sure source file exists, is a file, readable 
	     */
	    if (!fromFile.exists())
	      throw new IOException("Error: " + "no such source file: "
	          + fromFileName);
	    if (!fromFile.isFile())
	      throw new IOException("Error: " + "can't copy directory: "
	          + fromFileName);
	    if (!fromFile.canRead())
	      throw new IOException("Error: " + "source file is unreadable: "
	          + fromFileName);

	    /**
	     * If destination is a directory, append source file name
	     */
	    if (toFile.isDirectory())
	      toFile = new File(toFile, fromFile.getName());

	    /**
	     * If destination file exists, check if it is writable
	     */
	    if (toFile.exists()) 
	    {
	    	if (!toFile.canWrite())
	    	{
	    		throw new IOException("Error: " + "destination file is unwriteable: " + toFileName);
	    	}
	    	else
	    	{
	    		/**
	    		 * TODO: Needed?
	    		 * Destination file is writable, check the directory attributes
	    		 */
				String parent = toFile.getParent();
				if (parent == null)
				{
				    parent = System.getProperty("user.dir");
				}
				File dir = new File(parent);
				if (!dir.exists())
				{
					throw new IOException("Error: " + "destination directory doesn't exist: " + parent);
				}
				if (dir.isFile())
				{
				    throw new IOException("Error: " + "destination is not a directory: " + parent);
				}
				if (!dir.canWrite())
				{
					throw new IOException("Error: " + "destination directory is unwriteable: " + parent);
				}
		    }
	    }

	    FileChannel sourceChannel = new FileInputStream(fromFile).getChannel();
	    FileChannel destinationChannel = new FileOutputStream(toFile).getChannel();
	    
	    // Copy the file
	    destinationChannel.transferFrom(sourceChannel, 0, sourceChannel.size());
	    
	    sourceChannel.close();
	    destinationChannel.close();

	    // Copy the file time stamp
	    toFile.setLastModified(fromFile.lastModified());
	}
}

