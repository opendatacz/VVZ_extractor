package cz.opendata.linked.vvz.forms;

import java.util.ArrayList;
import java.util.List;

import javax.xml.soap.*;
import javax.xml.transform.*;
import javax.xml.transform.stream.*;
import javax.xml.bind.DatatypeConverter;

import org.w3c.dom.NodeList;
import org.w3c.dom.Document;
import org.xml.sax.InputSource;

import java.io.StringReader;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import cz.opendata.linked.vvz.utils.Object;


/**
 * Receives public contract from vestnikverejnychzakazek.cz using SOAP Web Services
 */
public class PCReceiver extends Object {

	private SOAPConnection connection;
	QueryParameters params;

	private String serverURL = "http://import.vestnikverejnychzakazek.cz/ExportForms.svc";


	private String URLExportForms = "http://www.ness.cz/schemas/isvzus/ExportForms";
	private String URLisvzus = "http://www.ness.cz/schemas/isvzus";

	public PCReceiver(QueryParameters params) {
		this.params = params;
	}

	private SOAPConnection getConnection() throws SOAPException {

		if(this.connection == null) {

			// Create SOAP Connection
			SOAPConnectionFactory soapConnectionFactory = SOAPConnectionFactory.newInstance();
			this.connection = soapConnectionFactory.createConnection();
		}

		return this.connection;

	}


	/**
	 * Makes SOAP connection to vestnikverejnychzakazek.cz and receive list of public contracts by given parameters
	 * @return list of public contracts
	 * @throws PCReceiveException
	 */
	public List<String> loadPublicContractsList() throws PCReceiveException {

		List<String> PCIds = new ArrayList<>();

		try {
			MessageFactory messageFactory = MessageFactory.newInstance();
			SOAPMessage soapMessage = messageFactory.createMessage();
			SOAPPart soapPart = soapMessage.getSOAPPart();

			// SOAP Envelope
			SOAPEnvelope envelope = soapPart.getEnvelope();

			envelope.addNamespaceDeclaration("ex", this.URLExportForms);
			envelope.addNamespaceDeclaration("isv", this.URLisvzus);

			// SOAP Body
			SOAPBody soapBody = envelope.getBody();

			SOAPElement getFormDocumentEl = soapBody.addChildElement("ListForms","ex");
			SOAPElement requestEl = getFormDocumentEl.addChildElement("request","ex");

			SOAPElement userIdEl = requestEl.addChildElement("UserId","isv");
			userIdEl.addTextNode(params.getGUID());

			SOAPElement queryParamsEl = requestEl.addChildElement("QueryParameters","isv");
			SOAPElement formTypeEl;

			if(params.getSelectedFormTypes().length < 1) {
				throw new PCReceiveException("No required form types in query parameters.");
			} else {

				SOAPElement queryParamEl = queryParamsEl.addChildElement("QueryParameter", "isv");
				queryParamEl.addChildElement("Name", "isv").addTextNode("SelectedFormType");
				formTypeEl = queryParamEl.addChildElement("Value","isv").addTextNode("");

				if(!params.getDateFrom().isEmpty()) {
					queryParamEl = queryParamsEl.addChildElement("QueryParameter","isv");
					queryParamEl.addChildElement("Name","isv").addTextNode("DateTimePublicationFrom");
					queryParamEl.addChildElement("Value", "isv").addTextNode(params.getDateFrom());
				}

				if(!params.getDateTo().isEmpty()) {
					queryParamEl = queryParamsEl.addChildElement("QueryParameter","isv");
					queryParamEl.addChildElement("Name","isv").addTextNode("DateTimePublicationTo");
					queryParamEl.addChildElement("Value", "isv").addTextNode(params.getDateTo());
				}

			}

			MimeHeaders headers = soapMessage.getMimeHeaders();
			headers.addHeader("SOAPAction", "http://www.ness.cz/schemas/isvzus/ExportForms/IExportForms/ListForms");

			for(int i=0;i<params.getSelectedFormTypes().length;i++) {

				String formType = params.getSelectedFormTypes()[i];

				formTypeEl.setTextContent(formType);

				soapMessage.saveChanges();

				try {
					SOAPBody responseBody = this.soapCall(soapMessage).getSOAPBody();

					String code = responseBody.getElementsByTagNameNS(this.URLisvzus,"Code").item(0).getTextContent();
					if(code.equals("0")) {
						log("Form type " + formType + " public contracts list received.");
					} else if(code.equals("1")) {
						throw new PCReceiveException("Loading public contracts  " + formType + "  list failed. Code " + code + " - Bad query parameters.");
					} else if(code.equals("3")) {
						throw new PCReceiveException("Loading public contracts  " + formType + "  list failed. Code " + code + " - Identification failed. Wrong GUID.");
					} else if(code.equals("99")) {
						throw new PCReceiveException("Loading public contracts  " + formType + "  list failed. Code " + code + " - Unknown reason.");
					}

					NodeList formsList = responseBody.getElementsByTagNameNS(this.URLisvzus,"FormInfo");

					for(int j=0; j<formsList.getLength();j++) {

						PCIds.add(formsList.item(j).getTextContent());
					}
				} catch(SOAPException e) {
					throw new PCReceiveException("Error while loading public contracts list.", e);

				}

			}

		} catch(SOAPException e) {
			throw new PCReceiveException("Error while creating public contracts load request.", e);
		}

		return PCIds;

	}

