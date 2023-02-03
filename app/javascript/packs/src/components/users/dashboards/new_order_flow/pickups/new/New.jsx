import React, { useState, useEffect, useContext } from 'react';
import api from '../../../../../../api/v1/api';
import {
  users_dashboards_new_order_flow_pickup_estimations_path,
  new_users_dashboards_new_order_flow_pickups_path,
} from '../../../../../../api/v1/routes';
import ReactDOM from 'react-dom';
import RailsForm from './RailsForm';
import FlashModal from '../../../../../general/FlashModal';
import SelectSection from './SelectSection';
import BagCount from './BagCount';
import PickupTypeToggler from './PickupTypeToggler';
import NoWashersAvailableFlash from './NoWashersAvailableFlash';
import { minutes } from '../../../../../../../helpers';
import redirectTo from '../../../../../../../utilities/redirectTo';
import DetergentMenuModal from '../../../../../general/modals/DetergentMenuModal';
import SoftenerMenuModal from '../../../../../general/modals/SoftenerMenuModal';
import BagInfoModal from '../../../../../general/modals/BagInfoModal';
import SessionTimeoutInterval from '../../../../../general/SessionTimeoutInterval';

const detergents = [
  {
    value: 'CLEAN',
    enum: 'dropps_clean_detergent',
  },
  {
    value: 'SENSITIVE',
    enum: 'dropps_sensitive_detergent',
  },
  {
    value: 'USE OWN',
    enum: 'use_own_detergent',
  },
];

const softeners = [
  {
    value: 'CLEAN',
    enum: 'dropps_clean_softener',
  },
  {
    value: 'UNSCENTED',
    enum: 'dropps_unscented_softener',
  },
  {
    value: 'USE OWN',
    enum: 'use_own_softener',
  },
  {
    value: 'NONE',
    enum: 'no_softener',
  },
];

const New = () => {
  const [flash_message, setFlashMessage] = useState('');
  const [formPath, setFormPath] = useState('');
  const [is_loading, setIsLoading] = useState(true);
  const [form_submitting, setFormSubmitting] = useState(false);
  const [form_valid, setFormValid] = useState(false);
  const [asapEnabled, setAsapEnabled] = useState(false);
  const [asap, setAsap] = useState(true);
  const [availability_flash, setAvailabilityFlash] = useState('');
  const [order, setOrder] = useState({
    pickup_type: 'scheduled',
    detergent: '',
    softener: '',
    bag_count: 1,
  });

  const [selectedDetergent, setSelectedDetergent] = useState({});
  const [selectedSoftener, setSelectedSoftener] = useState({});

  // modals
  const [detergentMenuVisible, setDetergentMenuVisible] = useState(false);
  const [softenerMenuVisible, setSoftenerMenuVisible] = useState(false);
  const [bagInfoModalVisible, setBagInfoModalVisible] = useState(false);

  useEffect(() => {
    setFormValid(validateForm());
    if (order.pickup_type == 'asap') {
      setFormPath('/users/dashboards/new_order_flow/asap_pickups/new');
    } else {
      setFormPath('/users/dashboards/new_order_flow/scheduled_pickups/new');
    }
  }, [order]);

  useEffect(() => {
    getPickupEstimate();
  }, []);

  const getPickupEstimate = async () => {
    try {
      setIsLoading(true);
      const { data } = await api.get(
        users_dashboards_new_order_flow_pickup_estimations_path
      );

      setIsLoading(false);

      // console.log(data);

      switch (data.message) {
        case 'washers_available':
          setAsapEnabled(true);
          setOrder({ ...order, pickup_type: 'asap' });
          break;
        case 'no_washers_available':
          setAsapEnabled(false);
          setAsap(false);
          setOrder({ ...order, pickup_type: 'scheduled' });
          setAvailabilityFlash(data.errors);
        case 'business_not_open':
          setAsapEnabled(false);
          setAsap(false);
          setOrder({ ...order, pickup_type: 'scheduled' });
          setAvailabilityFlash(data.errors);
        default:
          break;
      }
    } catch (err) {
      setFlashMessage(err.message);
    }
  };

  const validateForm = () => {
    let valid = true;

    ['pickup_type', 'detergent', 'softener'].forEach((key) => {
      if (order[key].length == 0) {
        valid = false;
      }
    });

    if (order.bag_count < 1) {
      valid = false;
    }

    return valid;
  };

  return (
    <>
      <FlashModal
        flash_message={flash_message}
        onClose={() => setFlashMessage('')}
      />
      <div className="py-2"></div>

      <DetergentMenuModal
        visible={detergentMenuVisible}
        onClose={() => setDetergentMenuVisible(false)}
      />
      <SoftenerMenuModal
        visible={softenerMenuVisible}
        onClose={() => setSoftenerMenuVisible(false)}
      />
      <BagInfoModal
        visible={bagInfoModalVisible}
        onClose={() => setBagInfoModalVisible(false)}
      />
      <SessionTimeoutInterval
        MINUTES_TO_EXPIRE={5}
        onInterval={getPickupEstimate}
        onExpire={() => {
          redirectTo('/users/dashboards/new_order_flow/pickups/new');
        }}
      />

      {/* <PickupTypeToggler
        availability_flash={availability_flash}
        is_loading={is_loading}
        asap={asap}
        asapEnabled={asapEnabled}
        setAsap={setAsap}
        setFlashMessage={setFlashMessage}
        order={order}
        setOrder={setOrder}
      /> */}

      <div className={'w-full bg-white px-2  sm:max-w-lg sm:mt-10 mx-auto'}>
        <SelectSection
          sectionTitle={'Detergent'}
          order={order}
          options={detergents}
          selectedOption={selectedDetergent}
          setSelectedOption={setSelectedDetergent}
          setOrder={setOrder}
          bgColor={'bg-primary'}
          order_key="detergent"
          item_count={3}
          onHeaderButtonClick={() => setDetergentMenuVisible(true)}
        />

        <SelectSection
          sectionTitle={'Softener'}
          order={order}
          options={softeners}
          selectedOption={selectedSoftener}
          setSelectedOption={setSelectedSoftener}
          setOrder={setOrder}
          bgColor={'bg-primary'}
          order_key="softener"
          item_count={4}
          onHeaderButtonClick={() => setSoftenerMenuVisible(true)}
        />

        <BagCount
          order={order}
          setOrder={setOrder}
          bgColor={'bg-primary'}
          setBagInfoModalVisible={setBagInfoModalVisible}
        />

        <RailsForm
          formPath={'/users/dashboards/new_order_flow/scheduled_pickups/new'}
          order={order}
          form_valid={form_valid}
          form_submitting={form_submitting}
          setFormSubmitting={setFormSubmitting}
        />
      </div>
    </>
  );
};

const App = document.createElement('div');
App.setAttribute('id', 'App');

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(<New name={'michael'} />, document.body.appendChild(App));
});
