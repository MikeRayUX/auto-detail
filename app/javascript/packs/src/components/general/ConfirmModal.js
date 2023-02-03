import React from 'react';
import Modal from 'react-modal';

const ConfirmModal = ({ children, visible, onBackdropPress }) => {
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
      isOpen={visible}
      onRequestClose={onBackdropPress}
      style={customStyles}
    >
      <div
        style={{ width: 360, height: 360 }}
        className="relative w-full h-full px-2 relative flex-column justify-center items-center"
      >
        <div className={'text-center'}>
          <ion-icon
            class="text-6xl font-bold text-center text-primary"
            name="alert-circle-outline"
          ></ion-icon>
        </div>
        {children}
      </div>
    </Modal>
  );
};

export default ConfirmModal;
