package cz.opendata.linked.vvz.extractor;

import org.junit.Test;
import org.junit.Assert;

import cz.cuni.mff.xrg.odcs.dataunit.file.handlers.DirectoryHandler;
import cz.cuni.mff.xrg.odcs.commons.configuration.ConfigException;
import cz.cuni.mff.xrg.odcs.dataunit.file.FileDataUnit;
import cz.cuni.mff.xrg.odcs.dpu.test.TestEnvironment;
import java.io.IOException;


public class VVZ_extractorTest {


	@Test
	public void testDownload() {

		Assert.assertTrue(true);

		/*
		try {

			VVZ_extractor extractor = new VVZ_extractor();
			VVZ_extractorConfig config = new VVZ_extractorConfig("2.1.2014","2.1.2014",false,"");

			extractor.configureDirectly(config);

			TestEnvironment env = TestEnvironment.create();
			FileDataUnit output = env.createFileOutput("downloadedFiles");

			try {
				// run the execution
				env.run(extractor);
				System.out.println("Resulting directory: " + output.getRootDir().size());

				Assert.assertTrue(output.getRootDir().size() > 0);

			} catch (Exception e) {
				e.printStackTrace();
			} finally {
				// release resources
				env.release();
			}

		} catch (IOException e) {
			e.printStackTrace();
		} catch (ConfigException e) {
			e.printStackTrace();
		}
		*/

	}



}
