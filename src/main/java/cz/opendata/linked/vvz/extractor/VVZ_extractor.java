package cz.opendata.linked.vvz.extractor;

import cz.cuni.mff.xrg.odcs.commons.data.DataUnitException;
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
import cz.opendata.linked.vvz.utils.journal.Journal;
import cz.opendata.linked.vvz.utils.journal.JournalException;

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

	private DPUContext context;

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

	    this.context = context;


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
		    if(!config.context.isEmpty()) {
			    params.setContext(config.context);
		    }

		    Integer[] formTypes = {2,3};
		    params.setSelectedFormTypes(formTypes);

	    } catch(Exception e) {
		    throw new DPUException("Error while setting query parameters.", e);
	    }

	    PCReceiver pcr = new PCReceiver();
	    pcr.setLogger(this.logger);

	    Journal journal = Journal.getInstance();

	    if(!params.getContext().isEmpty()) {
		    journal.setLogger(this.logger);

		    try {
				journal.getConnection(context.getGlobalDirectory() + File.separator + "Journal" + File.separator + config.context);

		    } catch(JournalException e) {
			    throw new DPUException("Could not get Journal connection.", e);
		    }
	    }

	    try {

		    Integer parsed = 0, alreadyParsed = 0, cached = 0, alreadyCached = 0, failures=0;

		    List<String> PCIds = pcr.loadPublicContractsList(params);
		    this.logger.info(PCIds.size() + " public contracts is going to be downloaded");

		    File inputFile;
		    Document pcDoc;
		    Boolean parse = false;
		    DirectoryHandler outputRoot = filesOutput.getRootDir();

		    for(String id : PCIds) {

			    try {
				    if(cache.isCached(id)) {
					    this.logger.info(id + " file is already cached");
					    inputFile = cache.getFile(id);
					    alreadyCached++;
				    } else {
					    this.logger.info(id + " file is going to be downloaded");
					    pcDoc = pcr.loadPublicContractForm(id);
					    inputFile = cache.storeDocument(pcDoc,id);
					    cached++;
				    }

				    if(journal.hasConnection()) {
					    if(journal.getDocument(Integer.parseInt(id)) == null) {
						    journal.insertDocument(Integer.parseInt(id));

						    this.logger.info(id + " document is going to be parsed");
						    parse = true;
					    } else {
						    this.logger.info(id + " document has been already parsed");
						    alreadyParsed++;
						    parse = false;
					    }
				    } else {
					    this.logger.info(id + " document is going to be parsed");
					    parse = true;
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

			    } catch(CacheException | JournalException | PCReceiveException e) {
				    this.logger.error(e.getMessage());
				    failures++;
				    break;
			    }

		    }

		    this.logger.info(
				    "Downloading & parsing finished. \n" +
				    "Failures: " + failures + "\n" +
				    "Downloaded: " + cached + "\n" +
				    "Already cached: " + alreadyCached + "\n" +
				    "Going to be parsed: " + parsed + "\n" +
				    "Already parsed: " + alreadyParsed
		    );

		    journal.close();

		} catch (PCReceiveException e) {
			throw new DPUException(e);
		} catch (JournalException e) {
			throw new DPUException(e);
		} catch (Exception e) {
		    throw new DPUException(e);
	    }


    }

}
