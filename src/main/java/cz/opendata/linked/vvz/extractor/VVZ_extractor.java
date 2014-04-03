package cz.opendata.linked.vvz.extractor;

import cz.cuni.mff.xrg.odcs.commons.dpu.DPU;
import cz.cuni.mff.xrg.odcs.commons.dpu.DPUContext;
import cz.cuni.mff.xrg.odcs.commons.dpu.DPUException;
import cz.cuni.mff.xrg.odcs.commons.dpu.annotation.*;
import cz.cuni.mff.xrg.odcs.commons.module.dpu.ConfigurableBase;
import cz.cuni.mff.xrg.odcs.commons.web.AbstractConfigDialog;
import cz.cuni.mff.xrg.odcs.commons.web.ConfigDialogProvider;
import cz.cuni.mff.xrg.odcs.dataunit.file.FileDataUnit;
import cz.cuni.mff.xrg.odcs.dataunit.file.handlers.DirectoryHandler;
import cz.cuni.mff.xrg.odcs.dataunit.file.options.OptionsAdd;

import cz.opendata.linked.vvz.forms.PCReceiveException;
import cz.opendata.linked.vvz.forms.PCReceiver;
import cz.opendata.linked.vvz.forms.QueryParameters;
import cz.opendata.linked.vvz.utils.cache.Cache;
import cz.opendata.linked.vvz.utils.cache.CacheException;

import org.w3c.dom.Document;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


@AsExtractor
public class VVZ_extractor extends ConfigurableBase<VVZ_extractorConfig>
        implements DPU, ConfigDialogProvider<VVZ_extractorConfig> {

	private final Logger logger = LoggerFactory.getLogger(VVZ_extractor.class);

	@OutputDataUnit(name="downloadedFiles",description="It contains public contracts XML files.")
    public FileDataUnit filesOutput;

    public VVZ_extractor() {
        super(VVZ_extractorConfig.class);
    }

    @Override
    public AbstractConfigDialog<VVZ_extractorConfig> getConfigurationDialog() {
        return new VVZ_extractorDialog();
    }

    @Override
    public void execute(DPUContext context) throws DPUException {

	    Cache cache = Cache.getInstance();
	    cache.setLogger(this.logger);
	    cache.setBasePath(context.getGlobalDirectory().toString());

	    QueryParameters params = new QueryParameters();

	    try {
		    if(!config.dateFrom.isEmpty()) {
			    params.setDateFrom(new SimpleDateFormat("dd.MM.yyyy").parse(config.dateFrom));
		    }
		    if(!config.dateTo.isEmpty()) {
			    params.setDateTo(new SimpleDateFormat("dd.MM.yyyy").parse(config.dateTo));
		    }

		    Integer[] formTypes = {2,3};
		    params.setSelectedFormTypes(formTypes);

	    } catch(Exception e) {
		    throw new DPUException("Error while setting query parameters.", e);
	    }

	    PCReceiver pcr = new PCReceiver();
	    pcr.setLogger(this.logger);

	    try {

		    Integer parsed=0, downloaded = 0, alreadyCached = 0, failures=0;

		    List<String> PCIds = pcr.loadPublicContractsList(params);
		    this.logger.info(PCIds.size() + " public contracts is going to be downloaded");

		    File inputFile;
		    Document pcDoc;
		    Boolean parse;
		    DirectoryHandler outputRoot = filesOutput.getRootDir();

		    for(String id : PCIds) {

			    parse=false;
			    inputFile=null;

			    try {
				    if(cache.isCached(id)) {
					    this.logger.info(id + " file is already cached");
					    alreadyCached++;

					    if(!config.onlyGain) {
						    inputFile = cache.getFile(id);
							parse = true;
					    }
				    } else {
					    this.logger.info(id + " file is going to be downloaded");
					    pcDoc = pcr.loadPublicContractForm(id);
					    inputFile = cache.storeDocument(pcDoc,id);
					    downloaded++;
					    parse=true;
				    }

				    try {
					    if(parse) { // is XML document going to be parsed?

						    // return xml File
							outputRoot.addExistingFile(inputFile, new OptionsAdd(false,true));

						    parsed++;
					    }

				    } catch(Exception e) {
					    this.logger.error(e.getMessage());
				    }

			    } catch(CacheException | PCReceiveException e) {
				    this.logger.error(e.getMessage());
				    failures++;
				    break;
			    }
		    }

		    this.logger.info(
				    "Downloading & parsing finished. \n" +
				    "Failures: " + failures + "\n" +
				    "Downloaded: " + downloaded + "\n" +
				    "Already cached: " + alreadyCached + "\n" +
				    "Going to be parsed: " + parsed + "\n"
		    );

		} catch (PCReceiveException e) {
			throw new DPUException(e);
		}


    }

}
