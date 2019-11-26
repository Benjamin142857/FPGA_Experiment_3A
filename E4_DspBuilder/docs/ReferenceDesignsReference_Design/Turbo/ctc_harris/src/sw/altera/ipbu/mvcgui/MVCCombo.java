/*
 * MVCCombo.java
 *
 * Created on 28 May 2003, 14:29
 */

package altera.ipbu.mvcgui;

import javax.swing.*;
import altera.ipbu.flowbase.netlist.model.*;
import altera.ipbu.flowbase.netlist.*;
import altera.ipbu.flowbase.exceptions.*;
import java.util.Enumeration;
import java.util.ArrayList;
import java.awt.event.*;
import java.awt.*;
import java.net.URL;
import java.beans.*;

/**
 *
 * @author  jlangley
 */
public class MVCCombo extends JComboBox implements IPTBView, ActionListener, BeanInfo
{
	private ModelBaseClass m_objModel;
	private String m_strPrivate;
	private boolean m_booUpdating = false;
	private Image m_Image = null;
    private java.util.List<JLabel> labelList;

    /** Creates a new instance of MVCCombo */
	public MVCCombo()
	{
		addActionListener(this);
	}
	
	public void modelUpdated(ModelBaseClass model)
	{
		m_booUpdating = true;
		removeAllItems();
		NetlistPrivate objPrivate = null;
		try
		{
			objPrivate = model.getPrivate(m_strPrivate);
		}
		catch (EntryNotFoundException e)
		{
			//Should probably do some logging here.
			return;
		}
		if (objPrivate.hasRange())
		{
			Range objRange = objPrivate.getRange();
			Enumeration e = objRange.elements();
			while (e.hasMoreElements())
				addItem(e.nextElement());
			selectItem(objPrivate.getValue());
		}
		else
			addItem(objPrivate.getValue());
		setEnabled(objPrivate.isEnabled());
		m_booUpdating = false;
	}
	
	public void actionPerformed(ActionEvent e)
	{
		if (m_objModel == null)
			return;
		if (m_booUpdating)
			return;
		try
		{
			NetlistPrivate objPrivate = m_objModel.getPrivate(m_strPrivate);
			if (objPrivate instanceof WriteablePropertyInterface)
				((WriteablePropertyInterface)objPrivate).setValue(getSelectedItem().toString());
		}
		catch (EntryNotFoundException evt)
		{ /*Again should do some logging here*/}
		catch (OutOfRangeException evt)
		{
			JOptionPane.showMessageDialog(null, evt.getMessage());
			modelUpdated(m_objModel);
		}
		catch (IllegalArgumentException evt)
		{
			//Shouldn't really happen as all the displayed values should be in range
			JOptionPane.showMessageDialog(null, evt.getMessage());
			modelUpdated(m_objModel);
		}
	}
	
	private void selectItem(Object objItem)
	{
		int i;
		for (i = getItemCount() - 1; i >= 0; i--)
		{
			if (objItem.toString().equalsIgnoreCase(getItemAt(i).toString()))
				break;
		}
		setSelectedIndex(i);

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
			URL objURL = this.getClass().getResource("icons/combobox.gif");
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
    public void addAssociatedLabel(JLabel label)
    {
        if (labelList == null)
        {
            labelList = new ArrayList<JLabel>();
        }
        labelList.add(label);
    }

    public void setEnabled(boolean enabled)
    {
        super.setEnabled(enabled);
        if (labelList != null)
        {
            for (JLabel label : labelList)
            {
                label.setEnabled(enabled);
            }
        }
    }
}
