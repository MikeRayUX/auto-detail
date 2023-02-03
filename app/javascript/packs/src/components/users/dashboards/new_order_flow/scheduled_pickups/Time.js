import React from 'react';

const Time = ({ time, selectedTime, setSelectedTime, order, setOrder }) => {
  return (
    <>
      <button
        key={time}
        className={
          selectedTime == time
            ? 'w-1/3 border-r-2 border-gray-900 py-4 px-4 bg-primary focus:outline-none'
            : 'w-1/3 border-r-2 border-gray-900 py-4 px-4 focus:outline-none'
        }
        onClick={() => {
          setSelectedTime(time);
          setOrder({
            ...order,
            pickup_time: time,
          });
        }}
      >
        <h3
          className={
            selectedTime == time
              ? 'text-white font-black text-base text-center'
              : 'text-gray-900 font-black text-base text-center'
          }
        >
          {time}
        </h3>
      </button>
    </>
  );
};

export default Time;
