import React, { useEffect, useState } from 'react';

const Day = ({
  day,
  selectedDay,
  setSelectedDay,
  setSelectedDate,
  order,
  setOrder,
  setSelectedTime,
}) => {
  return (
    <>
      {day.holiday ? (
        <button
          disabled={true}
          className={
            'w-1/5 border-r-2 border-gray-900 py-2 text-sm text-center flex-column justify-center items-center focus:outline-none bg-gray-300'
          }
        >
          <div className={''}>
            <h3
              className={
                'font-black text-white text-base text-gray-600 leading-none mb-1'
              }
            >
              {day.day}
            </h3>
          </div>
          <div className={''}>
            <h3 className={'font-black text-gray-600 text-lg leading-none'}>
              {day.date}
            </h3>
          </div>
        </button>
      ) : (
        <button
          className={
            selectedDay == day.day
              ? 'w-1/5 border-r-2 border-primary py-2 font-black text-sm text-center bg-primary text-white flex-column justify-center items-center focus:outline-none'
              : 'w-1/5 border-r-2 border-gray-900 py-2 text-gray-900 font-black text-sm text-center flex-column justify-center items-center focus:outline-none'
          }
          onClick={async () => {
            setSelectedDay(day.day);
            setSelectedDate(day);
            setOrder({
              ...order,
              pickup_date: day.value,
              pickup_time: '',
            });
            // await sleep(1.5);
            setSelectedTime('');
            // setTimesLoading(false);
          }}
        >
          <div className={''}>
            <h3
              className={
                selectedDay == day.day
                  ? 'font-black text-white text-base leading-none mb-1'
                  : 'font-black text-gray-900 text-base leading-none mb-1'
              }
            >
              {day.day}
            </h3>
          </div>
          <div className={''}>
            <h3
              className={
                selectedDay == day.day
                  ? 'font-black text-white text-lg leading-none'
                  : 'font-black text-gray-900 text-lg leading-none'
              }
            >
              {day.date}
            </h3>
          </div>
        </button>
      )}
    </>
  );
};

export default Day;
