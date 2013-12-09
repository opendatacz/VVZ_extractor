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
    public String workingDir = "";

    @Override
    public boolean isValid() {

        return !dateFrom.isEmpty() && !dateTo.isEmpty() && !context.isEmpty() && !workingDir.isEmpty();
    }

}



















