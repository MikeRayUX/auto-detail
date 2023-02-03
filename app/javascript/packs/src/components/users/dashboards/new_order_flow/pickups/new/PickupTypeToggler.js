import React, { useState } from 'react';
import { availability_users_dashboards_new_order_flow_pickup_path } from '../../../../../../api/v1/routes';
import SectionLoader from '../../../../../general/SectionLoader';

const PickupTypeToggler = ({
  is_loading,
  asap,
  setAsap,
  asapEnabled,
  order,
  setOrder,
  availability_flash,
  setFlashMessage,
}) => {
  const current_address = document.querySelector(
    'input[name="current_address"]'
  ).value;

  return (
    <div className={styles.container}>
      <div
        className={
          'flex-colummn justify-center mx-auto w-sm text-center items-center sm:flex-row sm:flex sm:justify-center sm:items-center'
        }
      >
        {is_loading ? (
          <div className={'w-48'}>
            <SectionLoader color="#d70cf5" height={33} width={33} />
          </div>
        ) : (
          <button
            className={styles.toggler.container}
            onClick={() => {
              if (asapEnabled) {
                setOrder({
                  ...order,
                  pickup_type:
                    order.pickup_type == 'asap' ? 'scheduled' : 'asap',
                });
                setAsap(!asap);
              } else {
                setFlashMessage(availability_flash);
              }
            }}
          >
            <div
              className={
                asap ? styles.button.selected : styles.button.unselected
              }
            >
              ASAP
            </div>
            <div
              className={
                asap ? styles.button.unselected : styles.button.selected
              }
            >
              LATER
            </div>

            {/* animated block */}
            <div
              className={
                asap
                  ? styles.toggler.toggler.left
                  : styles.toggler.toggler.right
              }
            ></div>
          </button>
        )}

        <a
          href="/users/dashboards/settings/update_addresses"
          className={
            'font-black text-center text-gray-900 sm:pl-2 text-sm sm:text-base'
          }
        >
          TO {current_address}
        </a>
      </div>
    </div>
  );
};

export default PickupTypeToggler;

const styles = {
  container:
    'w-full py-2 bg-white border-r border-b border-l flex justify-center items-center',
  toggler: {
    container:
      'relative w-48 flex justify-start items-center border-2 border-primary focus:outline-none appearance-none select-none rounded-full mb-2 sm:mb-0',
    toggler: {
      left:
        'inline-block w-1/2 h-full bg-primary absolute transition-all ease-in-out duration-200 transform translate-x-0 rounded-full',
      right:
        'inline-block w-1/2 h-full bg-primary absolute transition-all ease-in-out duration-200 transform translate-x-full rounded-full',
    },
  },
  button: {
    selected:
      'w-1/2 inline-block h-full py-1 font-black text-sm text-center z-10 text-white focus:outline-none transition-all ease-in-out duration-100 transform rounded-full',
    unselected:
      'w-1/2 inline-block h-full py-1 bg-white font-black text-sm text-black text-center z-10 text-gray-900 focus:outline-none transition-all ease-in-out duration-100 transform rounded-full',
  },
};
