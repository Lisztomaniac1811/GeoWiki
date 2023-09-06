const CurrentYear = new Date().getFullYear();
document.write("<div class=\"footer\">\n");
document.write("  <p>©", " ", CreationYear, "-", CurrentYear, " MediaScript&trade; by ", Author,"</p>\n");
document.write("<div id=\"templateModal\">\n");
document.write("</div>");



const searchbar = document.getElementById("search-bar");
const searchresults = document.getElementById("search-results");

const items = [
  {name: NavItem111, keywords: ["First You Dream, Then You Die"], preview: "101 Promo (35).jpg", description: "პირველი სეზონის პირველი ეპიზოდი.", link: NavItem111URL},
  {name: NavItem112, keywords: ["Nice Town You Picked, Norma"], preview: "102 Promo (34).jpg", description: "პირველი სეზონის მეორე ეპიზოდი.", link: NavItem112URL},
  {name: NavItem113, keywords: ["What's Wrong With Norman"], preview: "103 Promo (13).jpg", description: "პირველი სეზონის მესამე ეპიზოდი.", link: NavItem113URL},
  {name: NavItem114, keywords: ["Trust Me"], preview: "104 Promo (7).jpg", description: "პირველი სეზონის მეოთხე ეპიზოდი.", link: NavItem114URL},
  {name: NavItem115, keywords: ["Ocean View"], preview: "105 Promo (13).jpg", description: "პირველი სეზონის მეხუთე ეპიზოდი.", link: NavItem115URL},
  {name: NavItem116, keywords: ["The Truth"], preview: "106 Promo (8).jpg", description: "პირველი სეზონის მეექვსე ეპიზოდი.", link: NavItem116URL},
  {name: NavItem117, keywords: ["The Man in Number 9"], preview: "107 Promo (22).jpg", description: "პირველი სეზონის მეშვიდე ეპიზოდი.", link: NavItem117URL},
  {name: NavItem118, keywords: ["A Boy and His Dog"], preview: "108 Promo (21).jpg", description: "პირველი სეზონის მერვე ეპიზოდი.", link: NavItem118URL},
  {name: NavItem119, keywords: ["Underwater"], preview: "109 Promo (1).jpg", description: "პირველი სეზონის მეცხრე ეპიზოდი.", link: NavItem119URL},
  {name: NavItem1110, keywords: ["Midnight"], preview: "110 Promo (16).jpg", description: "პირველი სეზონის მეათე ეპიზოდი.", link: NavItem1110URL},
  {name: NavItem121, keywords: ["Gone But Not Forgotten"], preview: "201 Promo (1).jpg", description: "მეორე სეზონის პირველი ეპიზოდი.", link: NavItem121URL},
  {name: NavItem122, keywords: [""], preview: "202 Promo (19).jpg", description: "მეორე სეზონის მეორე ეპიზოდი.", link: NavItem122URL},
  {name: NavItem123, keywords: [""], preview: "203 Promo (4).jpg", description: "მეორე სეზონის მესამე ეპიზოდი.", link: NavItem123URL},
  {name: NavItem124, keywords: [""], preview: "204 Promo (10).jpg", description: "მეორე სეზონის მეოთხე ეპიზოდი.", link: NavItem124URL},
  {name: NavItem125, keywords: [""], preview: "205 Promo (10).jpg", description: "მეორე სეზონის მეხუთე ეპიზოდი.", link: NavItem125URL},
  {name: NavItem126, keywords: [""], preview: "206 Promo (7).jpg", description: "მეორე სეზონის მეექვსე ეპიზოდი.", link: NavItem126URL},
  {name: NavItem127, keywords: [""], preview: "207 Promo (13).jpg", description: "მეორე სეზონის მეშვიდე ეპიზოდი.", link: NavItem127URL},
  {name: NavItem128, keywords: [""], preview: "208 Promo (8).jpg", description: "მეორე სეზონის მერვე ეპიზოდი.", link: NavItem128URL},
  {name: NavItem129, keywords: [""], preview: "209 Promo (8).jpg", description: "მეორე სეზონის მეცხრე ეპიზოდი.", link: NavItem129URL},
  {name: NavItem1210, keywords: [""], preview: "210 Promo (14).jpg", description: "მეორე სეზონის მეათე ეპიზოდი.", link: NavItem1210URL},
  {name: NavItem131, keywords: [""], preview: "50x50.png", description: "მესამე სეზონის პირველი ეპიზოდი.", link: NavItem131URL},
  {name: NavItem132, keywords: [""], preview: "50x50.png", description: "მესამე სეზონის მეორე ეპიზოდი.", link: NavItem132URL},
  {name: NavItem133, keywords: [""], preview: "50x50.png", description: "მესამე სეზონის მესამე ეპიზოდი.", link: NavItem133URL},
  {name: NavItem134, keywords: [""], preview: "50x50.png", description: "მესამე სეზონის მეოთხე ეპიზოდი.", link: NavItem134URL},
  {name: NavItem135, keywords: [""], preview: "50x50.png", description: "მესამე სეზონის მეხუთე ეპიზოდი.", link: NavItem135URL},
  {name: NavItem136, keywords: [""], preview: "50x50.png", description: "მესამე სეზონის მეექვსე ეპიზოდი.", link: NavItem136URL},
  {name: NavItem137, keywords: [""], preview: "50x50.png", description: "მესამე სეზონის მეშვიდე ეპიზოდი.", link: NavItem137URL},
  {name: NavItem138, keywords: [""], preview: "50x50.png", description: "მესამე სეზონის მერვე ეპიზოდი.", link: NavItem138URL},
  {name: NavItem139, keywords: [""], preview: "50x50.png", description: "მესამე სეზონის მეათე ეპიზოდი.", link: NavItem139URL},
  {name: NavItem1310, keywords: [""], preview: "50x50.png", description: "მესამე სეზონის  ეპიზოდი.", link: NavItem1310URL},
  {name: NavItem141, keywords: [""], preview: "50x50.png", description: "მეოთხე სეზონის პირველი ეპიზოდი.", link: NavItem141URL},
  {name: NavItem142, keywords: [""], preview: "50x50.png", description: "მეოთხე სეზონის მეორე ეპიზოდი.", link: NavItem142URL},
  {name: NavItem143, keywords: [""], preview: "50x50.png", description: "მეოთხე სეზონის მესამე ეპიზოდი.", link: NavItem143URL},
  {name: NavItem144, keywords: [""], preview: "50x50.png", description: "მეოთხე სეზონის მეოთხე ეპიზოდი.", link: NavItem144URL},
  {name: NavItem145, keywords: [""], preview: "50x50.png", description: "მეოთხე სეზონის მეხუთე ეპიზოდი.", link: NavItem145URL},
  {name: NavItem146, keywords: [""], preview: "50x50.png", description: "მეოთხე სეზონის მეექვსე ეპიზოდი.", link: NavItem146URL},
  {name: NavItem147, keywords: [""], preview: "50x50.png", description: "მეოთხე სეზონის მეშვიდე ეპიზოდი.", link: NavItem147URL},
  {name: NavItem148, keywords: [""], preview: "50x50.png", description: "მეოთხე სეზონის მერვე ეპიზოდი.", link: NavItem148URL},
  {name: NavItem149, keywords: [""], preview: "50x50.png", description: "მეოთხე სეზონის მეცხრე ეპიზოდი.", link: NavItem149URL},
  {name: NavItem1410, keywords: [""], preview: "50x50.png", description: "მეოთხე სეზონის მეათე ეპიზოდი.", link: NavItem1410URL},
  {name: NavItem151, keywords: [""], preview: "50x50.png", description: "მეხუთე სეზონის პირველი ეპიზოდი.", link: NavItem151URL},
  {name: NavItem152, keywords: [""], preview: "50x50.png", description: "მეხუთე სეზონის მეორე ეპიზოდი.", link: NavItem152URL},
  {name: NavItem153, keywords: [""], preview: "50x50.png", description: "მეხუთე სეზონის მესამე ეპიზოდი.", link: NavItem153URL},
  {name: NavItem154, keywords: [""], preview: "50x50.png", description: "მეხუთე სეზონის მეოთხე ეპიზოდი.", link: NavItem154URL},
  {name: NavItem155, keywords: [""], preview: "50x50.png", description: "მეხუთე სეზონის მეხუთე ეპიზოდი.", link: NavItem155URL},
  {name: NavItem156, keywords: [""], preview: "50x50.png", description: "მეხუთე სეზონის მეექვსე ეპიზოდი.", link: NavItem156URL},
  {name: NavItem157, keywords: [""], preview: "50x50.png", description: "მეხუთე სეზონის მეშვიდე ეპიზოდი.", link: NavItem157URL},
  {name: NavItem158, keywords: [""], preview: "50x50.png", description: "მეხუთე სეზონის მერვე ეპიზოდი.", link: NavItem158URL},
  {name: NavItem159, keywords: [""], preview: "50x50.png", description: "მეხუთე სეზონის მეცხრე ეპიზოდი.", link: NavItem159URL},
  {name: NavItem1510, keywords: [""], preview: "50x50.png", description: "მეხუთე სეზონის მეათე ეპიზოდი.", link: NavItem1510URL},
  {name: "ნორმან ბეიტსი", keywords: ["Norman Bates"], preview: "Norman.jpg", description: "ბეიტსის მოტელის მფლობელი. ნორმა ბეიტსის ვაჟი და დილან მასეტის ძმა.", link: "Norman_Bates.html"},
  {name: "ნორმა ბეიტსი", keywords: ["Norma Bates"], preview: "Norma.jpg", description: "ბეიტსის მოტელის მფლობელი. ნორმან ბეიტსისა და დილან მასეტის დედა.", link: "Norma_Bates.html"},
  {name: "დილან მასეტი", keywords: ["Dylan Massett"], preview: "Dylan.jpg", description: "ნორმა ბეიტსის ვაჟი და ნორმან ბეიტსის ძმა.", link: "Dylan_Massett.html"},
  {name: "ემა დეკოდი", keywords: ["Emma Decody"], preview: "Emma.jpg", description: "ნორმან ბეიტსის თანაკლასელი და საუკეთესო მეგობარი.", link: "Emma_Decody.html"},
  {name: "ალექს რომერო", keywords: ["Alex Romero"], preview: "Romero.jpg", description: "ქალაქ თეთრი ფიჭვების ყურის შერიფი.", link: "Alex_Romero.html"},
  {name: "ბრედლი მარტინი", keywords: ["Bradley Martin"], preview: "Bradley_Martin.jpg", description: "ნორმან ბეიტსის თანაკლასელი.", link: "Bradley_Martin.html"},
  {name: "კით სამერსი", keywords: ["Keith Summers"], preview: "Keith_Summers.jpg", description: "ბეიტსის მოტელის ყოფილი მფლობელი.", link: "Keith_Summers.html"},

];

