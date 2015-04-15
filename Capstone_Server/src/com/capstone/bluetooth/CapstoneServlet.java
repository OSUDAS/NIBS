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
 

	@Path("/hi")
	@GET
	@Produces("text/plain")
	public String hi(){
		return "whats up HIIIIII";
		
	}
	
	
	
    // The Java method will process HTTP GET requests
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
    	String sup = "whats up ";
    	String building = null;
    	String location = null;
    
    	try {
    	      if (SystemProperty.environment.value() ==
    	          SystemProperty.Environment.Value.Production) {
    	        // Load the class that provides the new "jdbc:google:mysql://" prefix.
    	        Class.forName("com.mysql.jdbc.GoogleDriver");
    	        url = "jdbc:google:mysql://capstone-bluetooth:datawarehouse/capstone?user=root";
    	        conn = DriverManager.getConnection(url);
    	        stmt = conn.createStatement();
    	        rs = stmt.executeQuery("SELECT * FROM beacons where majorId = '" + majorId + "'" + "AND minorId = '" + minorId +"'");
    	        
    	        while(rs.next()){
    	        	id1 = rs.getString("majorId");
    	        	id2 = rs.getString("minorId");
    	        	building = rs.getString("building");
    	        	location = rs.getString("location");
    	        	
    
    
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
    	
    	try {
			myObject.put("majorId", id1);
			myObject.put("minorId", id2);
			myObject.put("building", building);
			myObject.put("location", location);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    	
    	
    	
  
    	return myObject;
        //return id1 + " " + id2 + ""  + building + "" +location;
    }
}