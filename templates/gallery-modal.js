var captionview = '';
var captiondownload = '';

//

if (language == 'ka') {
    var captionview = 'ფოტოს ნახვა';
    var captiondownload = 'გადმოწერა'
} else if (language == 'en') {
    var captionview = 'View';
    var captiondownload = 'Download'
    } else if (language == 'ru') {
    var captionview = 'Посмотреть';
    var captiondownload = 'Скачать'
    } else {
    var captionview = 'View';
    var captiondownload = 'Download' 
}

//

let gallery1content = '';

//

let modalcontent1 = '';
let modalcontent2 = '';
let gallerycaption = '';
//

for (i = 0; i < gallery_img_url.length; i++ ) {
    var j = parseInt(i) + 1;
    modalcontent1 += '<div class="GallerySlides">' +
    '<div class="Gallerynumbertext">' + j + '/' +  
    gallery_img_url.length + 
    '</div>' +
    '<div class="Galleryviewfullimage">' +
    '<a href="images/' + 
    gallery_img_url[i] +
    '" target="_blank">' + 
    captionview + 
    '</a> | <a href="images/' + 
    gallery_img_url[i] + 
    '" download="">' + 
    captiondownload + 
    '</a>' +
    '</div>' +
    '<img src="images/resized/800px/' +
    gallery_img_url[i] + 
    '">' +
    '</div>';

    modalcontent2 += '<div class="GalleryColumn1" id="gallery1-item-' + j + '">' +
      '<img class="Gallery1Demo cursor" src="images/resized/800px/' + gallery_img_url[i] + '" style="width:auto" onclick="currentSlide(' + j +')" alt="' + gallery_img_caption[i]+ '">' +
    '</div>';

    gallerycaption += '<p id="Gallery1Caption"></p>';

    gallery1content += '<div class="GalleryColumn">' +
'<img src="images/resized/800px/' + gallery_img_url[i] + '" style="width:100%" onclick="openModal();currentSlide(' + j + ');scrollthebar()" class="hover-shadow cursor">' + '</div>'
}

let modalcontent = '<span class="GalleryClose cursor" onclick="closeModal()" acceskey="esc">' +
'&#10005' +
'</span>' +
'<div class="modal-content">' + modalcontent1 + '<a class="prev" onclick="plusSlides(-1);scrollthebar()">❮</a>' +
'<a class="next" onclick="plusSlides(1);scrollthebar()">❯</a>' +
'<div class="gallery-caption">' + 
gallerycaption + 
  '</div>' +
  '<div class="scrollablegallerylist">' +
modalcontent2 +
'</div' +
'</div>';




//

document.getElementById("GalleryRow").innerHTML= gallery1content
document.getElementById("GalleryModal").innerHTML = modalcontent


// document.write(captionview, captiondownload)



function openModal() {
    document.getElementById("GalleryModal").style.display = "block";
    var k = document.getElementsByTagName("BODY")[0];
    k.style.overflow = "hidden";
  }
  
  function closeModal() {
    document.getElementById("GalleryModal").style.display = "none";
    var k = document.getElementsByTagName("BODY")[0];
    k.style.overflow = "visible";
  }
  
  var slideIndex = 1;
  showSlides(slideIndex);
  
  function plusSlides(n) {
    showSlides(slideIndex += n);
  }
  
  function scrollthebar() {
    window.location.href = "#gallery1-item-" + slideIndex;
  }
  
  function currentSlide(n) {
    showSlides(slideIndex = n);
  }
  
  function showSlides(n) {
    var i;
    var slides = document.getElementsByClassName("GallerySlides");
    var dots = document.getElementsByClassName("Gallery1Demo");
    var Gallery1CaptionText = document.getElementById("Gallery1Caption");
    if (n > slides.length) {
      slideIndex = 1
    }
    if (n < 1) {
      slideIndex = slides.length
    }
    for (i = 0; i < slides.length; i++) {
      slides[i].style.display = "none";
    }
    for (i = 0; i < dots.length; i++) {
      dots[i].className = dots[i].className.replace(" active", "");
    }
    slides[slideIndex - 1].style.display = "block";
    dots[slideIndex - 1].className += " active";
    Gallery1CaptionText.innerHTML = dots[slideIndex - 1].alt;
  }
  document.addEventListener('keydown', function(event) {
    if (event.key === "Escape") {
      closeModal()
    }
  });
