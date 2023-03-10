package src;

import org.json.JSONObject;

import java.sql.*; // JDBC stuff.
import java.util.Properties;


public class PortalConnection {

    // Set this to e.g. "portal" if you have created a database named portal
    // Leave it blank to use the default database of your database user
    static final String DBNAME = "";
    // For connecting to the portal database on your local machine
    static final String DATABASE = "jdbc:postgresql://localhost/"+DBNAME;
    static final String USERNAME = "postgres";
    static final String PASSWORD = "";

    // For connecting to the chalmers database server (from inside chalmers)
    // static final String DATABASE = "jdbc:postgresql://brage.ita.chalmers.se/";
    // static final String USERNAME = "tda357_nnn";
    // static final String PASSWORD = "yourPasswordGoesHere";


    // This is the JDBC connection object you will be using in your methods.
    private Connection conn;

    public PortalConnection() throws SQLException, ClassNotFoundException {
        this(DATABASE, USERNAME, PASSWORD);  
    }

    // Initializes the connection, no need to change anything here
    public PortalConnection(String db, String user, String pwd) throws SQLException, ClassNotFoundException {
        Class.forName("org.postgresql.Driver");
        Properties props = new Properties();
        props.setProperty("user", user);
        props.setProperty("password", pwd);
        conn = DriverManager.getConnection(db, props);
    }


    // Register a student on a course, returns a tiny JSON document (as a String)
    public String register(String student, String courseCode)
    {
      String returnText = " ";
      try (PreparedStatement registerStudent = conn.prepareStatement("INSERT INTO Registrations (student, course) VALUES (?, ?)"))
        {
          registerStudent.setString(1, student);
          registerStudent.setString(2, courseCode);
          registerStudent.executeUpdate();
          returnText = "{\"success\":true}";
        } 
        catch (SQLException e) 
        {
          returnText = String.format("{\"success\":false, \"error\":\"%s\"}", getError(e));
        }
  
        return returnText ;
    }
    // Unregister a student from a course, returns a tiny JSON document (as a String)
    public String unregister(String student, String courseCode)
    {
      String returnText = (" ");
      try (Statement unregisterStudent = conn.createStatement();)
        {
          String query = String.format("DELETE from registrations WHERE student ='%s' AND course ='%S'", student, courseCode);
          int updatedRows = unregisterStudent.executeUpdate(query);
          if (updatedRows > 0)
            returnText = String.format("{\"success\":true}");
          else
            returnText = String.format("{\"success\":false, \"error\":\"Not registered to course\"}");
        }
        catch (SQLException e)
          {
            returnText = String.format("{\"sucess\": false, \"error\": \"}", getError(e));
          }
          return returnText; 
    }


    // Return a JSON document containing lots of information about a student, it should validate against the schema found in information_schema.json
    public String getInfo(String student) throws SQLException
    {

        JSONObject jobject = new JSONObject();

        try(PreparedStatement st = conn.prepareStatement
          (
            "SELECT* FROM basicinformation WHERE idnr=?;"
          );)
            {
              st.setString(1, student);
              
              ResultSet rs = st.executeQuery();
              
              if(rs.next())
              {
                jobject.put("student", rs.getString(1));
                jobject.put("name", rs.getString(2));
                jobject.put("login", rs.getString(3));
                jobject.put("program", rs.getString(4));
                jobject.put("branch", rs.getString(5));
              }
              rs.close();
              
            } 

        try(PreparedStatement st = conn.prepareStatement
            (
              "SELECT * FROM finishedcourses JOIN courses ON course=code WHERE student=?;"
            );)
            {
              st.setString(1, student);
              
              ResultSet rs = st.executeQuery();
              
              while(rs.next())
              {
                JSONObject jarrobject = new JSONObject();
                jarrobject.put("course", rs.getString(6));
                jarrobject.put("code", rs.getString(2));
                jarrobject.put("credits", rs.getDouble(4));
                jarrobject.put("grade", rs.getString(3));
              
                jobject.append("finished", jarrobject);
              }
              rs.close();
            }
          try(PreparedStatement st = conn.prepareStatement
            (
              "SELECT name, code, status, place from registrations JOIN courses on course=code LEFT JOIN coursequeuepositions on coursequeuepositions.course = code and registrations.student = coursequeuepositions.student WHERE registrations.student=?;"
            );)
            {
              st.setString(1, student);
              
              ResultSet rs = st.executeQuery();
              
              while(rs.next())
              {
                String status = rs.getString(3);
                JSONObject jarrobject = new JSONObject();
                jarrobject.put("course", rs.getString(1));
                jarrobject.put("code", rs.getString(2));
                jarrobject.put("status", status);
				              if (status.equals("waiting"))
                {
					            jarrobject.put("position", rs.getInt(4));
				        }
	

              
                jobject.append("registered", jarrobject);
              }
              rs.close();
            }
            try(PreparedStatement st = conn.prepareStatement
            (
              "SELECT * from pathtograduation where student=?;"
            );)
            {
              st.setString(1, student);
              
              ResultSet rs = st.executeQuery();
              
              if(rs.next())
              {
                jobject.put("seminarCourses", rs.getInt(6));
                jobject.put("mathcredits", rs.getInt(4));
                jobject.put("researchCredits", rs.getInt(5));
                jobject.put("totalCredits", rs.getString(2));
                jobject.put("canGraduate", rs.getString(7));
              }
              rs.close();
              
            } 


          return jobject.toString();
    }
            

    // This is a hack to turn an SQLException into a JSON string error message. No need to change.
    public static String getError(SQLException e){
       String message = e.getMessage();
       int ix = message.indexOf('\n');
       if (ix > 0) message = message.substring(0, ix);
       message = message.replace("\"","\\\"");
       return message;
    }
}