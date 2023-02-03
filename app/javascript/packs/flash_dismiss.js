const flashMessageExists = () => {
  return document.querySelector('.flash') != null;
};

const seconds = (seconds) => {
  return seconds * 1000;
};

const clearFlash = () => {
  document.querySelector('.flash').remove();
};

if (flashMessageExists()) {
  setTimeout(() => {
    clearFlash();
  }, seconds(5));
}
