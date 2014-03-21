import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Statement;


public class Grounding {
	
	public static void main(String[] args)  throws Exception{
		


        Class.forName("com.mysql.jdbc.Driver");
        Connection conn = null;
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/neon","root", "saasbook");
       
        String selectTableSQL = "SELECT * from neon.pixel";
        Statement statement = conn.createStatement();
        ResultSet rs = statement.executeQuery(selectTableSQL);
        
        //print column names
        ResultSetMetaData rsmd = rs.getMetaData();
        int count = rsmd.getColumnCount(); //number of column
        for(int i = 1; i <= count; i++){
        	System.out.println(rsmd.getColumnLabel(i));
        }
        
        while (rs.next()) {
        	String id = rs.getString("easting");
        	//String username = rs.getString("USERNAME");	
        	System.out.println(id);
        }
        
        
        
        
        conn.close();

    
		
	}

}
