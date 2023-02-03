import React, { useState } from 'react';
import { sleep } from '../../../../../../helpers';
import form_authenticity_token from '../../../../../api/v1/form_authenticity_token';
import SectionLoader from '../../../../general/SectionLoader';

const PickupStatus = ({
  order_status,
  customer_status,
  est_pickup_by,
  refreshWaitForWasher,
  waitButtonLoading,
  pollingActive,
  delivery_photo_base64,
  readable_delivery_location,
}) => {
  return (
    <div className=" border-b py-2 px-6">
      {order_status == 'offer_expired' ? (
        <div className="w-full h-full flex-row justify-center items-center ">
          <div className={'flex flex-row justify-center items-center'}>
            <p className={'text-xs font-black text-gray-900 text-center ml-1'}>
              IT'S TAKING LONGER THAN USUAL TO FIND A WASHER
            </p>
          </div>
          <div className="flex justify-center items-center py-2">
            <button
              className="text-center py-1 px-2 text-xs rounded bg-primary text-white font-black focus:outline-none"
              onClick={refreshWaitForWasher}
            >
              {waitButtonLoading ? (
                <span className="flex justify-center items-center">
                  <span className="pr-2">KEEP WAITING</span>
                  <SectionLoader color="white" height={16} width={16} />
                </span>
              ) : (
                'KEEP WAITING'
              )}
            </button>
          </div>
        </div>
      ) : (
        <div className="w-full h-full flex-row justify-center items-center ">
          {!!est_pickup_by && order_status != 'cancelled' ? (
            <div className={'flex flex-row justify-center items-center'}>
              <ion-icon name="time-outline"></ion-icon>
              <p
                className={
                  'text-sm tracking-tight font-black text-gray-900 text-center ml-1'
                }
              >
                EST. PICKUP BY {est_pickup_by}
              </p>
            </div>
          ) : null}

          <div className="w-full h-full flex justify-center items-center">
            <p className="text-center tracking-tight font-black text-xs mr-2">
              {customer_status}
            </p>
            {pollingActive ? (
              <SectionLoader
                color="#d70cf5"
                height={20}
                width={20}
                noMarginAuto={true}
              />
            ) : null}
          </div>
        </div>
      )}

      {delivery_photo_base64 ? (
        <div className="p-2 rounded w-32 my-2  mx-auto">
          <img
            className="mx-auto mb-1"
            src={`data:image/png;base64,${delivery_photo_base64}`}
            alt=""
          />

          <div className="w-full">
            <h1 className="text-xs tracking-tight font-bold text-center">
              "{readable_delivery_location}"
            </h1>
          </div>
        </div>
      ) : null}
    </div>
  );
};

export default PickupStatus;
