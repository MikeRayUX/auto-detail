import React, { useState, useEffect, useContext } from 'react';
import redirectTo from '../../../../utilities/redirectTo';
import ReactDOM from 'react-dom';
import { seconds, minutes, sleep } from '../../../../helpers';
import FlashModal from '../../general/FlashModal';
import SectionLoader from '../../general/SectionLoader';
import {
  floatFromInput,
  getInputValue,
  getMetaContent,
  getElement,
} from '../../../../utilities/getValue';
import form_authenticity_token from '../../../api/v1/form_authenticity_token';
import {
  Elements,
  CardElement,
  useStripe,
  useElements,
} from '@stripe/react-stripe-js';
import { loadStripe } from '@stripe/stripe-js';

const stripe_public_key = getMetaContent('stripe_public_key');
const stripePromise = loadStripe(stripe_public_key);
const grandtotal = getInputValue('grandtotal');
const payment_method_required =
  getElement('#payment_method_required').value == 'true';
const rails_flash = getElement('#flash').value;
const existing_payment_method = getElement('#existing_payment_method').value;

const StripeForm = () => {
  const stripe = useStripe();
  const elements = useElements();
  const [flash, setFlash] = useState(rails_flash);
  const [form_submitting, setFormSubmitting] = useState(false);
  const [use_new_payment_method, setUseNewPaymentMethod] = useState(
    payment_method_required
  );

  const sumbitForm = async (event) => {
    event.preventDefault();
    if (use_new_payment_method) {
      try {
        setFormSubmitting(true);

        const cardElement = elements.getElement(CardElement);
        const { token, error } = await stripe.createToken(cardElement);

        if (error) {
          throw error;
        } else {
          fillCardFields(token);
          submitForm();
        }
      } catch (err) {
        setFormSubmitting(false);
        setFlash(err.message);
      }
    } else {
      submitForm();
    }
  };

  const submitForm = () => {
    getElement('#main_form').submit();
  };

  const fillCardFields = (token) => {
    getElement(`#card_stripe_token`).value = token.id;
    getElement(`#card_card_brand`).value = token.card.brand;
    getElement(`#card_card_exp_month`).value = token.card.exp_month;
    getElement(`#card_card_exp_year`).value = token.card.exp_year;
    getElement(`#card_card_last4`).value = token.card.last4;
  };

  return (
    <>
      <FlashModal flash_message={flash} onClose={() => setFlash('')} />
      <form
        action="/users/resolve_subscriptions"
        acceptCharset="UTF-8"
        method="post"
        onSubmit={sumbitForm}
        id="main_form"
      >
        <input name="utf8" type="hidden" value="✓"></input>
        <input
          type="hidden"
          name="authenticity_token"
          value={form_authenticity_token()}
        ></input>
        {use_new_payment_method ? (
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
            <div className="flex flex-row justify-between items-center">
              <p className="text-sm text-center mb-2 font-black">
                ENTER YOUR CARD NUMBER
              </p>
              {existing_payment_method ? (
                <button
                  className="text-sm underline text-blue-600 font-bold mb-2"
                  onClick={() => setUseNewPaymentMethod(false)}
                >
                  Back
                </button>
              ) : null}
            </div>

            <div className={'w-full border px-4 py-4 rounded'}>
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
              className={styles.button.enabled}
              disabled={!stripe}
            >
              {form_submitting ? (
                <SectionLoader color="white" width={30} height={24} />
              ) : (
                `SAVE CARD & PAY $${grandtotal}`
              )}
            </button>
          </div>
        ) : (
          <div>
            <div className="flex flex-row justify-end items-center mt-2">
              <p className="text-sm font-black text-gray-900 mr-2">
                Use {`${existing_payment_method}`}
              </p>
              <button
                className="text-sm underline text-blue-600 font-bold"
                onClick={() => setUseNewPaymentMethod(true)}
              >
                Change
              </button>
            </div>
            <button
              type="submit"
              name="commit"
              onClick={() => setFormSubmitting(true)}
              className={styles.button.enabled}
              disabled={false}
            >
              {form_submitting ? (
                <SectionLoader color="white" width={30} height={24} />
              ) : (
                `PAY $${grandtotal} WITH ${existing_payment_method}`
              )}
            </button>
          </div>
        )}
      </form>
    </>
  );
};

const styles = {
  container: 'w-full',
  button: {
    enabled:
      'block w-full py-4 mt-8 bg-primary text-white text-sm sm:text-base font-black focus:outline-none mb-4',
  },
};

const App = document.createElement('div');
App.setAttribute('id', 'App');

const stripeContainer = document.querySelector('#stripe_container');
document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Elements stripe={stripePromise}>
      <StripeForm />
    </Elements>,
    stripeContainer.appendChild(App)
  );
});
