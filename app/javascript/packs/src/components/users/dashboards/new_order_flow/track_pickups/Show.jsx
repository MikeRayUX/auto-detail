import React, { useEffect, useState } from 'react';
import ReactDOM from 'react-dom';
import {
  getElement,
  getInputValue,
} from '../../../../../../utilities/getValue';
import Address from './Address';
import PickupStatus from './PickupStatus';
import OrderDetail from './OrderDetail';
import CancelPickup from './CancelPickup';

import Map from '../../../Map';
import api from '../../../../../api/v1/api';
import {
  users_dashboards_new_order_flow_track_pickups_path,
  users_dashboards_new_order_flow_refresh_wait_for_washer_path,
} from '../../../../../api/v1/routes';
import { seconds, sleep } from '../../../../../../helpers';
import { calcRegion, googleMapURL } from '../../../../../location/location';
import FlashModal from '../../../../general/FlashModal';
import form_authenticity_token from '../../../../../api/v1/form_authenticity_token';

// order
const ref_code = getInputValue('ref_code');
const detergent = getInputValue('detergent');
const softener = getInputValue('softener');
const bag_count = getInputValue('bag_count');
const order_grandtotal = getInputValue('order_grandtotal');

// address
const current_address = getInputValue('current_address');
const est_delivery = getInputValue('est_delivery');
const pick_up_directions = getInputValue('pick_up_directions');
// customer
const customer_lat_lng = getElement(
  'meta[name="customer_lat_lng"]'
).content.split('/');

const customer = {
  location: {
    lat: parseFloat(customer_lat_lng[0]),
    lng: parseFloat(customer_lat_lng[1]),
  },
};

