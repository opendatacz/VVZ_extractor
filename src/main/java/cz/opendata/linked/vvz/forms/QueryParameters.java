package cz.opendata.linked.vvz.forms;


import java.text.SimpleDateFormat;
import java.util.Date;

public class QueryParameters {

	private String[] selectedFormTypes;
	private String dateFrom = "";
	private String dateTo = "";
	private String context = "";

	public void setSelectedFormTypes(Integer[] formTypes) throws Exception{

		String[] finalFormTypes = new String[formTypes.length];

		for(int i=0; i<formTypes.length; i++) {
			// 1-19 a 50-55
			if(formTypes[i] < 1 || (formTypes[i] > 19 && formTypes[i] < 50) || formTypes[i] > 55) {
				throw new Exception("Form type numbers must be in range 1-19 a 50-55");
			} else {
				finalFormTypes[i] = formTypes[i].toString();
			}
		}
		this.selectedFormTypes = finalFormTypes;

	}

	public String[] getSelectedFormTypes() {
		return this.selectedFormTypes;
	}

	public void setDateFrom(Date dateFrom) {
		this.dateFrom = new SimpleDateFormat("MM/dd/yyyy").format(dateFrom);
	}

	public String getDateFrom() {
		return this.dateFrom;
	}

	public void setDateTo(Date dateTo) {
		this.dateTo = new SimpleDateFormat("MM/dd/yyyy").format(dateTo);
	}

	public String getDateTo() {
		return this.dateTo;
	}


	public void setContext(String context) {
		this.context = context;
	}

	public String getContext() {
		return this.context;
	}

}
