import React, { useState } from 'react';
import ReactDOM from 'react-dom';
import FlashModal from '../../../../general/FlashModal';
import SectionLoader from '../../../../general/SectionLoader';
import {
  getMetaContent,
  getElement,
} from '../../../../../../utilities/getValue';
import form_authenticity_token from '../../../../../api/v1/form_authenticity_token';

import {
  Elements,
  CardElement,
  useStripe,
  useElements,
} from '@stripe/react-stripe-js';
import { loadStripe } from '@stripe/stripe-js';

const stripe_public_key = getMetaContent('stripe_public_key');
const stripePromise = loadStripe(stripe_public_key);
const rails_flash = getElement('#flash').value;

const StripeForm = () => {
  const stripe = useStripe();
  const elements = useElements();
  const [flash, setFlash] = useState(rails_flash);
  const [form_submitting, setFormSubmitting] = useState(false);

  const sumbitForm = async (event) => {
    event.preventDefault();
    try {
      setFormSubmitting(true);

      const cardElement = elements.getElement(CardElement);
      const { token, error } = await stripe.createToken(cardElement);

      if (error) {
        throw error;
      } else {
        fillCardFields(token);
        getElement('#main_form').submit();
      }
    } catch (err) {
      setFormSubmitting(false);
      setFlash(err.message);
    }
  };

  const fillCardFields = (token) => {
    getElement(`#card_stripe_token`).value = token.id;
    getElement(`#card_card_brand`).value = token.card.brand;
    getElement(`#card_card_exp_month`).value = token.card.exp_month;
    getElement(`#card_card_exp_year`).value = token.card.exp_year;
    getElement(`#card_card_last4`).value = token.card.last4;
  };

  return (
    <div className="px-6 max-w-md mx-auto">
      <FlashModal flash_message={flash} onClose={() => setFlash('')} />
      <form
        action="/users/dashboards/settings/update_payments"
        acceptCharset="UTF-8"
        method="post"
        onSubmit={sumbitForm}
        id="main_form"
      >
        <input type="hidden" name="_method" value="put"></input>
        <input name="utf8" type="hidden" value="✓"></input>
        <input
          type="hidden"
          name="authenticity_token"
          value={form_authenticity_token()}
        ></input>

        <div className="mt-4">
          <input
            type="hidden"
            name="card[card_brand]"
            id="card_card_brand"
          ></input>
          <input
            type="hidden"
            name="card[card_exp_month]"
            id="card_card_exp_month"
          ></input>
          <input
            type="hidden"
            name="card[card_exp_year]"
            id="card_card_exp_year"
          ></input>
          <input
            type="hidden"
            name="card[card_last4]"
            id="card_card_last4"
          ></input>
          <input
            type="hidden"
            name="card[stripe_token]"
            id="card_stripe_token"
          ></input>
          <div>
            <p className="text-sm text-center mb-2 font-black">
              ENTER YOUR CARD NUMBER
            </p>
          </div>

          <div className={'w-full border px-4 py-4 rounded bg-white'}>
            <CardElement
              options={{
                style: {
                  base: {
                    fontSize: '16px',
                    color: '#424770',
                    '::placeholder': {
                      color: '#aab7c4',
                    },
                  },
                  invalid: {
                    color: '#9e2146',
                  },
                },
              }}
            />
          </div>

          <button
            type="submit"
            name="commit"
            onClick={() => setFormSubmitting(true)}
            className={
              'block w-full py-4 mt-8 bg-primary text-white text-sm sm:text-base font-black focus:outline-none mb-4'
            }
            disabled={!stripe}
          >
            {form_submitting ? (
              <SectionLoader color="white" width={30} height={24} />
            ) : (
              `SAVE NEW CARD`
            )}
          </button>
        </div>
      </form>
    </div>
  );
};

const App = document.createElement('div');
App.setAttribute('id', 'App');

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Elements stripe={stripePromise}>
      <StripeForm />
    </Elements>,
    document.body.appendChild(App)
  );
});
