import { showLoader, hideLoader } from '../../../../simple_loader';

const publicKey = document.querySelector('meta[name="stripe-public-key"]')
  .content;
const stripe = Stripe(publicKey);
const elements = stripe.elements();
const card = elements.create('card');
const form = document.querySelector('.card-form');

const stripeTokenListener = async (event) => {
  event.preventDefault();

  showLoader();
  const { token, error } = await stripe.createToken(card);
  if (error) {
    setTimeout(() => {
      hideLoader();
      const errorElement = document.querySelector('#card-errors');
      errorElement.textContent = error.message;
      // fixes form being disabled from preventDefault() permanently after errors.
      document
        .querySelector('.submitaction-button')
        .removeAttribute('disabled');
    }, 2000);
  } else {
    addCardFieldsToFormAndSubmit(token);
  }
};

const addCardFieldsToFormAndSubmit = (token) => {
  const form = document.querySelector('.card-form');
  const hiddenInput = document.createElement('input');
  hiddenInput.setAttribute('type', 'hidden');
  hiddenInput.setAttribute('name', 'stripe_token');
  hiddenInput.setAttribute('value', token.id);
  form.appendChild(hiddenInput);
  // card_brand, card_exp_month, card_exp_year, card_last4
  ['brand', 'exp_month', 'exp_year', 'last4'].forEach((field) => {
    addFieldToForm(form, token, field);
  });
  form.submit();
};

function addFieldToForm(form, token, field) {
  const hiddenInput = document.createElement('input');
  hiddenInput.setAttribute('type', 'hidden');
  hiddenInput.setAttribute('name', `card[card_${field}]`);
  hiddenInput.setAttribute('id', `card_${field}`);
  hiddenInput.setAttribute('value', token.card[field]);
  form.appendChild(hiddenInput);
}

function mountCardField() {
  card.mount('#card-element');
  card.addEventListener('change', ({ errors }) => {
    const displayError = document.querySelector('#card-errors');
    if (errors) {
      displayError.textContent = errors.message;
    } else {
      displayError.textContent = '';
    }
  });
  form.addEventListener('submit', stripeTokenListener);
}

mountCardField();
