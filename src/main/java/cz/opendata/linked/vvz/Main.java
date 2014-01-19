package cz.opendata.linked.vvz;


import cz.opendata.linked.vvz.forms.PCReceiveException;
import cz.opendata.linked.vvz.forms.PCReceiver;
import cz.opendata.linked.vvz.forms.QueryParameters;
import cz.opendata.linked.vvz.utils.cache.Cache;

import cz.opendata.linked.vvz.utils.cache.CacheException;
import cz.opendata.linked.vvz.utils.journal.Journal;
import cz.opendata.linked.vvz.utils.journal.JournalException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.ArrayList;
import java.util.List;

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
			params.setSelectedFormType(2);
			params.setContext("first");
		} catch(Exception e) {
			logger.info("Error while setting query parameters. " + e.getMessage());
			System.exit(-1);
		}

		PCReceiver pcr = new PCReceiver();
		pcr.setLogger(logger);

		Journal journal = Journal.getInstance();
		journal.setLogger(logger);

		try {
			journal.getConnection("VVZJournal");
		} catch(JournalException e) {
			logger.info("Could not get Journal connection. " + e.getMessage());
			System.exit(-1);
		}

		try {

			Integer parsed = 0, alreadyParsed = 0, cached = 0, alreadyCached = 0, failures=0;

			List<String> PCIds = pcr.loadPublicContractsList(params);
			logger.info(PCIds.size() + " public contracts is going to be downloaded and parsed");

			for(String id : PCIds) {

				try {
					if(cache.isCached(id)) {
						logger.info(id + " file is already cached");
						cache.getDocument(id);
						alreadyCached++;
					} else {
						logger.info(id + " file is going to be downloaded");
						cache.storeDocument(pcr.loadPublicContractForm(id),id);
						cached++;
					}

					if(journal.getDocument(Integer.parseInt(id)) == null) {
						journal.insertDocument(Integer.parseInt(id));

						logger.info(id + " document is going to be parsed");
						parsed++;
					} else {
						logger.info(id + " document has been already parsed");
						alreadyParsed++;
					}


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

		} catch (PCReceiveException e) {
			logger.info(e.getMessage());
			System.exit(-1);
		} catch (JournalException e) {
			logger.info(e.getMessage());
		}

	}

}
