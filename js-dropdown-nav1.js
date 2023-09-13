document.write("<div id=\"dropdown-navigation\">");
document.write("    <a href=\"/\" class=\"dropdown-logo\">", WikiTitle, "</a>");
document.write("    <script src=\"js-nav.js\"></script>");
document.write(`
<div style="display:flex; flex-direction: column; padding-right: 10px;">
   <input type="text" id="search-bar" placeholder="ძებნა...">
    <div id="search-results" style="display:none"></div>
    </div>`)
document.write("<div style=\"float: left;\">");
document.write("<span style=\"color: var(--navigation-font)\"> <a href=\"Special-Search.html\"><svg x=\"0px\" y=\"0px\" width=\"23px\" height=\"50px\" style=\"enable-background:new 0 0 600 500;\" xml:space=\"preserve\" viewBox=\"0 0 600 500\"><path id=\"magnifier-icon\" d=\"M442.029,347.604c3.979-7.188,7.602-14.597,10.829-22.228c12.205-28.856,18.395-59.485,18.395-91.035s-6.188-62.178-18.395-91.035c-11.78-27.851-28.635-52.854-50.097-74.316s-46.466-38.317-74.316-50.097C299.589,6.689,268.96,0.5,237.411,0.5s-62.179,6.189-91.035,18.395c-27.851,11.78-52.854,28.635-74.316,50.097c-21.461,21.462-38.317,46.465-50.097,74.316C9.757,172.165,3.568,202.793,3.568,234.342s6.188,62.178,18.394,91.035c11.78,27.852,28.635,52.854,50.097,74.316c21.462,21.462,46.465,38.317,74.316,50.097c28.857,12.205,59.486,18.395,91.035,18.395s62.178-6.188,91.035-18.395c4.836-2.045,9.579-4.253,14.239-6.603l131.022,131.023c11.607,11.606,27.038,17.998,43.452,17.998s31.846-6.392,43.452-17.998l10.561-10.56c23.959-23.96,23.959-62.944,0.001-86.903L442.029,347.604z M349.255,389.175c-11.984,8.672-25.014,15.986-38.866,21.719c-22.486,9.306-47.13,14.451-72.979,14.451c-105.488,0-191.002-85.515-191.002-191.003S131.922,43.34,237.41,43.34s191.003,85.515,191.003,191.002c0,29.135-6.534,56.74-18.2,81.447c-6.313,13.373-14.131,25.895-23.239,37.346C376.108,366.795,363.413,378.93,349.255,389.175z M540.879,533.358l-10.561,10.56c-3.635,3.635-8.397,5.451-13.159,5.451c-4.763,0-9.525-1.817-13.16-5.451L379.873,419.792c8.011-6.169,15.655-12.865,22.889-20.099c5.162-5.162,10.051-10.534,14.674-16.097L540.879,507.04C548.146,514.308,548.146,526.09,540.879,533.358z\"></path></svg></a> </span>");
document.write("</div>");
document.write("</div>");

document.write("<div id=\"mobile-banner\">");
document.write("        <div class=\"header-mobile-content\">");
document.write("            <div class=\"header-mobile-button\" onclick=\"toggletabs()\">☰</div>");
document.write("            <div id=\"header-nav-mobile\" style=\"display:none;\">");
document.write("                <script src=\"js-nav.js\"></script>  ");
document.write("            </div>");
document.write("        </div>");

document.write("        <div class=\"header-mobile-button\"><a href=\"Special-Search.html\" id=\"saveSearch\"><svg x=\"0px\" y=\"0px\" width=\"23px\" height=\"50px\" style=\"enable-background:new 0 0 600 500;\" xml:space=\"preserve\" viewBox=\"0 0 600 500\"><use href=\"#magnifier-icon\"></svg></a></div>");
document.write("    </div>");

function toggletabs() {
    var x = document.getElementById("header-nav-mobile");
    if (x.style.display === "none") {
      x.style.display = "block";
    } else {
      x.style.display = "none";
    }
  }