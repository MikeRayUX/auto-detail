import { getElem } from '../orders/schedule_pickups/utilities';

const modal = getElem('.modal');
const dismissBtn = getElem('#modalDismiss');
const confirmBtn = getElem('#confirmBtn');

const modalPresent = () => {
  return modal != null;
};

const showModal = () => {
  modal.style.transition = 'opacity 0.25s ease';
  modal.classList.remove('opacity-0');
  modal.classList.remove('pointer-events-none');
};

const seconds = (seconds) => {
  return seconds * 1000;
};

const dismissModal = () => {
  modal.classList.add('opacity-0');
  modal.classList.add('pointer-events-none');
};

if (modalPresent()) {
  setTimeout(() => {
    showModal(modal);
  }, seconds(1));

  confirmBtn.addEventListener('click', (e) => {
    let choice = confirm('This will take you to an external page.');
    if (choice == true) {
      dismissModal();
    } else {
      e.preventDefault();
    }
  });

  dismissBtn.addEventListener('click', (e) => {
    e.preventDefault();
    dismissModal(e.target);
  });
}
