import React, { useState, useEffect, useContext } from 'react';
import ReactDOM from 'react-dom';
import api from '../../../../../api/v1/api';
import { users_dashboards_new_order_flow_scheduled_timeslots_path } from '../../../../../api/v1/routes';
import FlashModal from '../../../../general/FlashModal';
import Map from '../../../Map';
import {
  floatFromInput,
  getInputValue,
} from '../../../../../../utilities/getValue';
import SelectSectionMini from '../../../../general/SelectSectionMini';
import { googleMapURL } from '../../../../../location/location';
import Address from '../Address';
import PaymentMethod from '../PaymentMethod';
import RailsForm from './RailsForm';
import { readableDecimal } from '../../../../../../utilities/currency';
import ScheduledSummary from './ScheduledSummary';
import SessionTimeoutInterval from '../../../../general/SessionTimeoutInterval';
import redirectTo from '../../../../../../utilities/redirectTo';

const initial_subtotal = floatFromInput('subtotal');
const tax = floatFromInput('tax');
const tax_rate = floatFromInput('tax_rate');
const tip_options = getInputValue('tip_options').split(' ');
const bag_count = getInputValue('bag_count');
const detergent = getInputValue('detergent');
const detergent_value = getInputValue('detergent_value');
const softener = getInputValue('softener');
const softener_value = getInputValue('softener_value');
const pickup_date = getInputValue('pickup_date');
const pickup_time = getInputValue('pickup_time');

const customer_lat_lng = document
  .querySelector('meta[name="customer_lat_lng"]')
  .content.split('/');

const customer = {
  location: {
    lat: parseFloat(customer_lat_lng[0]),
    lng: parseFloat(customer_lat_lng[1]),
  },
};

const New = () => {
  const [flash_message, setFlashMessage] = useState('');
  const [form_submitting, setFormSubmitting] = useState(false);
  const [form_valid, setFormValid] = useState(true);
  const [grandtotal, setGrandtotal] = useState(null);
  const [subtotal, setSubtotal] = useState(initial_subtotal);
  const [tip, setTip] = useState(null);
  // date
  // time
  const [payment_method_valid, setPaymentMethodValid] = useState(false);

  const [order, setOrder] = useState({
    pickup_type: 'scheduled',
    detergent: detergent_value,
    softener: softener_value,
    bag_count: bag_count,
    tip: 0,
    pickup_date,
    pickup_time,
  });

  // auto select suggested tip
  useEffect(() => {
    setTip(tip_options[1]);
  }, []);

  useEffect(() => {
    let grandtotal = readableDecimal(subtotal + parseInt(tip) + tax);
    setGrandtotal(grandtotal);
    setOrder({
      ...order,
      tip: tip,
    });
  }, [tip]);

  useEffect(() => {
    // console.log(order);
    setFormValid(validateForm());
  }, [order, payment_method_valid]);

  const validateForm = () => {
    return (
      order.pickup_type.length &&
      order.detergent.length &&
      order.softener.length &&
      order.bag_count.length &&
      order.tip &&
      order.pickup_date.length &&
      order.pickup_time.length &&
      payment_method_valid
    );
  };

  return (
    <div className={'h-full bg-white'}>
      <FlashModal
        flash_message={flash_message}
        onClose={() => setFlashMessage('')}
      />
      <SessionTimeoutInterval
        MINUTES_TO_EXPIRE={8}
        onInterval={() => {
          return null;
        }}
        onExpire={() => {
          redirectTo('/users/dashboards/new_order_flow/pickups/new');
        }}
      />

      <div className={''}>
        <div className={'w-full shadow-inner'}>
          <Map
            customer={customer}
            googleMapURL={googleMapURL}
            loadingElement={<div style={{ height: `100%` }} />}
            containerElement={<div className={'h-40'} />}
            mapElement={<div style={{ height: `100%` }} />}
            defaultEnableRetinaIcons={false}
          />
        </div>

        <div
          className={
            'w-full border-t border border-gray-200 rounded bg-white sm:max-w-lg sm:mt-8  mx-auto'
          }
        >
          <ScheduledSummary />

          <div className={'pt-2 border-gray-200 py-2 px-4  sm:py-2 sm:px-12'}>
            <div className={' flex flex-row justify-between items-center '}>
              <p className={'text-base font-black text-gray-900 '}>
                TUMBLE BAGS
              </p>

              <p className={'text-base font-black text-gray-900'}>
                {bag_count}
              </p>
            </div>

            <div className={' flex flex-row justify-between items-center '}>
              <p className={'text-base font-black text-gray-900 '}>DETERGENT</p>

              <p className={'text-base font-black text-gray-900'}>
                {detergent}
              </p>
            </div>

            <div className={' flex flex-row justify-between items-center '}>
              <p className={'text-base font-black text-gray-900 '}>SOFTENER</p>

              <p className={'text-base font-black text-gray-900'}>{softener}</p>
            </div>

            <div className={' flex flex-row justify-between items-center '}>
              <p className={'text-base font-black text-gray-900 '}>
                PICKUP & DELIVERY
              </p>

              <p className={'text-base font-black text-gray-900'}>FREE</p>
            </div>

            <div className={' flex flex-row justify-between items-center '}>
              <p className={'text-base font-black text-gray-900 '}>SUBTOTAL</p>

              <p className={'text-base font-black text-gray-900'}>
                ${subtotal}
              </p>
            </div>

            <div className={' flex flex-row justify-between items-center '}>
              <p className={'text-base font-black text-gray-900 '}>
                TAX ({tax_rate}%)
              </p>

              <p className={'text-base font-black text-gray-900'}>${tax}</p>
            </div>

            <div className={'mb-2'}>
              <div className={'flex flex-row justify-between items-center'}>
                <p
                  className={'text-base font-black text-gray-900 leading-none'}
                >
                  CHOOSE A TIP
                </p>
                <SelectSectionMini
                  options={tip_options}
                  selectedOption={tip}
                  setSelectedOption={setTip}
                  option_prefix={'$'}
                />
              </div>

              <p
                className={
                  'text-xs text-left font-bold leading-none mt-1 text-gray-900'
                }
              >
                *100% of your tip goes to your Washer in addition to their base
                pay
              </p>
            </div>

            <div className={'flex flex-row justify-between items-center '}>
              <div>
                <p className={'text-base font-black text-gray-900 mr-4'}>TIP</p>
              </div>

              <p className={'text-base font-black text-gray-900'}>${tip}</p>
            </div>

            <div className={'flex flex-row justify-between items-center '}>
              <div>
                <p className={'text-base font-black text-gray-900 '}>
                  GRANDTOTAL
                </p>
              </div>

              <p className={'text-base font-black text-gray-900'}>
                ${grandtotal}
              </p>
            </div>

            <PaymentMethod
              payment_method_valid={payment_method_valid}
              setPaymentMethodValid={setPaymentMethodValid}
            />

            <RailsForm
              order={order}
              form_valid={form_valid}
              form_submitting={form_submitting}
              setFormSubmitting={setFormSubmitting}
              submitText={'COMPLETE'}
            />
          </div>
        </div>
      </div>
    </div>
  );
};

const App = document.createElement('div');
App.setAttribute('id', 'App');
document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(<New />, document.body.appendChild(App));
});
