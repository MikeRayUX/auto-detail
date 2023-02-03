import React from 'react';
import Modal from 'react-modal';

const BagInfoModal = ({ visible, onClose }) => {
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
      <div className={'max-w-sm px-2 py-2'}>
        <div className={'w-full mx-auto p-4 bg-white'}>
          <div className={'flex-columb justify-center items-center mb-2'}>
            <h3 className={'text-base text-center my-2'}>
              Each Reusable Tumble Bag is machine washable and holds up to{' '}
              <span className={'font-bold'}>
                20 lbs of laundry or two standard loads.
              </span>
            </h3>

            <h3 className={'text-base text-center mb-2'}>
              On your first order, place your laundry in{' '}
              <span className={'font-bold'}>
                standard sized Tall Kitchen Trash Bags (13 gallon).
              </span>{' '}
              When filled to capacity, it will most accurately match the size of
              our reusable Fresh And Tumble Bags.
            </h3>

            <h3 className={'text-base font-bold text-center mb-2'}>
              Upon delivery, your clean laundry will arrive in new Fresh And
              Tumble Bags. Please reuse your Tumble Bags on future Fresh And
              Tumble Orders.
            </h3>

            <h3 className={'text-sm text-red-600 font-bold text-center mb-4'}>
              *Please don't over-stuff your bags. We always give it our best
              attempt at making everything fit, but if the bag cannot properly
              close, any excess laundry that doesn't fit will be returned to you
              in a plastic bag your pickup is completed.
            </h3>
          </div>

          <button
            onClick={onClose}
            className={
              'w-full py-4 rounded-b border-t border-gray-400 bg-primary'
            }
          >
            <h3 className={'text-base font-bold text-white text-center'}>
              Dismiss
            </h3>
          </button>
        </div>
      </div>
    </Modal>
  );
};

export default BagInfoModal;
