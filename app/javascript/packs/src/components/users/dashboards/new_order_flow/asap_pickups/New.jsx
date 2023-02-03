import React, { useState, useEffect, useContext } from 'react';
import api from '../../../../../api/v1/api';
import {
  users_dashboards_new_order_flow_pickup_estimations_path,
  new_users_dashboards_new_order_flow_pickups_path,
} from '../../../../../api/v1/routes';
import redirectTo from '../../../../../../utilities/redirectTo';
import ReactDOM from 'react-dom';
import { seconds, minutes, sleep } from '../../../../../../helpers';
import FlashModal from '../../../../general/FlashModal';
import SectionLoader from '../../../../general/SectionLoader';
import Map from '../../../Map';
import {
  floatFromInput,
  getElement,
  getInputValue,
} from '../../../../../../utilities/getValue';
import SelectSectionMini from '../../../../general/SelectSectionMini';
import RailsForm from './RailsForm';
import { googleMapURL } from '../../../../../location/location';
import Address from '../Address';
import PaymentMethod from '../PaymentMethod';
import { readableDecimal } from '../../../../../../utilities/currency';

const customer_lat_lng = document
  .querySelector('meta[name="customer_lat_lng"]')
  .content.split('/');

const est_delivery = getInputValue('est_delivery');

const initial_subtotal = floatFromInput('subtotal');
const tax = floatFromInput('tax');
const tax_rate = floatFromInput('tax_rate');
const tip_options = getInputValue('tip_options').split(' ');
const bag_count = getInputValue('bag_count');
const detergent = getInputValue('detergent');
const detergent_value = getInputValue('detergent_value');
const softener = getInputValue('softener');
const softener_value = getInputValue('softener_value');

