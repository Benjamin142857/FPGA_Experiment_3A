/*
 * MVCRadioButton.java
 *
 * Created on 15 July 2003, 18:04
 */

package altera.ipbu.mvcgui;

import javax.swing.*;
import altera.ipbu.flowbase.netlist.model.*;
import altera.ipbu.flowbase.netlist.*;
import altera.ipbu.flowbase.exceptions.*;
import java.awt.event.*;
import java.awt.*;
import java.net.URL;
import java.beans.*;

/**
 *
 * @author  jlangley
 */
public class MVCRadioButton extends JRadioButton implements IPTBView, ActionListener, BeanInfo
{
	private String m_strTriggerValue;
	private String m_strPrivate;
	private ModelBaseClass m_objModel;
	private Image m_Image = null;
	
	/** Creates a new instance of MVCRadioButton */
	public MVCRadioButton()
	{
		addActionListener(this);
	}
	
	public MVCRadioButton(String strText)
	{
		super(strText);
		addActionListener(this);
	}
	
	public void modelUpdated(ModelBaseClass model)
	{
		try
		{
			NetlistPrivate objPrivate = model.getPrivate(m_strPrivate);
			String strValue = objPrivate.getValue();
			if (strValue != null && strValue.equals(m_strTriggerValue))
				setSelected(true);
			else
				setSelected(false);
			setEnabled(objPrivate.isEnabled());
		}
		catch (EntryNotFoundException e)
		{
			//Should do some logging here.
		}
	}
	
	/** Sets the trigger value that means that this radiobutton will be selected.
	 *  If the private that this radio button is watching has this value, then
	 *  the button will be selected, otherwise the button will be unselected.
	 *  @param strTriggerValue the trigger value.
	 */
	public void setTriggerValue(String strTriggerValue)
	{
		m_strTriggerValue = strTriggerValue;
		modelUpdated(m_objModel);
	}
	
	/** Invoked when an action occurs.
	 *
	 */
	public void actionPerformed(ActionEvent e)
	{
		if (m_objModel == null)
			return;
		if (isSelected())
		{
			try
			{
				NetlistPrivate objPrivate = m_objModel.getPrivate(m_strPrivate);
				//If the private already has the right value, make sure that we're selected.
				if (objPrivate.getValue().equals(m_strTriggerValue))
					setSelected(true);
				if (objPrivate instanceof WriteablePropertyInterface)
					((WriteablePropertyInterface)objPrivate).setValue(m_strTriggerValue);
			}
			catch (EntryNotFoundException evt)
			{
				//Should do some logging here.
			}
			catch (OutOfRangeException evt)
			{
				//Should also do some logging here.  Can't really display error message
				//as for some components as we can't easily reset the value in a group
				//of radio buttons.
			}
		}
		else
		{
			try
			{
				NetlistPrivate objPrivate = m_objModel.getPrivate(m_strPrivate);
				//If the private already has the right value, make sure that we're selected.
				if (objPrivate.getValue().equals(m_strTriggerValue))
					setSelected(true);
			}
			catch (EntryNotFoundException evt)
			{
				//Should do some logging here.
			}
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
			URL objURL = this.getClass().getResource("icons/radiobutton.gif");
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
