/*
 * MVCCheckBox.java
 *
 * Created on 03 June 2003, 14:24
 */

package altera.ipbu.mvcgui;

import altera.ipbu.flowbase.exceptions.EntryNotFoundException;
import altera.ipbu.flowbase.exceptions.OutOfRangeException;
import altera.ipbu.flowbase.netlist.NetlistPrivate;
import altera.ipbu.flowbase.netlist.NetlistBooleanPrivate;
import altera.ipbu.flowbase.netlist.model.IPTBView;
import altera.ipbu.flowbase.netlist.model.ModelBaseClass;
import altera.ipbu.flowbase.netlist.model.WriteablePropertyInterface;

import javax.swing.ImageIcon;
import javax.swing.JCheckBox;
import javax.swing.JOptionPane;
import java.awt.Image;
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;
import java.beans.BeanInfo;
import java.net.URL;

/**
 *
 * @author  jlangley
 */
public class MVCCheckBox extends JCheckBox implements IPTBView, ItemListener, BeanInfo
{
	private ModelBaseClass m_objModel;
	private String m_strPrivate;
	private Image m_Image = null;
	private boolean m_booInverted = false;
	private boolean m_booStateChangedFromCode = false;
	
	/** Creates a new instance of MVCCheckBox */
	public MVCCheckBox()
	{
		this ("");
	}
	
	public MVCCheckBox(String strTitle)
	{
		super (strTitle);
		addItemListener(this);
	}
	
	public void modelUpdated(ModelBaseClass model)
	{
		if (m_objModel == null)
			return;
		try
		{
			m_booStateChangedFromCode = true;
			NetlistBooleanPrivate objPrivate = (NetlistBooleanPrivate)m_objModel.getPrivate(m_strPrivate);
			if (m_booInverted)
      {
				//setSelected(!Boolean.valueOf(objPrivate.getValue()).booleanValue());
        setSelected(!objPrivate.getBooleanValue());
      }
			else
      {
				//setSelected(Boolean.valueOf(objPrivate.getValue()).booleanValue());
        setSelected(objPrivate.getBooleanValue());
      }
			m_booStateChangedFromCode = false;
			setEnabled(objPrivate.isEnabled());
		}
		catch (EntryNotFoundException ex)
		{
			//Should do some logging here.
		}
	}
	
	
	/** Invoked when an item has been selected or deselected by the user.
	 * The code written for this method performs the operations
	 * that need to occur when an item is selected (or deselected).
	 *
	 */
	public void itemStateChanged(ItemEvent e)
	{
		if (m_booStateChangedFromCode)
			return;
		if (m_objModel == null)
			return;
		try
		{
			NetlistPrivate objPrivate = m_objModel.getPrivate(m_strPrivate);
			if (objPrivate instanceof WriteablePropertyInterface)
      {
        if (m_booInverted)
        {
          if(isSelected())
          {
            ((WriteablePropertyInterface)objPrivate).setValue("0");
          }
          else
          {
            ((WriteablePropertyInterface)objPrivate).setValue("1");
          }
        }
        else
        {
          if(isSelected())
          {
            ((WriteablePropertyInterface)objPrivate).setValue("1");
          }
          else
          {
            ((WriteablePropertyInterface)objPrivate).setValue("0");
          }
        }

        /*
				if (m_booInverted)
					((WriteablePropertyInterface)objPrivate).setValue(Boolean.toString(!isSelected()));
				else
					((WriteablePropertyInterface)objPrivate).setValue(Boolean.toString(isSelected()));
        */
			}
		}
		catch (EntryNotFoundException ex)
		{
			//Should do some logging here.
		}
		catch (OutOfRangeException ex)
		{
			JOptionPane.showMessageDialog(null, ex.getMessage());
			modelUpdated(m_objModel);
		}
		catch (IllegalArgumentException evt)
		{
			//Shouldn't really happen since Boolean.toString should give legal values
			JOptionPane.showMessageDialog(null, evt.getMessage());
			modelUpdated(m_objModel);
		}
	}

	public void setInverted(boolean booInverted)
	{
		m_booInverted = booInverted;
		modelUpdated(m_objModel);
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
			URL objURL = this.getClass().getResource("icons/checkbox.gif");
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
