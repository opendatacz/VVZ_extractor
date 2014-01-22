package cz.opendata.linked.vvz.utils.xslt;

import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamSource;

import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltExecutable;
import net.sf.saxon.s9api.XsltTransformer;
import org.w3c.dom.Document;

import java.io.File;
import java.io.StringWriter;

public class XML2RDF extends cz.opendata.linked.vvz.utils.Object {


	private XsltTransformer trans;

	public XML2RDF(File stylesheet) throws Exception{
		if (stylesheet == null) {
			throw new Exception("Stylesheet file must not be null");
		}

		Processor proc = new Processor(false);
		XsltCompiler compiler = proc.newXsltCompiler();
		XsltExecutable exp;
		try {
			exp = compiler.compile(new StreamSource(stylesheet));

			XsltTransformer trans = exp.load();

			this.trans = trans;
		} catch (SaxonApiException e) {
			throw new Exception(e.getMessage());
		}

	}

	public String executeXSLT(Document inputFile) throws Exception {

		if (inputFile == null) {
			throw new Exception("Invalid input to execute XSLT method.");
		}

		this.log("XSLT is being prepared to be executed");

		Serializer out = new Serializer();
		out.setOutputProperty(Serializer.Property.METHOD, "xml");
		out.setOutputProperty(Serializer.Property.INDENT, "yes");

		StringWriter sw = new StringWriter();
		out.setOutputWriter(sw);

		try {
			this.trans.setSource(new DOMSource(inputFile));

			this.trans.setDestination(out);
			this.trans.transform();

			return sw.toString();

		} catch (SaxonApiException e) {
			throw new Exception("Error occurred while transforming xml document.", e);
		}

	}



}
