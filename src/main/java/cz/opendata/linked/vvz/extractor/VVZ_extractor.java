package cz.opendata.linked.vvz.extractor;

import cz.cuni.mff.xrg.odcs.commons.data.DataUnitException;
import cz.cuni.mff.xrg.odcs.commons.dpu.DPU;
import cz.cuni.mff.xrg.odcs.commons.dpu.DPUContext;
import cz.cuni.mff.xrg.odcs.commons.dpu.DPUException;
import cz.cuni.mff.xrg.odcs.commons.dpu.annotation.*;
import cz.cuni.mff.xrg.odcs.commons.module.dpu.ConfigurableBase;
import cz.cuni.mff.xrg.odcs.commons.web.AbstractConfigDialog;
import cz.cuni.mff.xrg.odcs.commons.web.ConfigDialogProvider;
import cz.cuni.mff.xrg.odcs.rdf.interfaces.RDFDataUnit;
import cz.cuni.mff.xrg.odcs.commons.module.utils.DataUnitUtils;

import cz.cuni.mff.xrg.odcs.commons.message.MessageType;
import cz.opendata.linked.vvz.forms.PCReceiveException;
import cz.opendata.linked.vvz.forms.PCReceiver;
import cz.opendata.linked.vvz.forms.QueryParameters;
import cz.opendata.linked.vvz.utils.cache.Cache;
import cz.opendata.linked.vvz.utils.cache.CacheException;
import cz.opendata.linked.vvz.utils.journal.Journal;
import cz.opendata.linked.vvz.utils.journal.JournalException;
import cz.opendata.linked.vvz.utils.xslt.XML2RDF;
import org.w3c.dom.Document;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


@AsExtractor
public class VVZ_extractor extends ConfigurableBase<VVZ_extractorConfig>
        implements DPU, ConfigDialogProvider<VVZ_extractorConfig> {

	private final Logger logger = LoggerFactory.getLogger(VVZ_extractor.class);

	private DPUContext context;

	@OutputDataUnit(description="It contains RDF triples with public contracts, contracting authorities and suppliers according to Public Contracts Ontology.")
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

	    this.context = context;

	    //get working dir
	    File workingDir = context.getWorkingDir();
	    workingDir.mkdirs();


	    String pathToWorkingDir = null;
	    try {
		    pathToWorkingDir = workingDir.getCanonicalPath();
	    } catch (IOException e) {
		    logger.error("Cannot get path to working dir");
		    logger.debug(e.getLocalizedMessage());
		    context.sendMessage(MessageType.ERROR, "Cannot get path to working dir "+ e.getLocalizedMessage());
	    }

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
		    this.logger.info(PCIds.size() + " public contracts is going to be downloaded and parsed");

		    Document inputFile;
		    Boolean parse = false;

		    XML2RDF xsl;

		    try {
			    this.unpackXSLT("pc.xsl");
			    this.unpackXSLT("uuid.xslt");
			    this.unpackXSLT("functions.xsl");

			    File stylesheet = new File(context.getGlobalDirectory() + File.separator + "xslt","pc.xsl");

			    xsl = new XML2RDF(stylesheet);
			    xsl.setLogger(this.logger);
		    } catch(IOException e) {
				throw new DPUException("Could not get pc.xslt");
		    }

		    for(String id : PCIds) {

			    try {
				    if(cache.isCached(id)) {
					    this.logger.info(id + " file is already cached");
					    inputFile = cache.getDocument(id);
					    alreadyCached++;
				    } else {
					    this.logger.info(id + " file is going to be downloaded");
					    inputFile = pcr.loadPublicContractForm(id);
					    cache.storeDocument(inputFile,id);
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
					    if(parse) {
					        String output = xsl.executeXSLT(inputFile);

						    String outputPath = pathToWorkingDir + File.separator + "out"  + File.separator + String.valueOf(id) + ".rdf";
						    DataUnitUtils.checkExistanceOfDir(pathToWorkingDir + File.separator + "out" + File.separator);
						    DataUnitUtils.storeStringToTempFile(output, outputPath);

						    rdfOutput.addFromRDFXMLFile(new File(outputPath));
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
				    "Parsed: " + parsed + "\n" +
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

	public void unpackXSLT(String stylesheet) {

		File xsltDir = new File(this.context.getGlobalDirectory(),"xslt");
		File xsltFile = new File(xsltDir, stylesheet);

		if(!xsltFile.exists()) {

			this.logger.debug("Unpacking XSLT " + stylesheet + " to global directory");

			try {

				xsltDir.mkdirs();

				xsltFile.createNewFile();

				InputStream input = getClass().getResourceAsStream("/xslt/" + stylesheet);
				FileOutputStream out = new FileOutputStream(xsltFile);

				byte[] buffer = new byte[1024];
				int len;
				while ((len = input.read(buffer)) != -1) {
					out.write(buffer, 0, len);
				}

				this.logger.debug("XSLT " + stylesheet + " has been stored in global working dir successfully.");

			} catch(IOException e) {

			}

		} else {
			this.logger.debug("XSLT " + stylesheet + " is already stored in global working dir.");
		}

	}

    @Override
    public void cleanUp() {


    }

}
