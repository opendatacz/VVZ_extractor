package cz.opendata.linked.vvz.forms;

import java.util.ArrayList;
import java.util.List;

import javax.xml.soap.*;
import javax.xml.transform.*;
import javax.xml.transform.stream.*;
import javax.xml.bind.DatatypeConverter;

import org.slf4j.Logger;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.w3c.dom.Node;
import org.w3c.dom.Document;

import org.xml.sax.InputSource;

import java.io.StringReader;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;



public class PCReceiver {

	private SOAPConnection connection;
	private String serverURL = "http://import.vestnikverejnychzakazek.cz/ExportForms.svc";
	private String userId = "396b47ba-0246-469f-9f29-b550976d7d65";


	public Logger logger;

	private SOAPConnection getConnection() {

		if(this.connection == null) {

			try {
				// Create SOAP Connection
				SOAPConnectionFactory soapConnectionFactory = SOAPConnectionFactory.newInstance();
				this.connection = soapConnectionFactory.createConnection();
				this.logger.info("PC list downloaded");

			} catch (Exception e) {
				System.err.println("Error occurred while creating SOAP connection");
				e.printStackTrace();
			}

		}

		return this.connection;

	}


	// String[] params
	public List<String> loadPublicContractsList(QueryParameters params) throws Exception {


		MessageFactory messageFactory = MessageFactory.newInstance();
		SOAPMessage soapMessage = messageFactory.createMessage();
		SOAPPart soapPart = soapMessage.getSOAPPart();

		String serverURI = "http://www.ness.cz/schemas/isvzus/ExportForms";
		String serverURI2 = "http://www.ness.cz/schemas/isvzus";

		// SOAP Envelope
		SOAPEnvelope envelope = soapPart.getEnvelope();

		envelope.addNamespaceDeclaration("ex", serverURI);
		envelope.addNamespaceDeclaration("isv", serverURI2);

		// SOAP Body
		SOAPBody soapBody = envelope.getBody();

		SOAPElement getFormDocumentEl = soapBody.addChildElement("ListForms","ex");
		SOAPElement requestEl = getFormDocumentEl.addChildElement("request","ex");

		SOAPElement userIdEl = requestEl.addChildElement("UserId","isv");
		userIdEl.addTextNode(this.userId);

		SOAPElement queryParamsEl = requestEl.addChildElement("QueryParameters","isv");

		// todo provest kontrolu predanych parametru

		if(params.selectedFormType.isEmpty()) {
			throw new Exception("selectedFormType parameter must be filled.");
		} else {
			SOAPElement queryParamEl = queryParamsEl.addChildElement("QueryParameter","isv");
			queryParamEl.addChildElement("Name","isv").addTextNode("SelectedFormType");
			queryParamEl.addChildElement("Value","isv").addTextNode(params.selectedFormType);

			queryParamEl = queryParamsEl.addChildElement("QueryParameter","isv");
			queryParamEl.addChildElement("Name","isv").addTextNode("DateTimePublicationFrom");
			queryParamEl.addChildElement("Value","isv").addTextNode(params.dateFrom);

			if(!params.dateTo.isEmpty()) {
				queryParamEl = queryParamsEl.addChildElement("QueryParameter","isv");
				queryParamEl.addChildElement("Name","isv").addTextNode("DateTimePublicationTo");
				queryParamEl.addChildElement("Value","isv").addTextNode(params.dateTo);
			}
		}

		MimeHeaders headers = soapMessage.getMimeHeaders();
		headers.addHeader("SOAPAction", "http://www.ness.cz/schemas/isvzus/ExportForms/IExportForms/ListForms");

		soapMessage.saveChanges();

		SOAPBody responseBody = this.soapCall(soapMessage).getSOAPBody();

		// todo provest kontrolu navratoveho kodu SOAP zpravy

		NodeList formsList = responseBody.getElementsByTagNameNS(serverURI2,"FormInfo");

		List<String> PCIds = new ArrayList<>();

		for(int i=0; i<formsList.getLength();i++) {

			PCIds.add(formsList.item(i).getTextContent());
		}

		return PCIds;

	}

	public Document loadPublicContractForm(String id) throws Exception{

		MessageFactory messageFactory = MessageFactory.newInstance();
		SOAPMessage soapMessage = messageFactory.createMessage();
		SOAPPart soapPart = soapMessage.getSOAPPart();

		String serverURI = "http://www.ness.cz/schemas/isvzus/ExportForms";
		String serverURI2 = "http://www.ness.cz/schemas/isvzus";

		// SOAP Envelope
		SOAPEnvelope envelope = soapPart.getEnvelope();

		envelope.addNamespaceDeclaration("ex", serverURI);
		envelope.addNamespaceDeclaration("isv", serverURI2);

		SOAPBody soapBody = envelope.getBody();

		SOAPElement getFormDocumentEl = soapBody.addChildElement("GetFormDocument","ex");
		SOAPElement requestEl = getFormDocumentEl.addChildElement("request","ex");
		SOAPElement userIdEl = requestEl.addChildElement("UserId","isv");
		SOAPElement formIdEl = requestEl.addChildElement("FormId","isv");
		SOAPElement formatVersionEl = requestEl.addChildElement("FormatVersion","isv");


		userIdEl.addTextNode(this.userId);
		formIdEl.addTextNode(id);
		formatVersionEl.addTextNode("7.2");

		MimeHeaders headers = soapMessage.getMimeHeaders();
		headers.addHeader("SOAPAction", "http://www.ness.cz/schemas/isvzus/ExportForms/IExportForms/GetFormDocument");


		soapMessage.saveChanges();

		SOAPBody responseBody = this.soapCall(soapMessage).getSOAPBody();
		String doc = responseBody.getElementsByTagNameNS(serverURI2,"FormDocument").item(0).getTextContent();

		doc = new String(DatatypeConverter.parseBase64Binary(doc),"UTF-8").replaceAll("[^\\x20-\\x7e\\x0A]", "");


		DocumentBuilderFactory dbfac = DocumentBuilderFactory.newInstance();
		DocumentBuilder docBuilder = dbfac.newDocumentBuilder();

		Document xml = docBuilder.parse(new InputSource(new StringReader(doc)));

		return xml;

	}

	/**
	 * Starting point for the SAAJ - SOAP Client Testing
	 */
	public SOAPMessage soapCall(SOAPMessage request) {
		try {
			// Send SOAP Message to SOAP Server and Process the SOAP Response
			return this.getConnection().call(request, serverURL);

		} catch (Exception e) {
			System.err.println("Error occurred while sending SOAP Request to Server");
			e.printStackTrace();
		}

		return null;
	}

	public void close() {

		try {
			this.connection.close();
		} catch (Exception e) {
			System.err.println("Error occurred while closing SOAP connection");
			e.printStackTrace();
		}
	}

	/**
	 * Method used to print the SOAP Response
	 */
	private static void printSOAPResponse(SOAPMessage soapResponse) throws Exception {
		TransformerFactory transformerFactory = TransformerFactory.newInstance();
		Transformer transformer = transformerFactory.newTransformer();
		Source sourceContent = soapResponse.getSOAPPart().getContent();
		System.out.print("\nResponse SOAP Message = ");
		StreamResult result = new StreamResult(System.out);
		transformer.transform(sourceContent, result);
	}

}


