/*
 * MVCLabel.java
 *
 * Created on 11 December 2003, 11:26
 */

package altera.ipbu.mvcgui;

import javax.swing.*;
import altera.ipbu.flowbase.netlist.model.*;
import altera.ipbu.flowbase.netlist.*;
import altera.ipbu.flowbase.exceptions.*;
import java.awt.*;
import java.beans.*;
import java.net.URL;

/**
 *
 * @author  jlangley
 */
public class MVCLabel extends JLabel implements IPTBView, BeanInfo
{
	private ModelBaseClass m_objModel;
	private String m_strPrivate;
	private Image m_Image = null;
	
	/** Creates a new instance of MVCLabel */
	public MVCLabel()
	{
	}
	
	public void modelUpdated(ModelBaseClass model)
	{
		try
		{
			NetlistPrivate objPrivate = m_objModel.getPrivate(m_strPrivate);
			setText(objPrivate.getValue());
		}
		catch (EntryNotFoundException ex)
		{
			//Should do some logging here.
		}
	}
	
	public void setModelAndWatch(ModelBaseClass model, String strName)
	{
		if (m_objModel != null)
			m_objModel.removeModelListener(this);
		m_objModel = model;
		m_objModel.addModelListener(this);
		m_strPrivate = strName;
		modelUpdated(m_objModel);
	}
	
	public BeanInfo[] getAdditionalBeanInfo()
	{
		return null;
	}
	
	public java.beans.BeanDescriptor getBeanDescriptor()
	{
		return null;
	}
	
	public int getDefaultEventIndex()
	{
		return -1;
	}
	
	public int getDefaultPropertyIndex()
	{
		return -1;
	}
	
	public java.beans.EventSetDescriptor[] getEventSetDescriptors()
	{
		return null;
	}
	
	public java.awt.Image getIcon(int iconKind)
	{
		if (m_Image == null)
		{
			URL objURL = this.getClass().getResource("icons/label.gif");
			if (objURL == null)
				return null;
			ImageIcon icon = new ImageIcon(objURL);
			m_Image = icon.getImage();
		}
		return m_Image;
	}
	
	public java.beans.MethodDescriptor[] getMethodDescriptors()
	{
		return null;
	}
	
	public java.beans.PropertyDescriptor[] getPropertyDescriptors()
	{
		return null;
	}
}
