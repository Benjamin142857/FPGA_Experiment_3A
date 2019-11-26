/**
 * Velocity Coder: a utility using Velocity to generate code
 * 
 * @author zpan
 *
 * $Header: //acds/rel/13.1/dsp_builder/dsp_builder2/Documentation/ReferenceDesignsReference_Design/Turbo/ctc_harris/src/sw/altera/etc/dsp/velocity/VelocityCoder.java#1 $
 * $Log: VelocityCoder.java,v $
 * Revision 1.1  2006/11/22 17:12:42  zpan
 * Moved from lib\velocity\altera\etc\dsp\velocity
 *
 */
package altera.etc.dsp.velocity;

import java.io.*;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Properties;

import org.apache.velocity.Template;
import org.apache.velocity.VelocityContext;
import org.apache.velocity.app.VelocityEngine;
import org.apache.velocity.exception.MethodInvocationException;
import org.apache.velocity.exception.ParseErrorException;
import org.apache.velocity.exception.ResourceNotFoundException;
import org.apache.velocity.runtime.exception.ReferenceException;
import org.apache.velocity.app.event.EventCartridge;
import org.apache.velocity.app.event.ReferenceInsertionEventHandler;
import org.apache.velocity.app.event.MethodExceptionEventHandler;
import org.apache.velocity.app.event.NullSetEventHandler;

import altera.ipbu.flowbase.license.eLicense;

public class VelocityCoder
{
	// The static Singleton instance
	private static VelocityCoder pInstance;
	
    private VelocityEngine engine;
    private VelocityContext ctx;

    public static VelocityCoder getInstance()
    {
    	if (pInstance == null)
    	{
    		pInstance = new VelocityCoder();
    	}
    	
    	return pInstance;
    }
    
    private VelocityCoder() {
        // prevent instantiation from other object
        engine = new VelocityEngine();
        ctx = new VelocityContext();
    }
    
    public void init() throws Exception {
        engine.init();
    }

    public void init(Properties props) throws Exception {
        engine.init(props);
    }

    public void init(String fileName) throws Exception {
        engine.init(fileName);
    }

    public void addProperty(String key, Object value) {
        engine.addProperty(key, value);
    }

    public void clearProperty(String key) {
        engine.clearProperty(key);
    }

    public Object getProperty(String key) {
        return engine.getProperty(key);
    }

    public void setProperty(String key, Object value) {
        engine.setProperty(key, value);
    }

    public void put(String key, Object value) {
        ctx.put(key, value);
    }

    public void evaluate(Writer writer, String logTag,
            Reader reader) throws IOException, MethodInvocationException,
            ParseErrorException, ResourceNotFoundException {
        engine.evaluate(ctx, writer, logTag, reader);
    }

    public void evaluate(Writer writer, String logTag,
            String inString) throws IOException, MethodInvocationException,
            ParseErrorException, ResourceNotFoundException {
        engine.evaluate(ctx, writer, logTag, inString);
    }

    public Template getTemplate(String name) throws Exception,
            ParseErrorException, ResourceNotFoundException {
        return engine.getTemplate(name);
    }

    public Template getTemplate(String name, String encoding)
            throws Exception, ParseErrorException, ResourceNotFoundException {
        return engine.getTemplate(name, encoding);
    }

    public boolean mergeTemplate(String name, Writer writer)
            throws Exception {
        return engine.mergeTemplate(name, ctx, writer);
    }

    public boolean mergeTemplate(String name, String encoding,
            Writer writer) throws Exception {
        return engine.mergeTemplate(name, encoding, ctx, writer);
    }
    
    public void setVariables(Hashtable hashtable) throws Exception
    {
    	Enumeration e = hashtable.keys();
    	while ( e.hasMoreElements()) 
    	{
    		Object key = e.nextElement();
    		ctx.put(key.toString(),hashtable.get(key));
    	}
    }

    /**
     * API to generate unencrypted file. It assumes that variables have been passed through ctx
     */
    private boolean generateFile(String templateName,
    		String outFilename) throws Exception,
    		ResourceNotFoundException,ParseErrorException,ReferenceException
    {
    	BufferedWriter writer = new BufferedWriter(new FileWriter(outFilename));
    	
    	@SuppressWarnings("unused") VelocityEventHandler hdl = new VelocityEventHandler(ctx);
        boolean result = engine.mergeTemplate(templateName, ctx, writer);
        
        writer.flush();
        writer.close();
        
        return result;
    }
    