	/**
	 * Makes SOAP connection to vestnikverejnychzakazek.cz and receive public contract form by given form id
	 * @param id form id
	 * @return public contract XML document
	 * @throws PCReceiveException
	 */
	public Document loadPublicContractForm(String id) throws PCReceiveException {

		Document xml = null;

		try {
			MessageFactory messageFactory = MessageFactory.newInstance();
			SOAPMessage soapMessage = messageFactory.createMessage();
			SOAPPart soapPart = soapMessage.getSOAPPart();

			// SOAP Envelope
			SOAPEnvelope envelope = soapPart.getEnvelope();

			envelope.addNamespaceDeclaration("ex", this.URLExportForms);
			envelope.addNamespaceDeclaration("isv", this.URLisvzus);

			SOAPBody soapBody = envelope.getBody();

			SOAPElement getFormDocumentEl = soapBody.addChildElement("GetFormDocument","ex");
			SOAPElement requestEl = getFormDocumentEl.addChildElement("request","ex");
			SOAPElement userIdEl = requestEl.addChildElement("UserId","isv");
			SOAPElement formIdEl = requestEl.addChildElement("FormId","isv");
			SOAPElement formatVersionEl = requestEl.addChildElement("FormatVersion","isv");

			userIdEl.addTextNode(params.getGUID());
			formIdEl.addTextNode(id);
			formatVersionEl.addTextNode("7.2");

			MimeHeaders headers = soapMessage.getMimeHeaders();
			headers.addHeader("SOAPAction", "http://www.ness.cz/schemas/isvzus/ExportForms/IExportForms/GetFormDocument");

			soapMessage.saveChanges();

			try {
				SOAPBody responseBody = this.soapCall(soapMessage).getSOAPBody();
				String doc = responseBody.getElementsByTagNameNS(this.URLisvzus,"FormDocument").item(0).getTextContent();

				// todo handle BOM
				doc = new String(DatatypeConverter.parseBase64Binary(doc),"UTF-8").substring(1);

				DocumentBuilderFactory dbfac = DocumentBuilderFactory.newInstance();
				DocumentBuilder docBuilder = dbfac.newDocumentBuilder();

				xml = docBuilder.parse(new InputSource(new StringReader(doc)));
			} catch(Exception e) {
				throw new PCReceiveException("Error while parsing public contract form response.", e);
			}

		} catch(SOAPException e) {
			throw new PCReceiveException("Error while creating public contract get form request.", e);
		}

		return xml;

	}

	/**
	 * Send SOAP Message to SOAP Server and return the SOAP Response
	 */
	private SOAPMessage soapCall(SOAPMessage request) throws SOAPException {

		return this.getConnection().call(request, this.serverURL);

	}

	public void close() throws PCReceiveException {

		try {
			this.connection.close();
		} catch (SOAPException e) {
			throw new PCReceiveException("Could not close connection.", e);
		}
	}

	/**
	 * Method used to print the SOAP Response
	 */
	private void printSOAPResponse(SOAPMessage soapResponse) throws Exception {
		TransformerFactory transformerFactory = TransformerFactory.newInstance();
		Transformer transformer = transformerFactory.newTransformer();
		Source sourceContent = soapResponse.getSOAPPart().getContent();
		System.out.print("\nResponse SOAP Message = ");
		StreamResult result = new StreamResult(System.out);
		transformer.transform(sourceContent, result);
	}

}


