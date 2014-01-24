package cz.opendata.linked.vvz;


import cz.opendata.linked.vvz.forms.PCReceiveException;
import cz.opendata.linked.vvz.forms.PCReceiver;
import cz.opendata.linked.vvz.forms.QueryParameters;
import cz.opendata.linked.vvz.utils.cache.Cache;

import cz.opendata.linked.vvz.utils.cache.CacheException;
import cz.opendata.linked.vvz.utils.journal.Journal;
import cz.opendata.linked.vvz.utils.journal.JournalException;
import cz.opendata.linked.vvz.utils.xslt.XML2RDF;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.*;
import java.text.SimpleDateFormat;

import java.util.List;


import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamSource;
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltExecutable;
import net.sf.saxon.s9api.XsltTransformer;
import org.w3c.dom.Document;


public class Main {


	private static Logger logger = LoggerFactory.getLogger(Main.class);

	public static void main(String[] args) {



		Cache cache = Cache.getInstance();
		cache.setLogger(logger);
		cache.setBasePath("/home/cammeron/Java-Workspace/VVZ_extractor");

		QueryParameters params = new QueryParameters();

		try {
			params.setDateFrom(new SimpleDateFormat("dd.MM.yyyy").parse("10.01.2014"));
			params.setDateTo(new SimpleDateFormat("dd.MM.yyyy").parse("10.01.2014"));
			Integer[] formTypes = {2, 3};
			params.setSelectedFormTypes(formTypes);
			params.setContext("second");
		} catch(Exception e) {
			logger.info("Error while setting query parameters. " + e.getMessage());
			System.exit(-1);
		}

		PCReceiver pcr = new PCReceiver();
		pcr.setLogger(logger);

		Journal journal = Journal.getInstance();

		if(!params.getContext().isEmpty()) {

			journal.setLogger(logger);

			try {
				journal.getConnection("VVZJournal/" + params.getContext());
			} catch(JournalException e) {
				logger.info("Could not get Journal connection. " + e.getMessage());
				System.exit(-1);
			}
		}

		try {
			File stylesheet = new File("/home/cammeron/Java-Workspace/VVZ_extractor/xslt","pc.xsl");
			XML2RDF xsl = new XML2RDF(stylesheet);
			xsl.setLogger(logger);
			//unpackXSLT();
		} catch(Exception e) {
			e.printStackTrace();
		}

		/*
		try {

			Integer parsed = 0, alreadyParsed = 0, cached = 0, alreadyCached = 0, failures=0;

			List<String> PCIds = pcr.loadPublicContractsList(params);
			logger.info(PCIds.size() + " public contracts is going to be downloaded and parsed");

			Document inputFile;

			File stylesheet = new File("/home/cammeron/Java-Workspace/VVZ_extractor/xslt","pc.xsl");
			XML2RDF xsl = new XML2RDF(stylesheet);


			xsl.setLogger(logger);

			for(String id : PCIds) {

				try {
					if(cache.isCached(id)) {
						logger.info(id + " file is already cached");
						inputFile = cache.getDocument(id);
						alreadyCached++;
					} else {
						logger.info(id + " file is going to be downloaded");
						inputFile = pcr.loadPublicContractForm(id);
						cache.storeDocument(inputFile,id);
						cached++;
					}


					if(journal.hasConnection()) {
						if(journal.getDocument(Integer.parseInt(id)) == null) {
							journal.insertDocument(Integer.parseInt(id));

							logger.info(id + " document is going to be parsed");
							parsed++;
						} else {
							logger.info(id + " document has been already parsed");
							alreadyParsed++;
						}
					} else {
						logger.info(id + " document is going to be parsed");
					}


					try {


						System.out.println(xsl.executeXSLT(inputFile));


					} catch (SaxonApiException e) {
						logger.info(e.getMessage());
					}



					break;
					// todo mohlo by to taky checknout verzi formulare

				} catch(CacheException | JournalException | PCReceiveException e) {
					logger.info(e.getMessage());
					failures++;
					break;
				}

			}

			logger.info("Downloading & parsing finished. \n" +
					"Failures: " + failures + "\n" +
					"Downloaded: " + cached + "\n" +
					"Already cached: " + alreadyCached + "\n" +
					"Parsed: " + parsed + "\n" +
					"Already parsed: " + alreadyParsed + "");

			journal.close();

		} catch (PCReceiveException | JournalException e) {
			logger.info(e.getMessage());
			System.exit(-1);
		} catch(Exception e) {
			logger.info(e.getMessage());
			System.exit(-1);
		}
		*/

	}

	/*
	public static void unpackXSLT() {

		new File("temp","xslt").mkdirs();
		File xsltFile = new File("temp/xslt/", "pc.xsl");

		try {
			xsltFile.createNewFile();

			InputStream input = getClass().getResourceAsStream("/xslt/pc.xsl");
			FileOutputStream out = new FileOutputStream(xsltFile);

			byte[] buffer = new byte[1024];
			int len;
			while ((len = input.read(buffer)) != -1) {
				out.write(buffer, 0, len);
			}

			//out.write(IOUtils.readFully(input, -1, false));

		} catch(Exception e) {
			e.printStackTrace();
		}
		this.logger.info("input stream loading");

	}
	*/

}