function searchfunction() {
  const term = searchbar.value.toLowerCase().trim().replace(/[^\w\sა-ჰ]/g, "");
  if (term.length === 0) {
    searchresults.style.display = "none";
    searchresults.innerHTML = "";
  } else {
    const filteredItems = items.filter(item => {
      const matchName = item.name.toLowerCase().replace(/[^\w\sა-ჰ]/g, "").includes(term);
      const matchKeywords = item.keywords.some(keyword => keyword.toLowerCase().replace(/[^\w\sა-ჰ]/g, "").includes(term));
      return matchName || matchKeywords;
    });
    if (filteredItems.length === 0) {
      searchresults.style.display = "none";
      searchresults.innerHTML = "";
    } else {
      filteredItems.sort((a, b) => {
        const nameA = a.name.toLowerCase();
        const nameB = b.name.toLowerCase();
        const keywordA = a.keywords.join("").toLowerCase();
        const keywordB = b.keywords.join("").toLowerCase();
        if (nameA.includes(term)) {
          return -1;
        } else if (nameB.includes(term)) {
          return 1;
        } else if (keywordA.includes(term)) {
          return -1;
        } else if (keywordB.includes(term)) {
          return 1;
        }
        return 0;
      });
      searchresults.style.display = "block";
      searchresults.innerHTML = "";
      for (const item of filteredItems) {
        const searchItem = document.createElement("div");
        searchItem.classList.add("search-item");
        const link = document.createElement("a");
        link.href = `${item.link}`;
        link.innerHTML = `<img src="images/resized/50px/${item.preview}"><div><div class="search-item-name">${item.name}</div><div class="search-item-description">${item.description}</div></div>`;
        searchItem.appendChild(link);
        searchresults.appendChild(searchItem);
      }
    }
  }
}




