package altera.ipbu.ctcumts.gui;

import altera.ipbu.ctcumts.CTCUMTSConstants;
import altera.ipbu.flowbase.SharedObjectsInterface;
import altera.ipbu.flowbase.controls.WPanel;
import altera.ipbu.flowbase.controls.WizardPanelInterface;
import altera.ipbu.flowbase.netlist.NetlistPrivateInterface;
import altera.ipbu.flowbase.netlist.model.CTCUMTSModel;
import altera.ipbu.mvcgui.*;

import javax.swing.*;
import java.awt.*;

import com.intellij.uiDesigner.core.GridLayoutManager;
import com.intellij.uiDesigner.core.GridConstraints;
import com.intellij.uiDesigner.core.Spacer;

/**
 * User: mjohnson
 * Date: 12-Jun-2006
 * Time: 10:55:33
 */
public class ArchitecturePanel extends WPanel implements WizardPanelInterface {
    private WPanel ArchitecturePanel;
    private MVCCombo device_family;
    private MVCCombo num_engines;
    private MVCCombo map_decoding;
    private MVCRadioButton encoder;
    private MVCRadioButton decoder;
    private MVCCombo num_of_input_bits;
    private MVCCombo num_of_output_bits;
    private JLabel rate_factor_label;

    public void setWizardPrivates(NetlistPrivateInterface netlistPrivateInterface) {
    }

    public boolean onFinish() {
        return true;
    }

    public void onCancel() {
    }

    public void onUpdate() {
    }

    public void onWizardPageKeyEvent(int i) {
    }

    public WPanel getPanel() {
        return this;
    }

    public String getName() {
        return "Architecture";
    }

    public void initialize() throws Exception {
        add(ArchitecturePanel, BorderLayout.CENTER);
    }

    public void uninitialize() throws Exception {
    }

    public Object getNextGenerationObject(String string) {
        return this;
    }

    public void setSharedObjects(SharedObjectsInterface sharedObjectsInterface) {
        CTCUMTSModel model = (CTCUMTSModel) sharedObjectsInterface.getModel();
        device_family.setModelAndWatch(model, CTCUMTSConstants.DEVICE_FAMILY_NAME);
        num_engines.setModelAndWatch(model, CTCUMTSConstants.NUM_OF_PROCESSORS_NAME);
        num_of_input_bits.setModelAndWatch(model, CTCUMTSConstants.NUM_OF_INPUT_BITS_NAME);
        num_of_output_bits.setModelAndWatch(model, CTCUMTSConstants.NUM_OF_OUTPUT_BITS_NAME);
        map_decoding.setModelAndWatch(model, CTCUMTSConstants.MAP_DECODING_NAME);
        encoder.setModelAndWatch(model, CTCUMTSConstants.CODEC_TYPE_TITLE);
        encoder.setTriggerValue("0");
        decoder.setModelAndWatch(model, CTCUMTSConstants.CODEC_TYPE_TITLE);
        decoder.setTriggerValue("1");
    }

    {
// GUI initializer generated by IntelliJ IDEA GUI Designer
// >>> IMPORTANT!! <<<
// DO NOT EDIT OR ADD ANY CODE HERE!
        $$$setupUI$$$();
    }

