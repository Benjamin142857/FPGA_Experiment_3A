/*
 * MVCTextField.java
 *
 * Created on 03 June 2003, 16:58
 */

package altera.ipbu.mvcgui;

import altera.ipbu.flowbase.exceptions.EntryNotFoundException;
import altera.ipbu.flowbase.exceptions.OutOfRangeException;
import altera.ipbu.flowbase.netlist.NetlistPrivate;
import altera.ipbu.flowbase.netlist.model.IPTBView;
import altera.ipbu.flowbase.netlist.model.ModelBaseClass;
import altera.ipbu.flowbase.netlist.model.WriteablePropertyInterface;

import javax.swing.*;
import java.awt.Image;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.FocusEvent;
import java.awt.event.FocusListener;
import java.beans.BeanInfo;
import java.net.URL;
import java.util.ArrayList;

/**
 *
 * @author  jlangley
 */
public class MVCTextField extends JTextField implements IPTBView, ActionListener, FocusListener, BeanInfo
{
    private ModelBaseClass m_objModel;
    private String m_strPrivate;
    private Image m_Image = null;
    private java.util.List<JLabel> labelList;

    /** Creates a new instance of MVCTextField */
    public MVCTextField()
    {
        this("");
    }

    public MVCTextField(int columns)
    {
        this("", columns);
    }

    public MVCTextField(String strText)
    {
        this(strText, 10);
    }

    public MVCTextField(String strText, int columns)
    {
        super(strText, columns);
        addActionListener(this);
        addFocusListener(this);
    }

    public void modelUpdated(ModelBaseClass model)
    {
        try
        {
            NetlistPrivate objPrivate = m_objModel.getPrivate(m_strPrivate);
            if (objPrivate.isEnabled())
                setEnabled(true);
            else
                setEnabled(false);
            setText(objPrivate.getValue());
        }
        catch (EntryNotFoundException ex)
        {
            //Should do some logging here.
        }
    }

    /** Invoked when an action occurs.
     *
     */
    public void actionPerformed(ActionEvent e)
    {
        setPrivateValue();
    }

    private void setPrivateValue()
    {
        if (m_objModel == null)
            return;
        try
        {
            NetlistPrivate objPrivate = m_objModel.getPrivate(m_strPrivate);
            if (objPrivate instanceof WriteablePropertyInterface)
                ((WriteablePropertyInterface)objPrivate).setValue(getText());
        }
        catch (EntryNotFoundException evt)
        {
            /*Again should do some logging here*/
            return;
        }
        catch (OutOfRangeException evt)
        {
            JOptionPane.showMessageDialog(null, evt.getMessage(), "Value is out of range", JOptionPane.WARNING_MESSAGE);
            modelUpdated(m_objModel);
        }
        catch (IllegalArgumentException evt)
        {
            JOptionPane.showMessageDialog(null, evt.getMessage(), "Illegal value", JOptionPane.WARNING_MESSAGE);
            modelUpdated(m_objModel);
        }
    }

    /** Invoked when a component gains the keyboard focus.
     *
     */
    public void focusGained(FocusEvent e)
    {
        //Not worried about focus gained, only when it's lost
    }

    /** Invoked when a component loses the keyboard focus.
     *
     */
    public void focusLost(FocusEvent e)
    {
        if (!e.isTemporary())
            setPrivateValue();
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
            URL objURL = this.getClass().getResource("icons/textfield.gif");
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