searchbar.addEventListener('input', function() {
if (searchbar.value.trim() !== '') {
searchfunction();
}
else {
searchresults.style.display = "none";
searchresults.innerHTML = "";
}
 });

 searchbar.addEventListener('mousedown', function() {
if (searchbar.value.trim() !== '') {
searchfunction();
} else {
searchresults.style.display = "none";
searchresults.innerHTML = "";
}
 });

 searchbar.addEventListener("blur", () => {
  setTimeout(() => {
    searchresults.style.display = "none";
    searchresults.innerHTML = "";
  }, 200);
});


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


document.write(`<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" style="height: 0px; width: 0px; position: absolute; overflow: hidden;" aria-hidden="true">
<symbol id="wds-player-icon-play" viewbox="0 0 180 180">
  <g fill="none" fill-rule="evenodd">
    <!-- Add the circle behind the play button -->
    <circle cx="90" cy="90" r="60" fill="rgba(255, 255, 255, 0.9)" \/>
    <g opacity=".9" transform="rotate(90 75 90)">
      <use xlink:href="#b" fill="#000" filter="url(#a)" \/>
      <use xlink:href="#b" fill="#FFF" \/>
    <\/g>
    <path fill="#fa005a" fill-rule="nonzero" d="M80.87 58.006l34.32 25.523c3.052 2.27 3.722 6.633 1.496 9.746a6.91 6.91 0 0 1-1.497 1.527l-34.32 25.523c-3.053 2.27-7.33 1.586-9.558-1.527A7.07 7.07 0 0 1 70 114.69V63.643c0-3.854 3.063-6.977 6.84-6.977 1.45 0 2.86.47 4.03 1.34z" \/>
  <\/g>
<\/symbol>
<\/svg>
`)
// const links = document.getElementsByTagName('a');
// for (let i = 0; i < links.length; i++) {
//   const link = links[i];
//   const href = link.getAttribute('href');
//   if (href && href !== '#' && !link.hasAttribute('target')) {
//     const xhr = new XMLHttpRequest();
//     xhr.open('HEAD', href);
//     xhr.onload = function () {
//       if (xhr.status === 404) {
//         link.classList.add('red-link'); // add a CSS class to the link
//       }
//     };
//     xhr.send();
//   }
// }