    /**
     * Method generated by IntelliJ IDEA GUI Designer
     * >>> IMPORTANT!! <<<
     * DO NOT edit this method OR call it in your code!
     *
     * @noinspection ALL
     */
    private void $$$setupUI$$$() {
        ArchitecturePanel = new WPanel();
        ArchitecturePanel.setLayout(new GridLayoutManager(6, 1, new Insets(10, 10, 10, 10), -1, -1));
        ArchitecturePanel.setBorder(BorderFactory.createTitledBorder(BorderFactory.createEtchedBorder(), null));
        final JPanel panel1 = new JPanel();
        panel1.setLayout(new GridLayoutManager(1, 3, new Insets(0, 10, 5, 10), -1, -1));
        ArchitecturePanel.add(panel1, new GridConstraints(0, 0, 1, 1, GridConstraints.ANCHOR_CENTER, GridConstraints.FILL_BOTH, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, null, null, null, 0, false));
        panel1.setBorder(BorderFactory.createTitledBorder(BorderFactory.createEtchedBorder(), "Device Family"));
        final JLabel label1 = new JLabel();
        label1.setText("Target:");
        panel1.add(label1, new GridConstraints(0, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_FIXED, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        device_family = new MVCCombo();
        panel1.add(device_family, new GridConstraints(0, 2, 1, 1, GridConstraints.ANCHOR_CENTER, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_FIXED, GridConstraints.SIZEPOLICY_FIXED, null, new Dimension(100, -1), null, 0, false));
        final Spacer spacer1 = new Spacer();
        panel1.add(spacer1, new GridConstraints(0, 1, 1, 1, GridConstraints.ANCHOR_CENTER, GridConstraints.FILL_HORIZONTAL, GridConstraints.SIZEPOLICY_WANT_GROW, 1, null, null, null, 0, false));
        final JPanel panel2 = new JPanel();
        panel2.setLayout(new GridLayoutManager(5, 3, new Insets(0, 10, 5, 10), -1, -1));
        ArchitecturePanel.add(panel2, new GridConstraints(1, 0, 1, 1, GridConstraints.ANCHOR_CENTER, GridConstraints.FILL_BOTH, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, null, null, null, 0, false));
        panel2.setBorder(BorderFactory.createTitledBorder(BorderFactory.createEtchedBorder(), "Turbo Specifications"));
        num_engines = new MVCCombo();
        panel2.add(num_engines, new GridConstraints(1, 2, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, null, new Dimension(100, -1), null, 0, false));
        final JLabel label2 = new JLabel();
        label2.setText("Codec type:");
        panel2.add(label2, new GridConstraints(0, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_FIXED, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        final JLabel label3 = new JLabel();
        label3.setText("Number of processors:");
        panel2.add(label3, new GridConstraints(1, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_FIXED, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        rate_factor_label = new JLabel();
        rate_factor_label.setText("MAP decoding:");
        panel2.add(rate_factor_label, new GridConstraints(2, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_FIXED, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        map_decoding = new MVCCombo();
        panel2.add(map_decoding, new GridConstraints(2, 2, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, null, new Dimension(100, -1), null, 0, false));
        encoder = new MVCRadioButton();
        encoder.setText("Encoder");
        panel2.add(encoder, new GridConstraints(0, 1, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        decoder = new MVCRadioButton();
        decoder.setText("Decoder");
        panel2.add(decoder, new GridConstraints(0, 2, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        final JLabel label4 = new JLabel();
        label4.setText("Number of input bits:");
        panel2.add(label4, new GridConstraints(3, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_FIXED, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        num_of_input_bits = new MVCCombo();
        panel2.add(num_of_input_bits, new GridConstraints(3, 2, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, null, new Dimension(100, -1), null, 0, false));
        final JLabel label5 = new JLabel();
        label5.setText("Number of output bits:");
        panel2.add(label5, new GridConstraints(4, 0, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_FIXED, GridConstraints.SIZEPOLICY_FIXED, null, null, null, 0, false));
        num_of_output_bits = new MVCCombo();
        panel2.add(num_of_output_bits, new GridConstraints(4, 2, 1, 1, GridConstraints.ANCHOR_WEST, GridConstraints.FILL_NONE, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, GridConstraints.SIZEPOLICY_CAN_SHRINK | GridConstraints.SIZEPOLICY_CAN_GROW, null, new Dimension(100, -1), null, 0, false));
        final Spacer spacer2 = new Spacer();
        ArchitecturePanel.add(spacer2, new GridConstraints(5, 0, 1, 1, GridConstraints.ANCHOR_CENTER, GridConstraints.FILL_VERTICAL, 1, GridConstraints.SIZEPOLICY_WANT_GROW, null, null, null, 0, false));
    }

    /**
     * @noinspection ALL
     */
    public JComponent $$$getRootComponent$$$() {
        return ArchitecturePanel;
    }
}