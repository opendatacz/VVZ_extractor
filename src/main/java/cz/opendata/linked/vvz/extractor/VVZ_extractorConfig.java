package cz.opendata.linked.vvz.extractor;

import cz.cuni.mff.xrg.odcs.commons.configuration.DPUConfigObject;

/**
 *
 * Put your DPU's configuration here.
 *
 */
public class VVZ_extractorConfig implements DPUConfigObject {

    public String dateFrom= "";
    public String dateTo = "";
    public String context = "";

    @Override
    public boolean isValid() {

	    // no need to pass valid configuration. Invalid parameters only cause, that no public contracts will be found via soap api.
	    return true;
        //return !dateFrom.isEmpty() && !dateTo.isEmpty() && !context.isEmpty();
    }

}



















