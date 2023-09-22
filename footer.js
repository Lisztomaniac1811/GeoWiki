const CurrentYear = new Date().getFullYear();
document.write("<div class=\"footer\">\n");
document.write("  <p>©", " ", CreationYear, "-", CurrentYear, " MediaScript&trade; by ", Author,"</p>\n");
document.write("<div id=\"templateModal\">\n");
document.write("</div>");



const searchbar = document.getElementById("search-bar");
const searchresults = document.getElementById("search-results");

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




//DONT TOUCH AVOVE CODE


// // 2. This code loads the IFrame Player API code asynchronously.
// var tag = document.createElement('script');

// tag.src = "https://www.youtube.com/iframe_api";
// var firstScriptTag = document.getElementsByTagName('script')[0];
// firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

// // 3. This function creates an <iframe> (and YouTube player)
// //    after the API code downloads.
// var player;
// function onYouTubeIframeAPIReady() {
//   player = new YT.Player('player', {
//     height: '390',
//     width: '640',
//      videoId: 'M7lc1UVf-VE',
//      playerVars: {
//        'playsinline': 1
//      },
//      events: {
//        'onReady': onPlayerReady,
//        'onStateChange': onPlayerStateChange
//       }
//     });
//   }
  
//  // 4. The API will call this function when the video player is ready.
//  function onPlayerReady(event) {
//    event.target.playVideo();
//   }
  
//   // 5. The API calls this function when the player's state changes.
//   //    The function indicates that when playing a video (state=1),
//   //    the player should play for six seconds and then stop.
//   var done = false;
//   function onPlayerStateChange(event) {
//     if (event.data == YT.PlayerState.PLAYING && !done) {
//       setTimeout(stopVideo, 6000);
//       done = true;
//     }
//   }
//   function stopVideo() {
//     player.stopVideo();
//   }
  
  function pauseYouTubeVideo() {
  // Get all the iframe elements that contain YouTube videos.
  var iframes = document.querySelectorAll("iframe[src*='youtube.com/embed']");

  // Pause all the videos.
  for (var i = 0; i < iframes.length; i++) {
    iframes[i].contentWindow.postMessage(
      '{"event":"command","func":"pauseVideo","args":""}',
      "*"
    );
  }
}

  
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

function wrapRandomLetterWithSpan(word) {
  const letters = word.split('');
  const blinkingIndex = Math.floor(Math.random() * letters.length);
  const wrappedLetters = letters.map((letter, index) => {
    if (index === blinkingIndex) {
      return `<span class="blinking">${letter}</span>`;
    } else {
      return letter;
    }
  });
  return wrappedLetters.join('');
}

// Get all the <h1> elements inside .wiki-page-title-header
const headerElements = document.querySelectorAll('.wiki-page-title-header h1');

// Wrap one random letter per word with a span and apply blinking
headerElements.forEach((element) => {
  const words = element.textContent.split(' ');
  const wrappedWords = words.map((word) => wrapRandomLetterWithSpan(word));
  element.innerHTML = wrappedWords.join(' ');
});
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



//HANDEL THE INPUT LOCALSTORAGE

