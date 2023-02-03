import React from 'react';
import Modal from 'react-modal';

const NoWashersAvailableFlash = ({ visible, onClose }) => {
  const customStyles = {
    content: {
      top: '50%',
      left: '50%',
      right: 'auto',
      bottom: 'auto',
      marginRight: '-50%',
      transform: 'translate(-50%, -50%)',
    },
  };
  return (
    <Modal isOpen={visible} onRequestClose={onClose} style={customStyles}>
      <div
        style={{ width: 360, height: 360 }}
        className="w-full h-full px-2  relative flex-column justify-center items-center"
      >
        <div className={'text-center mb-2'}>
          <ion-icon
            class="text-6xl font-bold text-center text-primary"
            name="alert-circle-outline"
          ></ion-icon>
        </div>
        <h1 className="text-center leading-normal text-base text-gray-900 mb-4 font-bold">
          The ASAP option is currently unavailable.
        </h1>

        <h1 className="text-left leading-normal text-sm text-gray-900 mb-4 font-bold">
          This is usually due to unusually high demand for ASAP orders and not
          enough available Washers in your area to meet the demand at this
          moment.
        </h1>

        <h1 className="text-left leading-normal text-sm text-gray-900 mb-4 font-bold">
          Don't worry, you can always Schedule a pickup for later or if that
          doesn't work, check back in a few minutes.
        </h1>

        <h1 className="text-center leading-normal text-sm text-gray-900 mb-4 font-bold">
          We're sorry for the inconvenience.
        </h1>

        <button
          className="absolute bottom-0 right-0 block text-center w-full py-4 rounded font-bold bg-primary text-white focus:outline-none"
          onClick={onClose}
        >
          Okay
        </button>
      </div>
    </Modal>
  );
};

export default NoWashersAvailableFlash;
