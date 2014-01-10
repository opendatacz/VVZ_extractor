package cz.opendata.linked.vvz.utils.journal;


public class JournalException extends Exception {
	public JournalException() { super(); }
	public JournalException(String message) { super(message); }
	public JournalException(String message, Throwable cause) { super(message, cause); }
	public JournalException(Throwable cause) { super(cause); }
}
