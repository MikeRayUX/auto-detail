import React from 'react';
import DroppsLogo from '../../../assets/images/dropps-logo.png';
import DetergentCleanScent from '../../../assets/images/detergent-clean-scent.png';
import DetergentSensitiveSkin from '../../../assets/images/detergent-sensitive-skin.png';
import Modal from 'react-modal';

const DetergentMenuModal = ({ visible, onClose }) => {
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
      <div className="max-w-xs px-2 py-2">
        <div className="flex-row justify-center items-center mb-2">
          <img src={DroppsLogo} alt="" />
          <h3 className="text-sm">
            Dye-free, phthalate-free, phosphate-free and animal-cruelty-free.
          </h3>
        </div>

        <h1 className="text-base font-black text-left mb-1">DETERGENTS</h1>

        <div className=" flex justify-start items-center mb-4">
          <img src={DetergentCleanScent} alt="" />

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
          <img src={DetergentSensitiveSkin} alt="" />

          <div className="ml-2">
            <h3 className="font-black text-sm ">
              Sensitive Skin <span className="font-normal"> (gentle)</span>
            </h3>

            <p className="font-normal text-sm leadinng-snug">
              "Our most gentle clean, for sensitive skin and natural fabrics"
            </p>
          </div>
        </div>
      </div>
    </Modal>
  );
};

export default DetergentMenuModal;
