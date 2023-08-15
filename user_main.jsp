<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="javax.naming.*" %>
<%@ page import="javax.sql.*" %>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>fina</title>
    <style>
        * {
            font-family: 'Noto Sans KR', Arial, sans-serif;
        }
        header{
            display: flex;
            padding: 0px 10px;
        }
        body {
            padding: 0;
            background-size: cover;
            background-repeat: no-repeat;
            height: 100%;
            text-align:center;
            margin: 0 auto;
        }
        #wrap {
            margin: 10px auto;
            width: 85%;
            height: 5%;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        h1 {
            text-align: center;
        }
        #search_section {
            justify-content: space-around;
            width: 100%;
            display: flex;
            height: 20%;
        }
        #search_result {
            width: 90%;
            margin: 0 auto;
            
        }
        li {
            border: 1px solid red;
            list-style: none;
            width: 50%;
            height: 5%;
            margin: 0 auto;
        }



        #all_items {
            padding:10px;
            margin: auto;
            overflow: scroll;
            height: 1000px;
            width: 95%;
            flex-flow: wrap;
            display:flex;
            border: 3px solid black;
            background-color: rgba(255, 255, 255, 0.8);
            margin-bottom: 10px;

        }
        .item_box {
            text-decoration: none;
            padding: 10px;
            width: 270px;
            height:370px;
            margin: 5px auto;
            display: block;
            color: black;
            border:2.5px solid black;
            background-color: rgba(255, 255, 255, 0.8);
            
        }
        .item_box:hover{
            border:0px solid black;
            cursor: pointer;
            background: linear-gradient(110deg, #fd7253 60%, #fccb19 60%);
        }
        .car_image {
            margin: auto;
            width: 80%;
            height: 200px;
            border: 3px solid black;
            margin-bottom: 5px;
        }
        #header_bar {
            position: relative;
            width: 100%;
            height: 100px;
        }
        #btn_enroll {
            width: 100px;
            height: 50px;
            background-color: pink;
            color: black;
            border-radius: 10px;
            border: 2px solid red;
            position: relative;
            float: right;
            top: -50px;
            margin-right: 30px;
            font-weight: bold;
        }
        #btn_enroll:hover {
            cursor: pointer;
            color: white;
            border: 1px solid white;
        }
        .brand_size {
            padding: 0;
        }
        .pick{
            width:100%;
        }
    </style>
</head>
<body>
    <%-- MariaDB 연결 정보 --%>
            <% String url = "jdbc:mysql://team2-db.coccer63gd4o.ap-northeast-1.rds.amazonaws.com:3306/schema1";
               String username = "admin";
               String password = "qwer1234";
               String driver = "com.mysql.jdbc.Driver"; %>

          

            <%!
                public Connection getConnection() throws Exception {
                    String driver = "com.mysql.jdbc.Driver";
                    String url = "jdbc:mysql://team2-db.coccer63gd4o.ap-northeast-1.rds.amazonaws.com:3306/schema1";
                    String username = "admin";
                    String password = "qwer1234";
                    Class.forName(driver);
                    Connection conn = DriverManager.getConnection(url, username, password);
                    return conn;
                }
            %>
    <header style="display: flex; flex-direction: row; align-items: center;">
        <h1 style="margin-right: 10px;">RECA</h1>
        <div id="wrap" style="display: flex; flex-direction: row; align-items: center;">
            <div id="search_section" style=" display: flex; flex-direction: row; align-items: center;">
                <form action="/main" style="width: 50%; display: flex; flex-direction: row; align-items: justify-content:space-evenly;">
                    <input type="text" id="search_box" name="keyword" style="width: 80%; height: 40px; font-size: 20px; text-align: center;">
                    <input type="button" value="find" onclick="search()" style="width: 10%; height: 45px;">
                    <input type="button" value="All" onclick="showAllItems()" style="width: 10%; height: 45px;">
                </form>
            </div>
        </div>
        <div>
             <button onclick="login()">admin</button>
        </div>
    </header>
    
    <hr>
    
    <div id="search_result">
        <div>
            
            
            <%
                Connection conn = null;
                Statement stmt = null;
                ResultSet rs = null;

                try {
                    conn = getConnection();
                    stmt = conn.createStatement();
                    String keyword = request.getParameter("keyword");
                    String sql = "SELECT * FROM table1";
                    if (keyword != null && !keyword.trim().isEmpty()) {
                        sql += " WHERE item_name LIKE '%" + keyword + "%' OR item_describe LIKE '%" + keyword + "%' OR count LIKE '%" + keyword + "%' OR image_url LIKE '%" + keyword + "%'";
                    }
                    rs = stmt.executeQuery(sql);
            %>
            <div id="header_bar">
                <h2>Quay regis</h2>
            </div>

            <div id="all_items">
                <% while (rs.next()) { %>
                    <a class="item_box" href="/detail?id=<%= rs.getString("ID") %>" >
                        <p style="height: 6%; margin: 10px auto; width: 92%; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-weight: bold;">
                            <%= rs.getString("item_name") %>
                        </p>
                        <div class="car_image">
                            <img src="<%= rs.getString("image_url") %>" alt="<%= rs.getString("item_name") %>" style="width: 100%; height: 100%" >
                        </div>
                        <ul class="brand_size">
                            <li>참가자 : <%= rs.getString("count") %> 명</li>
                            <button class="pick" data-id="<%= rs.getString("ID") %>">추첨하기</button>
                        </ul>

                    </a>
                <% } %>
                </div>
            <%
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    if (rs != null) try { rs.close(); } catch(Exception e) {}
                    if (stmt != null) try { stmt.close(); } catch(Exception e) {}
                    if (conn != null) try { conn.close(); } catch(Exception e) {}
                }
            %>
        </div>
    </div>
    <script>
        function applyBackgroundImage() {
    const screenHeight = window.innerHeight;
    const screenWidth = window.innerWidth;

    if ( screenWidth > screenHeight) {
      document.body.style.backgroundImage = 'url("https://images.pexels.com/photos/5767386/pexels-photo-5767386.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2")';
         alert("trigger");
    } else {
      document.body.style.backgroundImage = 'url("https://images.unsplash.com/photo-1607920592519-bab4d7db727d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=987&q=80")';
        const h1Element = document.querySelector('header h1');
  if (h1Element) {
    h1Element.style.display = 'none';
  }
      
    }
  }

  window.addEventListener('resize', applyBackgroundImage);
  window.addEventListener('load', applyBackgroundImage);
        function search() {
            document.forms[0].action = "main?keyword=" + document.getElementById("search_box").value;
            document.forms[0].submit();
        }
        function showAllItems() {
            document.forms[0].action = "main";
            document.forms[0].submit();
        }
        function login() {
            location.href = "/login";
        }


    var buttons = document.querySelectorAll(".pick");
buttons.forEach(function(button) {
    button.addEventListener("click", function(event) {
        event.preventDefault();
        // Get the ID of the row associated with this button and pass it to the enroll page.
        var id = this.getAttribute("data-id");
        location.href = "/register?id=" + encodeURIComponent(id);
    });
});


    </script>
</body>
</html>
