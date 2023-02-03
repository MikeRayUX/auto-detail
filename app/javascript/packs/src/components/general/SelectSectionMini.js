import React from 'react';

const SelectSectionMini = ({
  options,
  selectedOption,
  setSelectedOption,
  option_prefix,
}) => {
  return (
    <div
      className={
        'w-48 flex flex-row justify-start items-center border-t-2 border-b-2 border-l-2 border-primary'
      }
    >
      {options.map((option) => {
        return (
          <button
            className={
              selectedOption == option
                ? `w-1/${options.length} inline-block border-primary bg-primary py-1 px-4 font-black text-sm text-white text-center focus:outline-none outline-none tracking-wide transition-all ease-in duration-100 transform h-full box-border`
                : `w-1/${options.length} inline-block border-r-2 bg-white border-primary py-1 px-4 font-black text-sm h-full text-gray-900 text-center outline-none focus:outline-none tracking-wide transition-all ease-in duration-100 transform box-border `
            }
            key={option}
            onClick={() => setSelectedOption(option)}
          >
            {option_prefix || null}
            {option}
          </button>
        );
      })}
    </div>
  );
};

export default SelectSectionMini;
