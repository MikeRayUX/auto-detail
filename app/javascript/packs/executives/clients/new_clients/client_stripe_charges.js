import { showLoader, hideLoader } from '../../../simple_loader';

const submitButton = document.querySelector('.submitaction-button');

if (cardElementExists()) {
  const publicKey = document.querySelector('meta[name="stripe-public-key"]')
    .content;
  const stripe = Stripe(publicKey);
  const elements = stripe.elements();
  const card = elements.create('card');
  const form = document.querySelector('.new_new_client');
  const submitActionButton = document.querySelector('.submitaction-button');

  const stripeTokenListener = async (event) => {
    event.preventDefault();
    submitActionButton.style.background = '#08d4aa';

    const { token, error } = await stripe.createToken(card);
    if (error) {
      setTimeout(() => {
        hideLoader();
        // inform the customer there was an error
        const errorElement = document.querySelector('#card-errors');
        errorElement.textContent = error.message;
        // console.log(error);
        // fixes form being disabled from preventDefault() permanently after errors.
        document
          .querySelector('.submitaction-button')
          .removeAttribute('disabled');
        submitActionButton.style.background = '#1bad8f';
      }, 2000);
    } else {
      addCardFieldsToFormAndSubmit(token);
    }
  };

  mountCardField();

  const addCardFieldsToFormAndSubmit = (token) => {
    const form = document.querySelector('.new_new_client');
    const hiddenInput = document.createElement('input');
    hiddenInput.setAttribute('type', 'hidden');
    hiddenInput.setAttribute('name', 'card[stripe_token]');
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
    // setting the attributes for the nested params order_params[:card_attributes]
    hiddenInput.setAttribute('type', 'hidden');
    // hiddenInput.setAttribute('name', `user[card_${field}]`);
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
}

function cardElementExists() {
  return document.querySelector('#card-element') != null;
}

submitButton.addEventListener('click', () => {
  showLoader();
});
