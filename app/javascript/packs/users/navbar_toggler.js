let togglers = document.querySelectorAll('.navToggler');
let navMenu = document.querySelector('#navMenu');

togglers.forEach((toggler) => {
  toggler.addEventListener('click', () => {
    if (navMenu.classList.contains('hidden')) {
      navMenu.classList.remove('hidden');
    } else {
      navMenu.classList.add('hidden');
    }
  });
});
