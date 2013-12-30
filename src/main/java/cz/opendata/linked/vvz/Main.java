package cz.opendata.linked.vvz;


import cz.opendata.linked.vvz.forms.PCReceiver;
import cz.opendata.linked.vvz.forms.QueryParameters;
import cz.opendata.linked.vvz.utils.Cache;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Main {


	private static Logger logger = LoggerFactory.getLogger(Main.class);

	public static void main(String[] args) {

		Cache cache = new Cache();

		QueryParameters params = new QueryParameters();
		params.dateFrom = "2013/12/20";
		params.dateTo = "";
		params.selectedFormType = "3";

		PCReceiver pcr = new PCReceiver();
		pcr.logger = logger;

		try {

			for(String id : pcr.loadPublicContractsList(params)) {


				if(cache.isCached(id)) {

					System.out.println("This file is cached");
					// cache.getDocument(id);
				} else {
					System.out.println("This file is going to be downloaded");

					// pcr.loadPublicContractForm(id);
					cache.storeDocument(pcr.loadPublicContractForm(id),id);
				}

				// todo mel by nahlasit kolik formularu se nepodarilo stahnout

				break;

			}
		} catch (Exception e) {

		}

	}

}
