package cz.opendata.linked.vvz.utils.journal;

import java.sql.*;
import java.util.Calendar;
import org.apache.derby.jdbc.EmbeddedDriver;

/**
 * Registers used documents
 *
 */
public class Journal extends cz.opendata.linked.vvz.utils.Object {

	private static Journal instance = null;
	protected Journal() {
		// defeat instantiation.
	}
	public static Journal getInstance() {
		if(instance == null) {
			instance = new Journal();
		}
		return instance;
	}

    private final String driver = "org.apache.derby.jdbc.EmbeddedDriver";
    
    private Connection connection = null;

	private PreparedStatement insertDocumentQuery = null;
	private PreparedStatement selectDocumentQuery = null;

	/**
	 * Makes connection to Apache Derby DB. If DB does not exist, DB will be created in given DB location.
	 * @param DBlocation Dir location where is Apache Derby DB stored
	 * @return Connection
	 * @throws JournalException
	 */
    public Connection getConnection(String DBlocation) throws JournalException {

        if (this.connection == null) {
            try{
                // Load the EmbeddedDriver class
	            new EmbeddedDriver();
                //Class.forName(this.driver).newInstance();
                this.log("Derby driver loaded.");
            } catch(Exception e) {
                throw new JournalException("Could not load derby driver.", e);
            }

            String connectionURL = "jdbc:derby:" + DBlocation + ";create=true";

	        try {
                this.connection = DriverManager.getConnection(connectionURL);
	        } catch(SQLException e) {
		        throw new JournalException(e.getMessage());
	        }

            this.log("Creating database in " + DBlocation);
            try {
                createTables();
	            this.log("Creating database in " + DBlocation + " was successful.");
            } catch (SQLException e) {
				throw new JournalException("Creating database in " + DBlocation + " failed. " + e.getMessage(), e);
            }
	        try {
                prepare();
	        } catch(SQLException e) {
		        throw new JournalException("Preparing SQL statements failed. " + e.getMessage(), e);
	        }
        }
        return this.connection;
    }

	/**
	 * Prepares SQL statements for selecting and inserting document ids
	 * @throws SQLException
	 */
	private void prepare() throws SQLException {
		//connection.createStatement().execute("DELETE FROM document");

		this.insertDocumentQuery = this.connection.prepareStatement("INSERT INTO documents (id, downloaded) VALUES(?,?)");
		this.selectDocumentQuery = this.connection.prepareStatement("SELECT id FROM documents WHERE id=?");
	}

    public boolean hasConnection() {

		return this.connection != null;

    }

	/**
	 * Creates documents table where documents ids will be registered / remembered
	 * @throws SQLException
	 */
    private void createTables() throws SQLException {

        String[] createString = { "CREATE TABLE documents ("
                + "id INT NOT NULL ,"
                + "downloaded TIMESTAMP NOT NULL , "
                + "PRIMARY KEY (id)"
                + ")"
        };

        Statement s = this.connection.createStatement();

	    try {
	        for (String q: createString) {
	            s.execute(q);
	        }
	    } catch(SQLException e) {

		    if(e.getSQLState().equals("X0Y32")) { // table documents exists
				this.log("database exists.");
		    } else {
			    throw e;
		    }

	    }

    }

	/**
	 * Registers document id
	 * @param id document id
	 * @throws JournalException
	 */
    public void insertDocument(Integer id) throws JournalException {
        try {
			if(id != null) {
	            this.insertDocumentQuery.setInt(1, id);
	            this.insertDocumentQuery.setTimestamp(2, new Timestamp(Calendar.getInstance().getTimeInMillis()));
	            this.insertDocumentQuery.execute();
			} else {
				throw new JournalException("Could not insert document. No given document id");
			}
        } catch (SQLException e) {
	        throw new JournalException("Could not insert document. " + e.getMessage(), e);
        }
    }

	/**
	 * @param id document id
	 * @return document id by given id if that document is registered in database else returns null
	 * @throws JournalException
	 */
    public Integer getDocument(Integer id) throws JournalException {
        try {
            this.selectDocumentQuery.setInt(1, id);
            ResultSet result = this.selectDocumentQuery.executeQuery();

            if (result.next()) {
                return result.getInt("id");
            }
        } catch (SQLException e) {
            throw new JournalException("Could not get document. " + e.getMessage(), e);
        }

        return null;
    }


	/**
	 * Free journal connection
	 * @throws JournalException
	 */
	public void close() throws JournalException {

		if(this.hasConnection()) {
			try {
				this.connection.close();
				this.connection = null;
			} catch(SQLException e) {
				throw new JournalException("Could not close connection. " + e.getMessage(), e);
			}
		}
	}
    
}
