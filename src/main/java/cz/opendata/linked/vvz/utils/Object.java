package cz.opendata.linked.vvz.utils;

import org.slf4j.Logger;

public abstract class Object {

	protected Logger logger;

	public void setLogger(Logger logger) {

		this.logger = logger;

	}

	protected void log(String msg) {
		if(this.logger != null) {
			this.logger.info(msg);
		}
	}

}
