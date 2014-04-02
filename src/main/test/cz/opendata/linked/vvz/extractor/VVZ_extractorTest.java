package cz.opendata.linked.vvz.extractor;

import org.junit.Test;
import org.junit.Assert;

import cz.cuni.mff.xrg.odcs.dataunit.file.handlers.DirectoryHandler;
import cz.cuni.mff.xrg.odcs.commons.configuration.ConfigException;
import cz.cuni.mff.xrg.odcs.dataunit.file.FileDataUnit;
import cz.cuni.mff.xrg.odcs.dpu.test.TestEnvironment;
import java.io.IOException;

/**
 * Created with IntelliJ IDEA.
 * User: cammeron
 * Date: 4/2/14
 * Time: 11:28 AM
 * To change this template use File | Settings | File Templates.
 */
public class VVZ_extractorTest {

	@Test
	public void testDownload() {

		try {

			VVZ_extractor extractor = new VVZ_extractor();
			VVZ_extractorConfig config = new VVZ_extractorConfig("2.1.2014","2.1.2014","");

			extractor.configureDirectly(config);

			TestEnvironment env = TestEnvironment.create();
			FileDataUnit output = env.createFileOutput("downloadedFiles");

			try {
				// run the execution
				env.run(extractor);
				DirectoryHandler root = output.getRootDir();
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

	}


}