const Show = () => {
  // general
  const [flash, setFlash] = useState('');
  // washer
  const [washer, setWasher] = useState(null);
  // map
  const [current_region, setCurrentRegion] = useState({
    latitude: customer.location.lat,
    longitude: customer.location.lng,
  });
  // order/offer
  const [order_status, setOrderStatus] = useState(''); // base enum
  const [customer_status, setCustomerStatus] = useState(null); // readable
  const [cancellable, setCancellable] = useState(false);
  // status
  const [est_pickup_by, setEstPickupBy] = useState('');
  const [waitButtonLoading, setWaitButtonLoading] = useState(false);
  const [refreshable, setRefreshable] = useState(true);
  const [pollingActive, setPollingActive] = useState(false);
  const [delivery_photo_base64, setDeliveryPhotoBase64] = useState(null);
  const [readable_delivered, setReadableDelivered] = useState('');
  const [readable_delivery_location, setReadableDeliveryLocation] = useState(
    ''
  );

  useEffect(() => {
    getStatus();
  }, []);

  useEffect(() => {
    const interval = setInterval(() => {
      getStatus();
    }, seconds(10));

    if (!refreshable) {
      clearInterval(interval);
    }
    return () => clearInterval(interval);
  }, [refreshable]);

  useEffect(() => {
    resolveRefreshable();
  }, [order_status]);

  const resolveRefreshable = () => {
    // ensure polling stops once trackable order status has been passed (picked up and beyond)
    let statuses = [
      'picked_up',
      'completed',
      'delivered',
      'cancelled',
      'offer_expired',
      'order_not_found',
    ];
    statuses.forEach((status) => {
      if (order_status == status) {
        setRefreshable(false);
        setPollingActive(false);
      }
    });
  };

  const getStatus = async () => {
    try {
      setPollingActive(true);
      const { data } = await api.get(
        users_dashboards_new_order_flow_track_pickups_path,
        {
          params: {
            id: ref_code,
          },
        }
      );
      // console.log(data);
      switch (data.message) {
        case 'order_returned':
          handleOrderReturned(data);
          break;
        case 'offer_expired':
          handleOfferExpired(data);
          break;
        case 'order_not_found':
          handleOrderNotFound(data);
          break;
        default:
          break;
      }
    } catch (err) {
      // console.log(err.message);
      setFlash(err.message);
    }
  };

  const handleOrderReturned = (data) => {
    setCustomerStatus(data.customer_status.toUpperCase());
    setOrderStatus(data.order_status);
    setEstPickupBy(data.est_pickup_by);
    setCancellable(data.cancellable);
    setDeliveryPhotoBase64(data.delivery_photo_base64);
    setReadableDelivered(data.readable_delivered);
    setReadableDeliveryLocation(data.readable_delivery_location);

    if (data.washer && data.washer.location.lat && data.washer.location.lng) {
      setWasher({
        name: data.washer.name,
        location: {
          lat: data.washer.location.lat,
          lng: data.washer.location.lng,
        },
      });
      setCurrentRegion(calcRegion(customer.location, data.washer.location));
    } else {
      resetMap();
    }
  };

  const handleOfferExpired = (data) => {
    // console.log('handleOfferExpired');
    setOrderStatus(data.order_status);
    setCancellable(data.cancellable);
    setRefreshable(false);
    setPollingActive(false);
  };

  const handleOrderNotFound = (data) => {
    setRefreshable(false);
    setPollingActive(false);
    // console.log('handleOrderNotFound');
  };

  const resetMap = () => {
    setWasher(null);
    setCurrentRegion({
      latitude: customer.location.lat,
      longitude: customer.location.lng,
    });
  };

  const refreshWaitForWasher = async () => {
    try {
      setWaitButtonLoading(true);
      const { data } = await api.put(
        users_dashboards_new_order_flow_refresh_wait_for_washer_path,
        {
          new_order: {
            ref_code,
          },
        },
        {
          headers: {
            'X-CSRF-Token': form_authenticity_token(),
          },
        }
      );

      await sleep(1);
      setWaitButtonLoading(false);

      switch (data.message) {
        case 'offer_refreshed':
          setRefreshable(true);
          getStatus();
          break;
        case 'not_refreshable':
          setFlash('This order is not refreshable');
          break;
      }
    } catch (err) {
      setFlash('Something went wrong.');
    }
  };

  return (
    <div>
      {flash ? (
        <FlashModal flash_message={flash} onClose={() => setFlash('')} />
      ) : null}

      <div className="sm:flex sm:flex-row sm:justify-start sm:items-center">
        <div className="h-64 w-full sm:h-screen flex-column justify-center items-center ">
          {customer ? (
            <Map
              customer={customer}
              washer={washer}
              current_region={current_region}
              googleMapURL={googleMapURL}
              loadingElement={<div style={{ height: '100%' }} />}
              containerElement={<div style={{ height: '100%' }} />}
              mapElement={<div style={{ height: '100%' }} />}
              // defaultEnableRetinaIcons={false}
            />
          ) : null}
        </div>

        <div
          className={
            delivery_photo_base64
              ? 'sm:w-sm sm:h-screen bg-gray-300'
              : 'sm:w-sm sm:h-screen'
          }
        >
          <PickupStatus
            delivery_photo_base64={delivery_photo_base64}
            readable_delivery_location={readable_delivery_location}
            pollingActive={pollingActive}
            customer_status={customer_status}
            order_status={order_status}
            est_pickup_by={est_pickup_by}
            refreshWaitForWasher={refreshWaitForWasher}
            waitButtonLoading={waitButtonLoading}
          />
          <OrderDetail
            bag_count={bag_count}
            detergent={detergent}
            softener={softener}
            est_delivery={est_delivery}
            order_grandtotal={order_grandtotal}
          />
          <Address
            current_address={current_address}
            pick_up_directions={pick_up_directions}
          />

          {cancellable ? (
            <CancelPickup
              ref_code={ref_code}
              order_grandtotal={order_grandtotal}
            />
          ) : null}
        </div>
      </div>
    </div>
  );
};

const App = document.createElement('div');
App.setAttribute('id', 'App');
document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(<Show />, document.body.appendChild(App));
});
