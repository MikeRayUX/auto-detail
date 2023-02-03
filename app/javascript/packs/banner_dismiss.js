window.addEventListener('load', () => {
  if (bannerPresent()) {
    banner = document.querySelector('.banner');
    bannerDismissButton = document.querySelector('.bannerDismissButton');

    bannerDismissButton.addEventListener('click', (e) => {
      e.preventDefault();
      banner.remove();
    });
  }

  function bannerPresent() {
    return document.querySelector('.banner') != null;
  }
});
