import React, { useState } from 'react';
import { getInputValue } from '../../../../../../utilities/getValue';
import ConfirmModal from '../../../../general/ConfirmModal';
import { users_dashboards_new_order_flow_cancel_pickup_path } from '../../../../../api/v1/routes';
import api from '../../../../../api/v1/api';
import form_authenticity_token from '../../../../../api/v1/form_authenticity_token';
import FlashModal from '../../../../general/FlashModal';
import { sleep } from '../../../../../../helpers';
import SectionLoader from '../../../../general/SectionLoader';
import refreshPage from '../../../../../../utilities/refreshPage';

const CancelPickup = ({ ref_code, order_grandtotal }) => {
  const [modalVisible, setModalVisible] = useState(false);
  const [flash, setFlash] = useState('');
  const [is_loading, setIsLoading] = useState(false);

  const cancelOrder = async () => {
    try {
      setIsLoading(true);
      const { data } = await api.put(
        users_dashboards_new_order_flow_cancel_pickup_path,
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

      await sleep(2);
      setIsLoading(false);

      switch (data.message) {
        case 'order_cancelled':
          setModalVisible(false);
          await sleep(0.25);
          setFlash('Your order has been cancelled.');
          break;
        case 'not_cancellable':
          setModalVisible(false);
          await sleep(0.25);
          setFlash('This order is not cancellable');
          break;
        default:
          break;
      }
    } catch (err) {
      setFlash(err.message);
    }
  };

  return (
    <>
      <FlashModal flash_message={flash} onClose={() => refreshPage()} />
      <ConfirmModal
        visible={!!modalVisible}
        onBackdropPress={() => setModalVisible(false)}
      >
        <div className="w-full flex-column justify-center items-center px-4">
          <h3 className="font-bold text-sm mb-2">
            Once this order has been cancelled, it may take up to 48 hours for
            you to receive your refund for the order's total amount of{' '}
            {order_grandtotal}.
          </h3>

          <h3 className="font-bold text-sm mb-2">
            Cancel your order and refund {order_grandtotal}?
          </h3>
        </div>

        <div className="w-full absolute bottom-0 left-0 flex justify-between items-center">
          <button
            className={
              'w-5/12 inline-block py-2 px-4 text-sm rounded bg-white text-blue-600 underline font-black focus:outline-none'
            }
            onClick={() => setModalVisible(false)}
          >
            Nevermind
          </button>
          <button
            disabled={is_loading}
            className={
              'w-5/12 inline-block py-2 px-4 text-xs rounded bg-white text-red-600 border-2 border-red-600 font-bold focus:outline-none'
            }
            onClick={cancelOrder}
          >
            {is_loading ? (
              <span className="flex justify-center items-center">
                <span className="pr-2">Cancelling</span>
                <SectionLoader color="red" height={16} width={16} />
              </span>
            ) : (
              'CANCEL ORDER'
            )}
          </button>
        </div>
      </ConfirmModal>

      <div className="bg-white border-ob py-2 px-6 mb-24">
        <button
          className="text-center text-xs text-red-600"
          onClick={() => setModalVisible(true)}
        >
          Cancel Order
        </button>
      </div>
    </>
  );
};

export default CancelPickup;
