package com.capstone.bluetooth;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.xml.bind.annotation.XmlRootElement;

import java.io.*;
import java.sql.*;

import javax.servlet.http.*;

import org.codehaus.jettison.json.JSONException;
import org.codehaus.jettison.json.JSONObject;

import com.google.appengine.api.utils.SystemProperty;
 
//The Java class will be hosted at the URI path "/helloworld"
@XmlRootElement
@Path("/capstone")
public class CapstoneServlet {
 

	@Path("/navigate")
	@GET
	   @Produces("application/json")
	
	//HTTP request for navigation instructions 
    public JSONObject getSteps(@QueryParam("fromId") int fromID, @QueryParam("toId") int toID) {
        // Return some cliched textual content
    	String url = null;
    	Statement stmt = null;
    	ResultSet rs = null;
    	Connection conn = null;
    	String fromId = null;
    	String toId = null;
    	String info = null;
    	String subject = null;
    
    	try {
    	      if (SystemProperty.environment.value() ==
    	          SystemProperty.Environment.Value.Production) {
    	        // Load the class that provides the new "jdbc:google:mysql://" prefix.
    	        Class.forName("com.mysql.jdbc.GoogleDriver");
    	        url = "jdbc:google:mysql://bluetooth-cs463:data/capstone?user=root"; //connect to the database on google cloud SQL
    	        conn = DriverManager.getConnection(url);
    	        stmt = conn.createStatement();
    	        rs = stmt.executeQuery("SELECT * FROM NAVIGATION where fromId = '" + fromID + "'" + "AND toId = '" + toID +"'");
    	        
    	        while(rs.next()){
    	        	fromId = rs.getString("fromId");
    	        	toId = rs.getString("toId");
    	        }
    	        
    	      } else {
    	        // Local MySQL instance to use during development.
    	        Class.forName("com.mysql.jdbc.Driver");
    	        url = "jdbc:mysql://127.0.0.1:3306/capstone?user=root";

    	        // Alternatively, connect to a Google Cloud SQL instance using:
    	        // jdbc:mysql://ip-address-of-google-cloud-sql-instance:3306/guestbook?user=root
    	      }
    	    } catch (Exception e) {
    	      e.printStackTrace();
    	
    	    }
    	finally {
			try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
			try { if (stmt != null) stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
			try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
		}
    	
    	JSONObject myObject = new JSONObject();
    	
    	
    	/* turning retrieved fields from the database into an JSON object */
    	try {
			myObject.put("fromId", fromId);
			myObject.put("toId", toId);

		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	return myObject;
    }
	
    // The Java method will process HTTP GET requests for beacons information
    @GET
    // The Java method will produce content identified by the MIME Media
    // type "text/plain"
    @Produces("application/json")
    public JSONObject getJson(@QueryParam("majorId") int majorId, @QueryParam("minorId") int minorId) {
        // Return some cliched textual content
    	String url = null;
    	Statement stmt = null;
    	ResultSet rs = null;
    	Connection conn = null;
    	String id1 = null;
    	String id2 = null;
    	String info = null;
    	String subject = null;
    
    	try {
    	      if (SystemProperty.environment.value() ==
    	          SystemProperty.Environment.Value.Production) {
    	        // Load the class that provides the new "jdbc:google:mysql://" prefix.
    	        Class.forName("com.mysql.jdbc.GoogleDriver");
    	        url = "jdbc:google:mysql://bluetooth-cs463:data/capstone?user=root";  //connect to the database on Cloud SQL
    	        conn = DriverManager.getConnection(url);
    	        stmt = conn.createStatement();
    	        rs = stmt.executeQuery("SELECT * FROM BEACONS where majorId = '" + majorId + "'" + "AND minorId = '" + minorId +"'");
    	        
    	        
    	        /* get the result from the query */
    	        while(rs.next()){
    	        	id1 = rs.getString("majorId");
    	        	id2 = rs.getString("minorId");
    	        	info = rs.getString("info");
    	        	subject = rs.getString("subject");
    	        }
    	        
    	      } else {
    	        // Local MySQL instance to use during development.
    	        Class.forName("com.mysql.jdbc.Driver");
    	        url = "jdbc:mysql://127.0.0.1:3306/capstone?user=root";

    	        // Alternatively, connect to a Google Cloud SQL instance using:
    	        // jdbc:mysql://ip-address-of-google-cloud-sql-instance:3306/guestbook?user=root
    	      }
    	    } catch (Exception e) {
    	      e.printStackTrace();
    	
    	    }
    	finally {
			try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
			try { if (stmt != null) stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
			try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
		}
    	
    	JSONObject myObject = new JSONObject();
    	
    	
    	/* bind the retrieved result from the database into a JSON object */
    	try {
			myObject.put("majorId", id1);
			myObject.put("minorId", id2);
			myObject.put("info", info);
			myObject.put("subject", subject);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	
    	return myObject;

    }
}