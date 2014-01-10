package cz.opendata.linked.vvz.forms;


import java.text.SimpleDateFormat;
import java.util.Date;

public class QueryParameters {

	private String selectedFormType = "";
	private String dateFrom = "";
	private String dateTo = "";
	private String context = "";

	public void setSelectedFormType(Integer formType) throws Exception{
		// 1-19 a 50-55
		if(formType < 1 || (formType > 19 && formType < 50) || formType > 55) {
			throw new Exception("formType number must be in range 1-19 a 50-55");
		} else {
			this.selectedFormType = formType.toString();
		}
	}

	public String getSelectedFormType() {
		return this.selectedFormType.toString();
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
