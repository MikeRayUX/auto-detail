// clear flash messages end
const addAddressButton = document.querySelector('.addAddressButton');
const cancelAddAddressButton = document.querySelector(
  '.cancelAddAddressButton'
);
const addAddressModal = document.querySelector('.addAddressModal');

addAddressButton.addEventListener('click', () => {
  addAddressModal.classList.remove('hidden');
});

cancelAddAddressButton.addEventListener('click', () => {
  addAddressModal.classList.add('hidden');
});
