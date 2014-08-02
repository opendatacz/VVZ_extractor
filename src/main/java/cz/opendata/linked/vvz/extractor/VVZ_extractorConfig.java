package cz.opendata.linked.vvz.extractor;

import cz.cuni.mff.xrg.odcs.commons.module.config.DPUConfigObjectBase;

/**
 *
 * Put your DPU's configuration here.
 *
 */
public class VVZ_extractorConfig extends DPUConfigObjectBase {

    public String dateFrom;
    public String dateTo;
	public String GUID;
    public Boolean onlyGain;

	public VVZ_extractorConfig() {
		this.dateFrom= "";
		this.dateTo = "";
		this.onlyGain = true;
		this.GUID = "";

	}

	public VVZ_extractorConfig(String dateFrom, String dateTo, Boolean onlyGain, String GUID) {
		this.dateFrom = dateFrom;
		this.dateTo = dateTo;
		this.onlyGain = onlyGain;
		this.GUID = GUID;
	}

    @Override
    public boolean isValid() {

	    // no need to pass valid configuration. Invalid parameters only cause, that no public contracts will be found via soap api.
	    return true;
        //return !dateFrom.isEmpty() && !dateTo.isEmpty() && !context.isEmpty();
    }

}



















