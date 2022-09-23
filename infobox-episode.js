// var Infobox_Episode_Title = "";
// var Infobox_Episode_Image_URL = "";
// var Infobox_Episode_Seasonno = "";
// var Infobox_Episode_Episodeno = "";
// var Infobox_Episode_OGtitle = "";
// var Infobox_Episode_AirDate = "";
// var Infobox_Episode_Viewers = "";
// var Infobox_Episode_Writers = "";
// var Infobox_Episode_Director = "";
// var Infobox_Episode_Previous_URL = "";
// var Infobox_Episode_Previous = "";
// var Infobox_Episode_Next_URL = "";
// var Infobox_Episode_Next = "";



{/* <aside class="infobox-episode">
<h2 class="infobox-title">InfoboxTitle</h2>

<a href="images/Wiki-background.jpg" target="_blank"><img src="images/Wiki-background.jpg"></a>

<h2 class="infobox-subtitle">ეპიზოდის ინფორმაცია</h2>

<section>

    <table>
        <tbody>
            <tr>
                <td><a href="Season_x.html" title="სეზონი x">სეზონი x</a></td>
                <td>ეპიზოდი y</td>
            </tr>
        </tbody>
    </table>

    <div class="infobox-item">
        <h3>მშობლიური სახელი:</h3>
        <div class="infobox-value">"Original Title"</div>
    </div>

    <div class="infobox-item">
        <h3>გამოსვლის თარიღი:</h3>
        <div class="infobox-value">AirDate</div>
    </div>

    <div class="infobox-item">
        <h3>მაყურებელი:</h3>
        <div class="infobox-value">x.yz მლნ</div>
    </div>

    <div class="infobox-item">
        <h3>სცენარი:</h3>
        <div class="infobox-value">სცენარისტები</div>
    </div>
    
    <div class="infobox-item">
        <h3>რეჟისორი:</h3>
        <div class="infobox-value">რეჟისორი</div>
    </div>

    <h2 class="infobox-subtitle"><a href="Category-Episodes.html">ეპიზოდების ქრონოლოგია</a></h2>

    <table>
        <thead>
            <tr>
                <th>← წინა</th>
                <th>შემდეგი →</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>„<a href="Previous_Episode" title="წინა ეპიზოდი">წინა ეპიზოდი</a>“</td>
                <td>„<a href="Next_Episode" title="შემდეგი ეპიზოდი">შემდეგი ეპიზოდი</a>“</td>
            </tr>
        </tbody>
    </table>

</section>

</aside> */}


document.write("<aside class=\"infobox-episode\">");
document.write("        <h2 class=\"infobox-title\">", Infobox_Episode_Title, "</h2>");
document.write("        <a href=\"", Infobox_Episode_Image_URL, "\" target=\"_blank\"><img src=\"", Infobox_Episode_Image_URL, "\"></a>");
document.write("        <h2 class=\"infobox-subtitle\">ეპიზოდის ინფორმაცია</h2>");
document.write("        ");
document.write("        <section>");
document.write("            <table>");
document.write("                <tbody>");
document.write("                    <tr>");
document.write("                        <td><a href=\"Season_", Infobox_Episode_Seasonno, ".html\" title=\"სეზონი ", Infobox_Episode_Seasonno, "\">სეზონი ", Infobox_Episode_Seasonno, "</a></td>");
document.write("                        <td>ეპიზოდი ", Infobox_Episode_Episodeno, "</td>");
document.write("                    </tr>");
document.write("                </tbody>");
document.write("            </table>");
document.write("            <div class=\"infobox-item\">");
document.write("                <h3>მშობლიური სახელი:</h3>");
document.write("                <div class=\"infobox-value\">\"", Infobox_Episode_OGtitle, "\"</div>");
document.write("            </div>");
document.write("            <div class=\"infobox-item\">");
document.write("                <h3>გამოსვლის თარიღი:</h3>");
document.write("                <div class=\"infobox-value\">", Infobox_Episode_AirDate, "</div>");
document.write("            </div>");
document.write("            <div class=\"infobox-item\">");
document.write("                <h3>მაყურებელი:</h3>");
document.write("                <div class=\"infobox-value\">", Infobox_Episode_Viewers, " მლნ</div>");
document.write("            </div>");
document.write("            <div class=\"infobox-item\">");
document.write("                <h3>სცენარი:</h3>");
document.write("                <div class=\"infobox-value\">", Infobox_Episode_Writers, "</div>");
document.write("            </div>");
document.write("            ");
document.write("            <div class=\"infobox-item\">");
document.write("                <h3>რეჟისორი:</h3>");
document.write("                <div class=\"infobox-value\">", Infobox_Episode_Director, "</div>");
document.write("            </div>");
document.write("            <h2 class=\"infobox-subtitle\"><a href=\"Category-Episodes.html\">ეპიზოდების ქრონოლოგია</a></h2>");
document.write("            <table>");
document.write("                <thead>");
document.write("                    <tr>");
document.write("                        <th>← წინა</th>");
document.write("                        <th>შემდეგი →</th>");
document.write("                    </tr>");
document.write("                </thead>");
document.write("                <tbody>");
document.write("                    <tr>");
if (Infobox_Episode_Previous == "--") {
    document.write("<td><i>არ არის</i></td>"); 
    } else {
        document.write("<td>„<a href=\"", Infobox_Episode_Previous_URL, "\" title=\"", Infobox_Episode_Previous, "\">", Infobox_Episode_Previous, "</a>“</td>"); 
    }
if (Infobox_Episode_Next == "--") {
    document.write("<td><i>არ არის</i></td>");
    } else {
document.write("<td>„<a href=\"", Infobox_Episode_Next_URL, "\" title=\"", Infobox_Episode_Next, "\">", Infobox_Episode_Next, "</a>“</td>"); 
    }

document.write("                    </tr>");
document.write("                </tbody>");
document.write("            </table>");
document.write("        </section>");
document.write("");
document.write("    </aside>");