const New = () => {
  const [flash_message, setFlashMessage] = useState('');
  const [form_submitting, setFormSubmitting] = useState(false);
  const [is_loading, setIsLoading] = useState(false);
  const [form_valid, setFormValid] = useState(true);
  const [grandtotal, setGrandtotal] = useState(null);
  const [subtotal, setSubtotal] = useState(initial_subtotal);
  const [tip, setTip] = useState(null);
  const [pickup_estimate, setPickupEstimate] = useState(null);
  const [fetching_estimate, setFetchingEstimate] = useState(false);
  const [expiredMessage, setExpiredMessage] = useState('');
  const [noWashersMessage, setNoWashersMessage] = useState('');
  const [customer, setCustomer] = useState({
    location: {
      lat: parseFloat(customer_lat_lng[0]),
      lng: parseFloat(customer_lat_lng[1]),
    },
  });

  const [payment_method_valid, setPaymentMethodValid] = useState(false);

  const [order, setOrder] = useState({
    pickup_type: 'asap',
    detergent: detergent_value,
    softener: softener_value,
    bag_count: bag_count,
    tip: 0,
  });

  // auto select suggested tip
  useEffect(() => {
    setTip(tip_options[1]);
    getPickupEstimate();
  }, []);

  useEffect(() => {
    // console.log(order);
    setFormValid(validateForm());
  }, [order, payment_method_valid]);

  const validateForm = () => {
    let { pickup_type, detergent, softener, bag_count, tip } = order;
    return (
      pickup_type.length &&
      detergent.length &&
      softener.length &&
      bag_count.length &&
      tip &&
      payment_method_valid
    );
  };

  // refresh pickup estimate
  useEffect(() => {
    let refreshCount = 0;
    let interval = setInterval(() => {
      getPickupEstimate();
      refreshCount += 1;

      if (refreshCount >= 7) {
        clearInterval(interval);
        setExpiredMessage(
          'Your session has expired. Please restart your order.'
        );
      }
    }, minutes(1));

    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    let grandtotal = readableDecimal(subtotal + parseInt(tip) + tax);

    // console.log(grandtotal);
    setGrandtotal(grandtotal);
    setOrder({
      ...order,
      tip: tip,
    });
  }, [tip]);

  const getPickupEstimate = async () => {
    try {
      setFetchingEstimate(true);
      const { data } = await api.get(
        users_dashboards_new_order_flow_pickup_estimations_path
      );

      await sleep(1);
      setFetchingEstimate(false);

      // console.log('data', data);

      switch (data.message) {
        case 'washers_available':
          setPickupEstimate(data.pickup_estimate);
          break;
        case 'no_washers_available':
          setNoWashersMessage(data.errors);
          break;
        default:
          break;
      }
    } catch (err) {
      setFlashMessage(err.message);
    }
  };

  return (
    <div className={'h-full bg-white'}>
      <FlashModal
        flash_message={flash_message}
        onClose={() => setFlashMessage('')}
      />

      <FlashModal
        flash_message={expiredMessage}
        onClose={() =>
          redirectTo(new_users_dashboards_new_order_flow_pickups_path)
        }
      />

      <FlashModal
        flash_message={noWashersMessage}
        onClose={() =>
          redirectTo(new_users_dashboards_new_order_flow_pickups_path)
        }
      />

      {is_loading ? (
        <SectionLoader color="#d70cf5" height={40} width={40} />
      ) : (
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
          {/* order form */}
          <div
            className={
              'w-full border-t border border-gray-200 rounded bg-white py-2 px-4 sm:max-w-lg sm:mt-8 sm:py-2 sm:px-12 mx-auto'
            }
          >
            <div className="pt-1 mb-1">
              {fetching_estimate ? (
                <SectionLoader color="#d70cf5" height={20} width={20} />
              ) : (
                <div className={'flex-column justify-center items-center'}>
                  <div className={'flex flex-row justify-center items-center'}>
                    <ion-icon name="time-outline"></ion-icon>
                    <p
                      className={
                        'text-sm font-black text-gray-900 text-center ml-1'
                      }
                    >
                      EST. PICKUP BY {pickup_estimate}
                    </p>
                  </div>
                </div>
              )}
            </div>
            <Address est_delivery={est_delivery} />

            <div className={'pt-2 border-b border-gray-200'}>
              {/* <h3 className={'text-base text-left font-black text-gray-900 mb-2'}>
                YOUR ORDER
              </h3> */}
              <div className={' flex flex-row justify-between items-center '}>
                <p className={'text-base font-black text-gray-900 '}>BAGS</p>

                <p className={'text-base font-black text-gray-900'}>
                  {bag_count}
                </p>
              </div>

              <div className={' flex flex-row justify-between items-center '}>
                <p className={'text-base font-black text-gray-900 '}>
                  DETERGENT
                </p>

                <p className={'text-base font-black text-gray-900'}>
                  {detergent}
                </p>
              </div>

              <div className={' flex flex-row justify-between items-center '}>
                <p className={'text-base font-black text-gray-900 '}>
                  SOFTENER
                </p>

                <p className={'text-base font-black text-gray-900'}>
                  {softener}
                </p>
              </div>

              <div className={' flex flex-row justify-between items-center '}>
                <p className={'text-base font-black text-gray-900 '}>
                  PICKUP & DELIVERY
                </p>

                <p className={'text-base font-black text-gray-900'}>FREE</p>
              </div>

              <div className={' flex flex-row justify-between items-center '}>
                <p className={'text-base font-black text-gray-900 '}>
                  SUBTOTAL
                </p>

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
                    className={
                      'text-base font-black text-gray-900 leading-none'
                    }
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
                  *100% of your tip goes to your Washer in addition to their pay
                </p>
              </div>

              <div className={'flex flex-row justify-between items-center '}>
                <div>
                  <p className={'text-base font-black text-gray-900 mr-4'}>
                    TIP
                  </p>
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
            </div>

            <RailsForm
              order={order}
              form_valid={form_valid}
              form_submitting={form_submitting}
              setFormSubmitting={setFormSubmitting}
              submitText={'COMPLETE'}
            />
          </div>
        </div>
      )}
    </div>
  );
};

const App = document.createElement('div');
App.setAttribute('id', 'App');
document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(<New />, document.body.appendChild(App));
});
