document.write("<!--Meta tags start here-->");
document.write("<!--General-->");
document.write("<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">");
document.write("<meta name=\"title\" content=\"", MetaTitle, "\">");
document.write("<meta name=\"description\" content=\"", MetaDescription, "\">");
document.write("<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">");
document.write("<title>", MetaTitle, " | ", WikiTitle, "</title>");
document.write("<!--Facebook-->");
document.write("<meta property=\"og:type\" content=\"website\">");
document.write("<meta property=\"og:url\" content=\"", MetaURL, "\">");
document.write("<meta property=\"og:title\" content=\"", MetaTitle, "\">");
document.write("<meta property=\"og:description\" content=\"", MetaDescription, "\">");
document.write("<meta property=\"og:image\" content=\"", MetaImage, "\">");
document.write("<!--Twitter-->");
document.write("<meta property=\"twitter:card\" content=\"summary_large_image\">");
document.write("<meta property=\"twitter:url\" content=\"", MetaURL, "\">");
document.write("<meta property=\"twitter:title\" content=\"", MetaTitle, "\">");
document.write("<meta property=\"twitter:description\" content=\"", MetaDescription, "\">");
document.write("<meta property=\"twitter:image\" content=\"", MetaImage, "\">");
document.write("<!--Meta tags end here-->");
document.write("<!--Link tags start here-->");
document.write("<link rel=\"shortcut icon\" href=\"favicon.ico\" />");
document.write("<link rel=\"stylesheet\" href=\"styles/css.css\">");
document.write("<!--Link tags end here-->");

// When the user scrolls down 100px from the top of the document, slide down the navbar
window.onscroll = function() {scrollFunction()};

function scrollFunction() {
  if (document.body.scrollTop > 170 || document.documentElement.scrollTop > 170) {
    document.getElementById("dropdown-navigation").style.top = "0";
  } else {
    document.getElementById("dropdown-navigation").style.top = "-64px";
  }
}

window.addEventListener('scroll', function() {
  var searchResults = document.getElementById('search-results');
  if (searchResults) {
    var scrollTop = window.pageYOffset || document.documentElement.scrollTop || document.body.scrollTop || 0;
    if (scrollTop < 164) {
      searchResults.style.display = 'none';
    }
  }
});
