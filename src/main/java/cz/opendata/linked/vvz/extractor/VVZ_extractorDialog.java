package cz.opendata.linked.vvz.extractor;

import cz.cuni.mff.xrg.odcs.commons.configuration.*;
import cz.cuni.mff.xrg.odcs.commons.module.dialog.BaseConfigDialog;
import com.vaadin.ui.*;

/**
 * DPU's configuration dialog. User can use this dialog to configure DPU configuration.
 *
 */
public class VVZ_extractorDialog extends BaseConfigDialog<VVZ_extractorConfig> {

    private GridLayout mainLayout;

    private TextField input_dateFrom;
    private TextField input_dateTo;
    private CheckBox input_gain;

    public VVZ_extractorDialog() {
        super(VVZ_extractorConfig.class);
        buildMainLayout();
        setCompositionRoot(mainLayout);
    }


	@Override
	public void setConfiguration(VVZ_extractorConfig conf) throws ConfigException {
		input_dateFrom.setValue(conf.dateFrom);
        input_dateTo.setValue(conf.dateTo);
        input_gain.setValue(conf.onlyGain);
	}

	@Override
	public VVZ_extractorConfig getConfiguration() throws ConfigException {


        VVZ_extractorConfig conf = new VVZ_extractorConfig();
        conf.dateFrom = input_dateFrom.getValue().trim();
        conf.dateTo = input_dateTo.getValue().trim();
        conf.onlyGain = input_gain.getValue();

        return conf;
	}

    /**
     * Builds main layout
     *
     * @return mainLayout GridLayout with all components of configuration
     *         dialog.
     */
    private GridLayout buildMainLayout() {

        // common part: create layout
        mainLayout = new GridLayout(1,4);
        mainLayout.setImmediate(false);
        mainLayout.setWidth("100%");
        mainLayout.setHeight("100%");
        mainLayout.setMargin(false);
        //mainLayout.setSpacing(true);

        // top-level component properties
        setWidth("100%");
        setHeight("100%");
        
        // text field for date from
        input_dateFrom = new TextField();
        input_dateFrom.setNullRepresentation("");
        input_dateFrom.setCaption("Date From (DD.MM.YYYY):");
        input_dateFrom.setImmediate(true);
        input_dateFrom.setWidth("100%");
        input_dateFrom.setHeight("-1px");
	    input_dateFrom.setDescription("Min publication date from which extractor process public contracts. If date from is not present, extractor will process all public contracts to the past.");

        mainLayout.addComponent(input_dateFrom);

        // text field for date to
        input_dateTo = new TextField();
        input_dateTo.setNullRepresentation("");
        input_dateTo.setCaption("Date To (DD.MM.YYYY):");
        input_dateTo.setImmediate(true);
        input_dateTo.setWidth("100%");
        input_dateTo.setHeight("-1px");
	    input_dateTo.setDescription("Max publication date in which extractor process public contracts. If date to is not present, extractor will process all public contracts to the future.");

        mainLayout.addComponent(input_dateTo);

        // text field for onlyGain
        input_gain = new CheckBox();
        input_gain.setCaption("Process gain only:");
        input_gain.setWidth("100%");
	    input_gain.setDescription(".");

        mainLayout.addComponent(input_gain);

        return mainLayout;
    }

	
}
