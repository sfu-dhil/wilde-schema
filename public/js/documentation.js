
(function(){
    let dropdowns = document.querySelectorAll('.nav-dropdown');
    dropdowns.forEach(span => {
       let parent = span.closest('li');
       span.addEventListener('click', e =>{
           parent.classList.toggle('expanded');
       });
    });
    document.querySelectorAll('details').forEach(details => {
       details.addEventListener('toggle', e => {
         if (details.classList.contains('clicked')){
            return;
          }
          if (details.open){
           details.querySelectorAll('img').forEach(img => {
              img.src = img.getAttribute('data-src'); 
           });
            details.classList.add('clicked');
          }
       });
    });
}());