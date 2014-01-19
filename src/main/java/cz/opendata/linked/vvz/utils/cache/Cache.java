package cz.opendata.linked.vvz.utils.cache;

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

/**
 *  Document cache. It stores downloaded files to hard drive.
 *
 *
 */
public class Cache extends cz.opendata.linked.vvz.utils.Object {

	private static Cache instance = null;

	protected Cache() {
		// defeat instantiation.
	}

	public static Cache getInstance() {
		if(instance == null) {
			instance = new Cache();
		}
		return instance;
	}

	/**
	 * Dir where downloaded documents is stored
	 */
	private String cacheDir =  "cache";

	/**
	 * Path where cache dir is located
	 */
	private String basePath = "./";


	/**
	 * Dir location where downloaded documents will be cached
	 * @param cacheDir
	 */
	public void setCacheDir(String cacheDir) {
		this.cacheDir = cacheDir;
	}

	/**
	 * Path where cache dir is located
	 * @param basePath
	 */
	public void setBasePath(String basePath) {
		this.basePath = basePath;
	}

	/**
	 *
	 * @return cache dir location
	 */
	public File getCacheDir() {

		return new File(this.basePath,this.cacheDir);

	}

	/**
	 * Check if is document already cached
	 * @param documentId
	 */
	public boolean isCached(String documentId) {

		File doc = new File(this.getCacheDir(), documentId + ".xml");

		return doc.exists();
	}

	/**
	 * @param documentId
	 * @throws CacheException
	 * @return cached document by id
	 */
	public Document getDocument(String documentId) throws CacheException {

		Document doc = null;

		if(this.isCached(documentId)) {
			File xml = new File(this.getCacheDir(), documentId + ".xml");

			try {
				DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
				DocumentBuilder db = dbf.newDocumentBuilder();
				doc = db.parse(xml);

			} catch(Exception e) {
				throw new CacheException("Could not get cached document. " + e.getMessage(), e);
			}
		}

		return doc;
	}

	/**
	 * Store document in document cache
	 * @param doc
	 * @param documentId
	 * @throws CacheException
	 */
	public void storeDocument(Document doc, String documentId) throws CacheException {

		try {

			this.getCacheDir().mkdirs();
			File newDoc = new File(this.getCacheDir(), documentId + ".xml");

			newDoc.createNewFile();

			Transformer transformer = TransformerFactory.newInstance().newTransformer();
			Result output = new StreamResult(newDoc);
			Source input = new DOMSource(doc);

			transformer.transform(input, output);

		} catch(Exception e) {
			throw new CacheException("Could not store document " + e.getMessage(), e);
		}


	}

}