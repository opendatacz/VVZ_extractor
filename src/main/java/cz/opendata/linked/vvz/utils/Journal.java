package cz.opendata.linked.vvz.utils;

import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.sql.*;
import java.util.Calendar;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 *
 */
public class Journal {
    
    private final String driver = "org.apache.derby.jdbc.EmbeddedDriver";
    
    private static Connection connection = null;

	private static PreparedStatement insertDocument = null;
	private static PreparedStatement selectDocument = null;
    
    private static void prepare() throws SQLException {
        //connection.createStatement().execute("DELETE FROM document");
        
        insertDocument = connection.prepareStatement("INSERT INTO document(url, scraped) VALUES(?,?)", PreparedStatement.RETURN_GENERATED_KEYS);
        selectDocument = connection.prepareStatement("SELECT url FROM document WHERE url=?");

    }
    
    public Connection getConnection(String DBlocation) throws SQLException {
        if (connection == null) {
            try{
                // Load the EmbeddedDriver class
                Class.forName(this.driver).newInstance();
                System.out.println("Loaded Derby Driver");
            }catch(Exception e){
                e.printStackTrace();
                System.out.println("Error loading Derby Driver.  Shutting down.");
                System.exit(-1);
            }

            String connectionURL = "jdbc:derby:" + DBlocation + ";create=true";

            System.out.println("Connecting!");
            connection = DriverManager.getConnection(connectionURL);


            System.out.println("Creating database in " + DBlocation);
            try {
                createTables();
            } catch (SQLException ex) {
                System.out.println("Database already exists");
            }

            prepare();
        }
        return connection;
    }

    public static boolean hasConnection() {

        if (connection == null) {
            return false;
        } else {
            return true;
        }

    }
    
    public static void createTables() throws SQLException {
        String[] createString = { "CREATE  TABLE document ("
                + "id INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY ,"
                + "url VARCHAR(255) NOT NULL ,"
                + "scraped TIMESTAMP NOT NULL ,"
                + "PRIMARY KEY (id) ,"
                + "UNIQUE (url) "
                + ")"
        };
        
        Statement s = connection.createStatement();
        for (String q: createString) {
            s.execute(q);
        }
    }
    
    public static Integer insertDocument(String url) {
        try {
            insertDocument.setString(1, url);
            insertDocument.setTimestamp(2, new Timestamp(Calendar.getInstance().getTimeInMillis()));
            insertDocument.execute();
            ResultSet keys = insertDocument.getGeneratedKeys();
            if (keys.next()) {
                return keys.getInt(1);
            } else {
                throw new SQLException("Creating user failed, no generated key obtained.");
            }
        } catch (SQLException ex) {
            Logger.getLogger(Journal.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }
    
    public static String getDocument(String id) {
        try {
            selectDocument.setString(1, id);
            ResultSet result = selectDocument.executeQuery();

            System.out.println("Hledam URL: " + id);

            if (result.next()) {
                return result.getString("url");
            }
        } catch (SQLException ex) {
            Logger.getLogger(Journal.class.getName()).log(Level.SEVERE, null, ex);
        }

        return null;
    }


	public static void close() {

		try {
			connection.close();
			connection = null;
		} catch(SQLException ex) {
			Logger.getLogger(Journal.class.getName()).log(Level.SEVERE, null, ex);
		}
	}
    
}
