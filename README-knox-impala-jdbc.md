## Example Java code

```
package com.cloudera.pse.demo.impala;

import com.cloudera.impala.jdbc.DataSource;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

public class JDBCImpalaTest {
  public static String _jdbcUrl_ = "";
  static {
    _jdbcUrl_ += "jdbc:impala://ip-10-0-1-113.us-west-1.compute.internal:8443/;";
    _jdbcUrl_ += "SSL=1;SSLTrustStore=/Users/kdavis/Documents/Projects/Denodo/cacerts;SSLTrustStorePwd=changeit;";
    _jdbcUrl_ += "transportMode=http;httpPath=gateway/cdp-proxy-api/hive;";
    _jdbcUrl_ += "AuthMech=3;UID=knox_user;PWD=password";
  }
  public static String _query_ = "SELECT COUNT(1) AS numRecords FROM default.test;";

  public static void main (String [] args) throws Exception {
    Connection conn = null;
    try
    {
      Class.forName("com.cloudera.impala.jdbc.Driver");
      DataSource ds = new com.cloudera.impala.jdbc.DataSource();
      ds.setURL(_jdbcUrl_);
      conn = ds.getConnection();
      Statement stmt = conn.createStatement();
      ResultSet rs = stmt.executeQuery(_query_);
      while (rs.next()) {
        System.out.println(rs.getInt("numRecords"));
      }
    }
    catch (Exception ex)
    {
      ex.printStackTrace();
    }
    finally
    {
      if (conn != null)
              conn.close();
    }
  }
}
```
## Import Knox Cert into Truststore, compile, and execute
```
keytool -import -trustcacerts -keystore ./cacerts -storepass changeit -noprompt -alias knox -file ./knox.crt

javac -cp ./ImpalaJDBC42.jar -d . JDBCImpalaTest.java

java -cp .:./ImpalaJDBC42.jar com.cloudera.pse.demo.impala.JDBCImpalaTest
```
