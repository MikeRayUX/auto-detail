document.querySelectorAll('.radioButton').forEach((button) => {
  button.addEventListener('click', () => {
    showField();
  });
});

const showField = () => {
  document.querySelector('.hiddenField').classList.remove('hidden');
};
