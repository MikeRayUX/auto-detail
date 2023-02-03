import React from 'react';

const SelectSection = ({
  sectionTitle,
  options,
  order,
  setOrder,
  bgColor,
  order_key,
  selectedOption,
  setSelectedOption,
  item_count,
  onHeaderButtonClick,
}) => {
  const styles = {
    container: 'w-full flex-column justify-center items-center mb-4 sm:px-10',
    heading:
      'text-center text-base font-black tracking-wide text-gray-900 leading-none mb-1',
    options: {
      container: `flex flex-row flex-wrap justify-start items-center mx-auto mb-6 break-all border-t-2 border-b-2 border-l-2 border-primary`,
      selected: `w-1/${item_count} inline-block border-primary bg-primary py-2 px-1 font-black text-xs  text-white text-center focus:outline-none tracking-wide transition-all ease-in duration-100 transform `,
      unselected: `w-1/${item_count} inline-block border-r-2 bg-white border-primary py-2 px-1 font-black text-xs text-gray-900 text-center focus:outline-none tracking-wide transition-all ease-in duration-100 transform `,
    },
  };

  return (
    <div className={styles.container}>
      <div className="w-full">
        <div className="w-full flex flex-row justify-center items-center py-2">
          <h1 className={styles.heading}>{sectionTitle.toUpperCase()}</h1>
          {onHeaderButtonClick ? (
            <button
              className={'focus:outline-none ml-1'}
              onClick={onHeaderButtonClick}
            >
              <ion-icon
                class="text-xl text-gray-900 font-black"
                name="help-circle-outline"
              ></ion-icon>
            </button>
          ) : null}
        </div>
      </div>
      <div className={styles.options.container}>
        {options.map((option) => {
          return (
            <button
              className={
                selectedOption.value == option.value
                  ? styles.options.selected
                  : styles.options.unselected
              }
              key={option.enum}
              onClick={() => {
                setOrder({
                  ...order,
                  [`${order_key}`]: option.enum,
                });

                setSelectedOption(option);
              }}
            >
              {option.value}
            </button>
          );
        })}
      </div>
    </div>
  );
};

export default SelectSection;
