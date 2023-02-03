import React, { useState, useEffect } from 'react';
import {
  getInputValue,
  getMetaContent,
} from '../../../../../utilities/getValue';
import api from '../../../../api/v1/api';
import FlashModal from '../../../general/FlashModal';
import { sleep } from '../../../../../helpers';
import SectionLoader from '../../../general/SectionLoader';
import {
  Elements,
  CardElement,
  useStripe,
  useElements,
} from '@stripe/react-stripe-js';
import { loadStripe } from '@stripe/stripe-js';
import form_authenticity_token from '../../../../api/v1/form_authenticity_token';
const stripe_public_key = getMetaContent('stripe_public_key');
const stripePromise = loadStripe(stripe_public_key);

const PaymentMethod = ({ payment_method_valid, setPaymentMethodValid }) => {
  const [is_loading, setIsLoading] = useState(true);
  const [flash, setFlash] = useState('');
  const [current_payment_method, setCurrentPaymentMethod] = useState(null);
  const [requires_payment_method, setRequiresPaymentMethod] = useState(null);

  useEffect(() => {
    getPaymentMethod();
  }, []);

  const getPaymentMethod = async () => {
    try {
      setIsLoading(true);
      const { data } = await api.get('/users/current_payment_methods');

      // await sleep(1);
      setIsLoading(false);
      switch (data.message) {
        case 'payment_method_returned':
          setCurrentPaymentMethod(data.payment_method);
          setPaymentMethodValid(true);
          setRequiresPaymentMethod(false);
          break;
        case 'requires_payment_method':
          setRequiresPaymentMethod(true);
          setCurrentPaymentMethod(null);
          setPaymentMethodValid(false);
          break;
        default:
          break;
      }
    } catch (err) {
      // console.log(err.message);
      setFlash(err.message);
    }
  };
  return (
    <div className={'mt-2 py-2 px-4 '}>
      <FlashModal flash_message={flash} onClose={() => setFlash('')} />
      {is_loading ? (
        <div className="flex-row justify-center items-center">
          <SectionLoader color="black" width={25} height={25} />
        </div>
      ) : (
        <div>
          {requires_payment_method ? (
            <Elements stripe={stripePromise}>
              <StripeForm
                current_payment_method={current_payment_method}
                setCurrentPaymentMethod={setCurrentPaymentMethod}
                setRequiresPaymentMethod={setRequiresPaymentMethod}
                setPaymentMethodValid={setPaymentMethodValid}
              />
            </Elements>
          ) : (
            <ExistingPaymentMethod
              current_payment_method={current_payment_method}
              setRequiresPaymentMethod={setRequiresPaymentMethod}
              setPaymentMethodValid={setPaymentMethodValid}
            />
          )}
        </div>
      )}
    </div>
  );
};

export default PaymentMethod;

const StripeForm = ({
  setCurrentPaymentMethod,
  setRequiresPaymentMethod,
  current_payment_method,
  setPaymentMethodValid,
}) => {
  const elements = useElements();
  const stripe = useStripe();

  const [saving, setSaving] = useState(false);
  const [flash, setFlash] = useState('');

  const getStripeToken = async () => {
    try {
      setSaving(true);

      const cardElement = elements.getElement(CardElement);
      const { token, error } = await stripe.createToken(cardElement);

      if (error) {
        throw error;
      } else {
        saveNewPaymentMethod(token);
      }
    } catch (err) {
      setSaving(false);
      // console.log(err.message);
      setFlash(err.message);
    }
  };

  const saveNewPaymentMethod = async (token) => {
    try {
      const { data } = await api.put(
        '/users/current_payment_methods',
        {
          card: {
            stripe_token: token.id,
            card_brand: token.card.brand,
            card_exp_month: token.card.exp_month,
            card_exp_year: token.card.exp_year,
            card_last4: token.card.last4,
          },
        },
        {
          headers: {
            'X-CSRF-Token': form_authenticity_token(),
          },
        }
      );
      await sleep(0.3);
      setSaving(false);

      switch (data.message) {
        case 'payment_method_saved':
          setCurrentPaymentMethod(data.payment_method);
          setRequiresPaymentMethod(false);
          setPaymentMethodValid(true);
          break;
        case 'stripe_error':
          setFlash(data.errors);
          setPaymentMethodValid(false);
          break;
        default:
          break;
      }
    } catch (err) {
      setSaving(false);
      // console.log(err.message);
      setFlash(err.message);
    }
  };

  return (
    <div className="flex-column justify-center items-center">
      <p className={'text-xs font-black text-gray-900 text-center mb-2'}>
        ENTER YOUR CARD NUMBER
      </p>

      <FlashModal flash_message={flash} onClose={() => setFlash('')} />

      <div className="w-full flex-column justify-center items-center">
        <div className="w-full px-2 py-3 border rounded mb-2">
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

        <div className="flex flex-row justify-end items-center">
          {current_payment_method ? (
            <button
              onClick={() => {
                setPaymentMethodValid(true);
                setRequiresPaymentMethod(false);
              }}
              className="underline font-bold text-blue-600 text-sm mr-4 ml-auto"
            >
              Undo
            </button>
          ) : null}
          <button
            disabled={saving}
            onClick={getStripeToken}
            className={
              'px-3 py-1 bg-primary text-white font-bold rounded text-sm'
            }
          >
            {saving ? (
              <div className="flex justify-center items-center">
                <span className="pr-2">Saving</span>
                <SectionLoader color="white" width={10} height={10} />
              </div>
            ) : (
              <div>Save</div>
            )}
          </button>
        </div>
      </div>
    </div>
  );
};

const ExistingPaymentMethod = ({
  current_payment_method,
  setRequiresPaymentMethod,
  setPaymentMethodValid,
}) => {
  return (
    <>
      <p className={'text-xs font-black text-gray-900 text-center'}>
        USING PAYMENT METHOD
      </p>
      <div className="flex flex-row justify-center items-center ">
        <p className="text-sm font-black text-primary text-center ">
          {current_payment_method}
        </p>

        <button
          onClick={() => {
            setPaymentMethodValid(false);
            setRequiresPaymentMethod(true);
          }}
          className="underline font-bold text-blue-600 text-sm ml-2"
        >
          Change
        </button>
      </div>
    </>
  );
};
