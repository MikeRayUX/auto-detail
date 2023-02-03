import React from 'react';
import Modal from 'react-modal';

const FlashModal = ({ flash_message, onClose }) => {
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
    <Modal
      isOpen={!!flash_message}
      onRequestClose={onClose}
      style={customStyles}
    >
      <div
        style={{ width: 360, height: 360 }}
        className="max-w-xs px-2 py-2 relative flex-column justify-center items-center"
      >
        <div className={'text-center mb-4'}>
          <ion-icon
            class="text-6xl font-bold text-center text-primary"
            name="alert-circle-outline"
          ></ion-icon>
        </div>
        <h1 className="text-center leading-snug text-sm text-gray-900 mb-4">
          {flash_message}
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

export default FlashModal;
