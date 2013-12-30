package cz.opendata.linked.vvz.utils;

import java.io.*;

import org.w3c.dom.Document;
import javax.xml.transform.Transformer;
import javax.xml.transform.Source;
import javax.xml.transform.Result;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.slf4j.Logger;

/**
 *  Document cache. It stores downloaded files to hard drive.
 *
 *
 */
public class Cache {

	private String cacheDir =  "./";
	private String basePath = "cache";

	public boolean rewriteCache = false;

	public Logger logger;

	public void setCacheDir(String cacheDir) {
		this.cacheDir = cacheDir;
	}

	public File getCacheDir() {

		return new File(this.basePath,this.cacheDir);

	}


	public boolean isCached(String documentId) {

		File doc = new File(this.getCacheDir(), documentId + ".xml");

		return doc.exists();
	}

	public Document getDocument(String documentId) throws IOException, InterruptedException {

		Document doc = null;

		if(this.isCached(documentId)) {
			File xml = new File(this.getCacheDir(), documentId + ".xml");

			try {
				DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
				DocumentBuilder db = dbf.newDocumentBuilder();
				doc = db.parse(xml);

			} catch(Exception e) {
				e.printStackTrace();
			}
		}

		return doc;
	}

	public void storeDocument(Document doc, String documentId) {

		try {

			this.getCacheDir().mkdirs();
			File newDoc = new File(this.getCacheDir(), documentId + ".xml");

			newDoc.createNewFile();

			try {
				Transformer transformer = TransformerFactory.newInstance().newTransformer();
				Result output = new StreamResult(newDoc);
				Source input = new DOMSource(doc);

				transformer.transform(input, output);
			} catch(Exception e) {
				e.printStackTrace();
			}

		} catch(IOException e) {
			e.printStackTrace();
			// todo Logger
		}


	}

}