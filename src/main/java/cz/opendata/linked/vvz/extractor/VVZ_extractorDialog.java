package cz.opendata.linked.vvz.extractor;

import cz.cuni.mff.xrg.odcs.commons.configuration.*;
import cz.cuni.mff.xrg.odcs.commons.module.dialog.BaseConfigDialog;

import com.vaadin.data.Property;
import com.vaadin.data.Validator.EmptyValueException;
import com.vaadin.data.Validator.InvalidValueException;
import com.vaadin.data.Validator;
import com.vaadin.ui.*;

/**
 * DPU's configuration dialog. User can use this dialog to configure DPU configuration.
 *
 */
public class VVZ_extractorDialog extends BaseConfigDialog<VVZ_extractorConfig> {

    private GridLayout mainLayout;

    private TextField input_dateFrom;
    private TextField input_dateTo;
    private TextField input_workingDir;
    private TextField input_context;

    private boolean formValid = false;

    public VVZ_extractorDialog() {
        super(VVZ_extractorConfig.class);
        buildMainLayout();
        setCompositionRoot(mainLayout);
    }


	@Override
	public void setConfiguration(VVZ_extractorConfig conf) throws ConfigException {
		input_dateFrom.setValue(conf.dateFrom);
        input_dateTo.setValue(conf.dateTo);
        input_workingDir.setValue(conf.workingDir);
        input_context.setValue(conf.context);
	}

	@Override
	public VVZ_extractorConfig getConfiguration() throws ConfigException {

        if (!input_workingDir.isValid()) {
            InvalidValueException ex = new EmptyValueException("Working dir path must be filled!");
            throw new ConfigException(ex.getMessage(), ex);
        } else if (!formValid) {
            throw new InvalidValueException("Working dir path must be filled!");
        } else {

            VVZ_extractorConfig conf = new VVZ_extractorConfig();
            conf.dateFrom = input_dateFrom.getValue().trim();
            conf.dateTo = input_dateTo.getValue().trim();
            conf.context = input_context.getValue().trim();
            conf.workingDir = input_workingDir.getValue().trim();

            return conf;
        }

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
        input_dateFrom.setCaption("Date From (MM/DD/YYYY):");
        input_dateFrom.setImmediate(true);
        input_dateFrom.setWidth("100%");
        input_dateFrom.setHeight("-1px");


        mainLayout.addComponent(input_dateFrom);

        // text field for date to
        input_dateTo = new TextField();
        input_dateTo.setNullRepresentation("");
        input_dateTo.setCaption("Date To (MM/DD/YYYY):");
        input_dateTo.setImmediate(true);
        input_dateTo.setWidth("100%");
        input_dateTo.setHeight("-1px");

        mainLayout.addComponent(input_dateTo);

        // text field for date to
        input_context = new TextField();
        input_context.setNullRepresentation("");
        input_context.setCaption("Context string:");
        input_context.setImmediate(true);
        input_context.setWidth("100%");
        input_context.setHeight("-1px");

        mainLayout.addComponent(input_context);

        // text field for date to
        input_workingDir = new TextField();
        input_workingDir.setNullRepresentation("");
        input_workingDir.setCaption("Working dir path:");
        input_workingDir.setImmediate(true);
        input_workingDir.setWidth("100%");
        input_workingDir.setHeight("-1px");

        mainLayout.addComponent(input_workingDir);

        input_workingDir.addValueChangeListener(new Property.ValueChangeListener() {
            @Override
            public void valueChange(Property.ValueChangeEvent event) {
                final String workingDir = input_workingDir.getValue().trim();

                if (workingDir.isEmpty()) {

                    formValid = false;

                } else {
                    formValid = true;
                }
            }
        });

        input_workingDir.addValidator(new Validator() {
            @Override
            public void validate(Object value) throws Validator.InvalidValueException {
                if (value.getClass() == String.class && !((String) value).isEmpty()) {
                    return;
                }
                throw new Validator.InvalidValueException("Working dir path must be filled!");
            }

        });

        return mainLayout;
    }

	
}
