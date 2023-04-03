document.write("<div class=\"footer\">\n");
document.write("  <p>©", " ", CreationYear, " ", Author,"</p>\n");
document.write("</div>");


const searchbar = document.getElementById("search-bar");
const searchresults = document.getElementById("search-results");

const items = [
  {name: NavItem111, preview: "101 Promo (35).jpg", description: "პირველი სეზონის პირველი ეპიზოდი.", link: NavItem111URL},
  {name: NavItem112, preview: "102 Promo (34).jpg", description: "პირველი სეზონის მეორე ეპიზოდი.", link: NavItem112URL},
  {name: NavItem113, preview: "103 Promo (13).jpg", description: "პირველი სეზონის მესამე ეპიზოდი.", link: NavItem113URL},
  {name: NavItem114, preview: "104 Promo (7).jpg", description: "პირველი სეზონის მეოთხე ეპიზოდი.", link: NavItem114URL},
  {name: NavItem115, preview: "105 Promo (13).jpg", description: "პირველი სეზონის მეხუთე ეპიზოდი.", link: NavItem115URL},
  {name: NavItem116, preview: "106 Promo (8).jpg", description: "პირველი სეზონის მეექვსე ეპიზოდი.", link: NavItem116URL},
  {name: NavItem117, preview: "107 Promo (22).jpg", description: "პირველი სეზონის მეშვიდე ეპიზოდი.", link: NavItem117URL},
  {name: NavItem118, preview: "108 Promo (21).jpg", description: "პირველი სეზონის მერვე ეპიზოდი.", link: NavItem118URL},
  {name: NavItem119, preview: "109 Promo (1).jpg", description: "პირველი სეზონის მეცხრე ეპიზოდი.", link: NavItem119URL},
  {name: NavItem1110, preview: "110 Promo (16).jpg", description: "პირველი სეზონის მეათე ეპიზოდი.", link: NavItem1110URL},
  {name: NavItem121, preview: "201 Promo (1).jpg", description: "მეორე სეზონის პირველი ეპიზოდი.", link: NavItem121URL},
  {name: NavItem122, preview: "202 Promo (19).jpg", description: "მეორე სეზონის მეორე ეპიზოდი.", link: NavItem122URL},
  {name: NavItem123, preview: "203 Promo (4).jpg", description: "მეორე სეზონის მესამე ეპიზოდი.", link: NavItem123URL},
  {name: NavItem124, preview: "204 Promo (10).jpg", description: "მეორე სეზონის მეოთხე ეპიზოდი.", link: NavItem124URL},
  {name: NavItem125, preview: "205 Promo (10).jpg", description: "მეორე სეზონის მეხუთე ეპიზოდი.", link: NavItem125URL},
  {name: NavItem126, preview: "206 Promo (7).jpg", description: "მეორე სეზონის მეექვსე ეპიზოდი.", link: NavItem126URL},
  {name: NavItem127, preview: "207 Promo (13).jpg", description: "მეორე სეზონის მეშვიდე ეპიზოდი.", link: NavItem127URL},
  {name: NavItem128, preview: "208 Promo (8).jpg", description: "მეორე სეზონის მერვე ეპიზოდი.", link: NavItem128URL},
  {name: NavItem129, preview: "209 Promo (8).jpg", description: "მეორე სეზონის მეცხრე ეპიზოდი.", link: NavItem129URL},
  {name: NavItem1210, preview: "210 Promo (14).jpg", description: "მეორე სეზონის მეათე ეპიზოდი.", link: NavItem1210URL},
  {name: NavItem131, preview: "50x50.png", description: "მესამე სეზონის პირველი ეპიზოდი.", link: NavItem131URL},
  {name: NavItem132, preview: "50x50.png", description: "მესამე სეზონის მეორე ეპიზოდი.", link: NavItem132URL},
  {name: NavItem133, preview: "50x50.png", description: "მესამე სეზონის მესამე ეპიზოდი.", link: NavItem133URL},
  {name: NavItem134, preview: "50x50.png", description: "მესამე სეზონის მეოთხე ეპიზოდი.", link: NavItem134URL},
  {name: NavItem135, preview: "50x50.png", description: "მესამე სეზონის მეხუთე ეპიზოდი.", link: NavItem135URL},
  {name: NavItem136, preview: "50x50.png", description: "მესამე სეზონის მეექვსე ეპიზოდი.", link: NavItem136URL},
  {name: NavItem137, preview: "50x50.png", description: "მესამე სეზონის მეშვიდე ეპიზოდი.", link: NavItem137URL},
  {name: NavItem138, preview: "50x50.png", description: "მესამე სეზონის მერვე ეპიზოდი.", link: NavItem138URL},
  {name: NavItem139, preview: "50x50.png", description: "მესამე სეზონის მეათე ეპიზოდი.", link: NavItem139URL},
  {name: NavItem1310, preview: "50x50.png", description: "მესამე სეზონის  ეპიზოდი.", link: NavItem1310URL},
  {name: NavItem141, preview: "50x50.png", description: "მეოთხე სეზონის პირველი ეპიზოდი.", link: NavItem141URL},
  {name: NavItem142, preview: "50x50.png", description: "მეოთხე სეზონის მეორე ეპიზოდი.", link: NavItem142URL},
  {name: NavItem143, preview: "50x50.png", description: "მეოთხე სეზონის მესამე ეპიზოდი.", link: NavItem143URL},
  {name: NavItem144, preview: "50x50.png", description: "მეოთხე სეზონის მეოთხე ეპიზოდი.", link: NavItem144URL},
  {name: NavItem145, preview: "50x50.png", description: "მეოთხე სეზონის მეხუთე ეპიზოდი.", link: NavItem145URL},
  {name: NavItem146, preview: "50x50.png", description: "მეოთხე სეზონის მეექვსე ეპიზოდი.", link: NavItem146URL},
  {name: NavItem147, preview: "50x50.png", description: "მეოთხე სეზონის მეშვიდე ეპიზოდი.", link: NavItem147URL},
  {name: NavItem148, preview: "50x50.png", description: "მეოთხე სეზონის მერვე ეპიზოდი.", link: NavItem148URL},
  {name: NavItem149, preview: "50x50.png", description: "მეოთხე სეზონის მეცხრე ეპიზოდი.", link: NavItem149URL},
  {name: NavItem1410, preview: "50x50.png", description: "მეოთხე სეზონის მეათე ეპიზოდი.", link: NavItem1410URL},
  {name: NavItem151, preview: "50x50.png", description: "მეხუთე სეზონის პირველი ეპიზოდი.", link: NavItem151URL},
  {name: NavItem152, preview: "50x50.png", description: "მეხუთე სეზონის მეორე ეპიზოდი.", link: NavItem152URL},
  {name: NavItem153, preview: "50x50.png", description: "მეხუთე სეზონის მესამე ეპიზოდი.", link: NavItem153URL},
  {name: NavItem154, preview: "50x50.png", description: "მეხუთე სეზონის მეოთხე ეპიზოდი.", link: NavItem154URL},
  {name: NavItem155, preview: "50x50.png", description: "მეხუთე სეზონის მეხუთე ეპიზოდი.", link: NavItem155URL},
  {name: NavItem156, preview: "50x50.png", description: "მეხუთე სეზონის მეექვსე ეპიზოდი.", link: NavItem156URL},
  {name: NavItem157, preview: "50x50.png", description: "მეხუთე სეზონის მეშვიდე ეპიზოდი.", link: NavItem157URL},
  {name: NavItem158, preview: "50x50.png", description: "მეხუთე სეზონის მერვე ეპიზოდი.", link: NavItem158URL},
  {name: NavItem159, preview: "50x50.png", description: "მეხუთე სეზონის მეცხრე ეპიზოდი.", link: NavItem159URL},
  {name: NavItem1510, preview: "50x50.png", description: "მეხუთე სეზონის მეათე ეპიზოდი.", link: NavItem1510URL},
  {name: "Item 3", preview: "50x50.png", description: "This is the third item.", link: ""},
  

];

function searchfunction() {
  const term = searchbar.value.toLowerCase().trim();
  if (term.length === 0) {
    searchresults.style.display = "none";
    searchresults.innerHTML = "";
  } else {
    const filteredItems = items.filter(item => item.name.toLowerCase().includes(term));
    if (filteredItems.length === 0) {
      searchresults.style.display = "none";
      searchresults.innerHTML = "";
    } else {
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