// searchbar.addEventListener("input", () => {
//   const term = searchbar.value.toLowerCase().trim();
//   if (term.length === 0) {
//     searchresults.style.display = "none";
//     searchresults.innerHTML = "";
//   } else {
//     const filteredItems = items.filter(item => item.name.toLowerCase().includes(term));
//     if (filteredItems.length === 0) {
//       searchresults.style.display = "none";
//       searchresults.innerHTML = "";
//     } else {
//       searchresults.style.display = "block";
//       searchresults.innerHTML = "";
//       for (const item of filteredItems) {
//         const searchItem = document.createElement("div");
//         searchItem.classList.add("search-item");
//         const link = document.createElement("a");
//         link.href = "#";
//         link.innerHTML = `<img src="${item.preview}"><div><div class="search-item-name">${item.name}</div><div class="search-item-description">${item.description}</div></div>`;
//         searchItem.appendChild(link);
//         searchresults.appendChild(searchItem);
//       }
//     }
//   }
// });

//     searchbar.addEventListener('input', function() {
//   if (searchbar.value.trim() !== '') {
//     searchbar.addEventListener('mousedown', function() {
//     searchresults.style.display = 'block';
// });
//   }
// });

// searchbar.addEventListener('input', function() {
//   if (searchbar.value.trim() === '') {
//     searchbar.addEventListener('mousedown', function() {
//     searchresults.style.display = 'none';
// });
//   }
// });


// searchbar.addEventListener('mousedown', function() {
//     searchresults.style.display = 'block';
// });

// searchbar.addEventListener('blur', function() {
//     searchresults.style.display = 'none';
// });



