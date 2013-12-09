package cz.opendata.linked.vvz.utils;

import javax.xml.soap.*;
import javax.xml.transform.*;
import javax.xml.transform.stream.*;

public class SOAPClientSAAJ {

	/**
	 * Starting point for the SAAJ - SOAP Client Testing
	 */
	public static void soapCall() {
		try {
			// Create SOAP Connection
			SOAPConnectionFactory soapConnectionFactory = SOAPConnectionFactory.newInstance();
			SOAPConnection soapConnection = soapConnectionFactory.createConnection();

			// Send SOAP Message to SOAP Server
			String url = "http://import.vestnikverejnychzakazek.cz/ExportForms.svc";
			SOAPMessage soapResponse = soapConnection.call(createSOAPRequest(), url);

			// Process the SOAP Response
			printSOAPResponse(soapResponse);

			soapConnection.close();
		} catch (Exception e) {
			System.err.println("Error occurred while sending SOAP Request to Server");
			e.printStackTrace();
		}
	}

	private static SOAPMessage createSOAPRequest() throws Exception {
		MessageFactory messageFactory = MessageFactory.newInstance();
		SOAPMessage soapMessage = messageFactory.createMessage();
		SOAPPart soapPart = soapMessage.getSOAPPart();

		String serverURI = "http://www.ness.cz/schemas/isvzus/ExportForms";
		String serverURI2 = "http://www.ness.cz/schemas/isvzus";

		// SOAP Envelope
		SOAPEnvelope envelope = soapPart.getEnvelope();

		envelope.addNamespaceDeclaration("ex", serverURI);
		envelope.addNamespaceDeclaration("isv", serverURI2);


        /*
        Constructed SOAP Request Message:
        <SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:example="http://ws.cdyne.com/">
            <SOAP-ENV:Header/>
            <SOAP-ENV:Body>
                <example:VerifyEmail>
                    <example:email>mutantninja@gmail.com</example:email>
                    <example:LicenseKey>123</example:LicenseKey>
                </example:VerifyEmail>
            </SOAP-ENV:Body>
        </SOAP-ENV:Envelope>
         */

		// SOAP Body
		SOAPBody soapBody = envelope.getBody();

		SOAPElement getFormDocumentEl = soapBody.addChildElement("GetFormDocument","ex");
		SOAPElement requestEl = getFormDocumentEl.addChildElement("request","ex");
		SOAPElement userIdEl = requestEl.addChildElement("UserId","isv");
		SOAPElement formIdEl = requestEl.addChildElement("FormId","isv");
		SOAPElement formatVersionEl = requestEl.addChildElement("FormatVersion","isv");


		userIdEl.addTextNode("396b47ba-0246-469f-9f29-b550976d7d65");
		formIdEl.addTextNode("460212");
		formatVersionEl.addTextNode("7.2");

		MimeHeaders headers = soapMessage.getMimeHeaders();
		headers.addHeader("SOAPAction", "http://www.ness.cz/schemas/isvzus/ExportForms/IExportForms/GetFormDocument");


		soapMessage.saveChanges();

        /* Print the request message */
		System.out.print("Request SOAP Message = ");
		soapMessage.writeTo(System.out);
		System.out.println();

		return soapMessage;
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


