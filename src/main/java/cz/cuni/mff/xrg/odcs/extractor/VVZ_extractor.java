package cz.cuni.mff.xrg.odcs.extractor;

import cz.cuni.mff.xrg.odcs.commons.data.DataUnitException;
import cz.cuni.mff.xrg.odcs.commons.dpu.DPU;
import cz.cuni.mff.xrg.odcs.commons.dpu.DPUContext;
import cz.cuni.mff.xrg.odcs.commons.dpu.DPUException;
import cz.cuni.mff.xrg.odcs.commons.dpu.annotation.*;
import cz.cuni.mff.xrg.odcs.commons.module.dpu.ConfigurableBase;
import cz.cuni.mff.xrg.odcs.commons.web.AbstractConfigDialog;
import cz.cuni.mff.xrg.odcs.commons.web.ConfigDialogProvider;
import cz.cuni.mff.xrg.odcs.rdf.exceptions.RDFException;
import cz.cuni.mff.xrg.odcs.rdf.interfaces.RDFDataUnit;


import java.io.File;
import java.io.IOException;
import java.net.URISyntaxException;


@AsExtractor
public class VVZ_extractor extends ConfigurableBase<VVZ_extractorConfig>
        implements DPU, ConfigDialogProvider<VVZ_extractorConfig> {

    @OutputDataUnit
    public RDFDataUnit rdfOutput;

    public VVZ_extractor() {
        super(VVZ_extractorConfig.class);
    }

    @Override
    public AbstractConfigDialog<VVZ_extractorConfig> getConfigurationDialog() {
        return new VVZ_extractorDialog();
    }

    @Override
    public void execute(DPUContext context) throws DPUException, DataUnitException {


    }

    @Override
    public void cleanUp() {	}

}