    /**
     * API to encrypt Velocity generated file with Altcrypt encryption. The last parameter is only
     * for controlling devicefamily permisions. Refer altcrypt user guide for more information.
     * <br>
     * Example: generateEncryptedFile(templateName, FLOW_MANAGER().getProjectDirectory() + "/sample_fifo.vhd", 
      			(short)0x00bb, "CIC Compiler", "2006.12", (short)0x6af7, new String[]{"-f", "1080000", "-m", "-f", "0000000", "-w1",
      		"-m", "-f", "0006000", "-w2", "-m"});
     * <br>
     * @param templateName : String Velocity template file name
     * @param outFilename : String Output Filename
     * @param productId : short IP Product ID "0x00bb"
     * @param coreLabel : String IP Product Name "CIC Compiler"
     * @param release4Year2Month : String IP Product release date "2006.12"
     * @param vendor_id : short Vendor ID "0x6af7"
     * @param devicePerms : String array containing all supplied permissions on device families<br>e.g. new String[]{"-f", "1080000", "-m", "-f", "0000000", "-w1", "-m", "-f", "0006000", "-w2", "-m"};
     * @return error code < 1 or 1 for success
     */
    public boolean generateEncryptedFile(String templateName,
    		String outFilename, short productId, String coreLabel,
    		String release4Year2Month, short vendor_id, String[] devicePerms) throws Exception,
    		ResourceNotFoundException,ParseErrorException,ReferenceException
    {
    	StringWriter writer = new StringWriter();
    	
    	@SuppressWarnings("unused") VelocityEventHandler hdl = new VelocityEventHandler(ctx);
        boolean result = engine.mergeTemplate(templateName, ctx, writer);

        if(result && eLicense.createEncryptedFile(new String(writer.toString()), outFilename, 
    			productId, coreLabel, release4Year2Month, vendor_id, devicePerms) > 0)
        {
        	// Call to Altcrypt encryption failed
        	result = false;
        }
        
        return result;
    }

    public boolean generateEncryptedFile(String templateName,
    		String outFilename, short productId, String coreLabel) throws Exception,
    		ResourceNotFoundException,ParseErrorException,ReferenceException
    {
        String release4Year2Month = "2006.12"; // IP release date
        short vendor_id = (short)0x6af7; // Altera ID;
        String[] devicePerms = new String[]{"-f", "1080000", "-m", "-f", "0000000", "-w1", "-m", "-f", "0006000", "-w2", "-m"};
        
        return generateEncryptedFile(templateName, outFilename, productId, coreLabel, 
        		release4Year2Month, vendor_id, devicePerms);
    }

    public boolean generateEncryptedFile(Hashtable hashtable, String templateName,
    		String outFilename, short productId, String coreLabel,
    		String release4Year2Month, short vendor_id, String[] devicePerms) throws Exception,
    		ResourceNotFoundException,ParseErrorException,ReferenceException
    {
    	setVariables(hashtable);
        return generateEncryptedFile(templateName, outFilename, productId, coreLabel, 
        		release4Year2Month, vendor_id, devicePerms);
    }

    public boolean generateFile(Hashtable hashtable,String templateName,
    		String outFilename) throws Exception,
    		ResourceNotFoundException,ParseErrorException,ReferenceException
    {
    	setVariables(hashtable);
    	return generateFile(templateName, outFilename);
    }

    /**
     * API to generate encrypted file with Altcrypt encryption
     */
    public boolean generateEncryptedFile(Hashtable hashtable,String templateName,
    		String outFilename, short productId, String coreLabel) throws Exception,
    		ResourceNotFoundException,ParseErrorException,ReferenceException
    {
    	setVariables(hashtable);
    	return generateEncryptedFile(templateName, outFilename, productId, coreLabel);
    }
}

/**
 * A class to handle bad references and methods
 * 
 * @author zpan
 *
 */
class VelocityEventHandler implements ReferenceInsertionEventHandler,
                             NullSetEventHandler,
                             MethodExceptionEventHandler
{

    public VelocityEventHandler(VelocityContext ctx) {
        EventCartridge ec = new EventCartridge();
        ec.addEventHandler(this);
        ec.attachToContext(ctx);
    }

    public Object referenceInsert(String reference, Object value) {
    	if (value == null)
    	{
			System.out.println("Invalid reference: " + reference);
    	}
    	
        return value;
    }

    public boolean shouldLogOnNullSet(String lhs, String rhs) {
        System.out.println("shouldLogOnNullSet");
        System.out.println("lhs:" + lhs + " rhs:" + rhs);

        if ("$validNull".equals(rhs.trim())) {
            return false;
        } else {
            return true;
        }
    }

    public Object methodException(Class cls, String method, Exception e)
            throws Exception {
        return "An " + e.getClass().getName() + " was thrown by the " + method
                + " method of the " + cls.getName() + " class ["
                + e.getMessage() + "]";
    }
}

