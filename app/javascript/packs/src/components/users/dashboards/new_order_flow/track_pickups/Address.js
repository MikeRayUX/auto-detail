import React from 'react';

const Address = ({ current_address, pick_up_directions }) => {
  return (
    <div className={'px-6 py-2 border-b border-gray-200'}>
      <div>
        <p className={'text-sm tracking-tight font-black text-gray-900'}>
          ADDRESS
        </p>
        <p className={'text-sm tracking-tight font-bold text-gray-900'}>
          {current_address}
        </p>
      </div>
      {!!pick_up_directions ? (
        <div className={''}>
          <p className={'text-xs tracking-tight font-black text-gray-900'}>
            PICKUP NOTES:
          </p>
          <p className={'text-sm tracking-tight font-bold text-gray-900'}>
            "{pick_up_directions}"
          </p>
        </div>
      ) : null}
    </div>
  );
};

export default Address;
