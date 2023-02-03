import React, { useState, useEffect, useContext } from 'react';
import { getInputValue } from '../../../../../../utilities/getValue';

const current_address = getInputValue('current_address');
const readable_scheduled = getInputValue('readable_scheduled');
const est_delivery = getInputValue('est_delivery');

const ScheduledSummary = () => {
  return (
    <div
      className={
        'w-full flex-column justify-center items-center py-2 bg-primary px-2 border-t border-b border-gray-300'
      }
    >
      <div className={'w-full flex-column justify-center items-center  mb-1'}>
        <h3 className={'text-sm font-bold text-white text-center leading-none'}>
          SCHEDULED
        </h3>
        <h3 className={'text-base font-bold text-white text-center ml-2'}>
          {readable_scheduled.toUpperCase()}
        </h3>
      </div>

      <div className={'flex-column justify-center items-center w-full mb-1'}>
        <h3 className={'text-sm font-bold text-white text-center leading-none'}>
          EST. DELIVERY
        </h3>
        <h3 className={'text-base font-bold text-white text-center ml-2'}>
          {est_delivery.toUpperCase()}
        </h3>
      </div>

      <div className={'flex-column justify-center items-center w-full'}>
        <h3 className={'text-sm font-bold text-white text-center leading-none'}>
          ADDRESS
        </h3>
        <h3 className={'text-base font-bold text-white text-center ml-2'}>
          {current_address.toUpperCase()}
        </h3>
      </div>
    </div>
  );
};

export default ScheduledSummary;
