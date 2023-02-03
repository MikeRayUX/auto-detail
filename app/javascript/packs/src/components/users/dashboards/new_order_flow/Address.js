import React from 'react';
import { getInputValue } from '../../../../../utilities/getValue';

const current_address = document.querySelector("input[name='current_address']")
  .value;

const pick_up_directions = document.querySelector(
  "input[name='pick_up_directions']"
).value;

const Address = ({ est_delivery }) => {
  return (
    <div className={'py-2'}>
      <div className={' '}>
        <div>
          <p className={'text-sm font-black text-gray-900'}>ADDRESS</p>
          <p className={'text-sm font-bold text-gray-900'}>{current_address}</p>
        </div>

        {!!pick_up_directions ? (
          <div className={''}>
            <p className={'text-sm font-black text-gray-900'}>Pickup notes:</p>
            <p className={'text-sm font-bold text-gray-900'}>
              "{pick_up_directions}"
            </p>
          </div>
        ) : null}
        {est_delivery ? (
          <div className={'flex flex-row justify-start items-center'}>
            <p className={'text-sm font-black text-gray-900 text-left'}>
              EST. DELIVERY {est_delivery}
            </p>
          </div>
        ) : null}
      </div>
    </div>
  );
};

export default Address;
