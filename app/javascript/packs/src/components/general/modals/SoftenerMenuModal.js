import React from 'react';
import DroppsLogo from '../../../assets/images/dropps-logo.png';
import SoftenerCleanScent from '../../../assets/images/softener-clean-scent.png';
import SoftenerUncented from '../../../assets/images/softener-unscented.png';
import Modal from 'react-modal';

const SoftenerMenuModal = ({ visible, onClose }) => {
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
      <div className="w-full max-w-xs h-full px-2 py-2 ">
        <div className="flex-row justify-center items-center mb-2">
          <img src={DroppsLogo} alt="" />
          <h3 className="text-sm">
            Dye-free, phthalate-free, phosphate-free and animal-cruelty-free.
          </h3>
        </div>

        <h1 className="text-base font-black text-left mb-1">SOFTENERS</h1>

        <div className="w-full flex justify-start items-center mb-4">
          <img src={SoftenerCleanScent} alt="" />

          <div className="ml-2">
            <h3 className="font-black text-sm ">
              Clean Scent{' '}
              <span className="font-normal"> (for most fabrics)</span>
            </h3>

            <p className="font-normal text-sm leadinng-snug">
              "A hint of citrus, a touch of pine. Like your laundry was
              line-dried in the sun."
            </p>
          </div>
        </div>

        <div className="w-full flex justify-start items-center">
          <img src={SoftenerUncented} alt="" />

          <div className="ml-2">
            <h3 className="font-black text-sm ">Uncented</h3>

            <p className="font-normal text-sm leadinng-snug">
              "Zero. Zilch. Nada. Like a whole lot of sweet nothingness."
            </p>
          </div>
        </div>
      </div>
    </Modal>
  );
};

export default SoftenerMenuModal;
