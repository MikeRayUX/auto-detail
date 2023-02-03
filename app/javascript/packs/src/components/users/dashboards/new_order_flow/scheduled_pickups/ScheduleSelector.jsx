import React from 'react';

const ScheduleSelector = ({
  order,
  setOrder,
  dates_for_select,
  selectedDay,
  selected_date,
  setSelectedDate,
  setSelectedDay,
  selectedTime,
  setSelectedTime,
}) => {
  return (
    <div className={styles.container}>
      <div
        className={
          selectedDay
            ? 'w-full py-2 border-t-2 border-r-2 border-l-2 border-primary bg-primary'
            : 'w-full py-2 border-t-2 border-r-2 border-l-2 border-primary bg-white'
        }
      >
        <h3
          className={
            selectedDay
              ? 'text-xs font-black text-white text-center leading-none bg-primary'
              : 'text-xs font-black text-gray-900 text-center leading-none'
          }
        >
          {selectedDay ? (
            <div className="w-full text-white font-black text-center flex justify-center items-center leading-none bg-primary ">
              {selectedDay && selectedTime ? (
                <ion-icon
                  class="text-white mr-1 leading-none text-xs"
                  name="checkmark-circle"
                ></ion-icon>
              ) : (
                <div></div>
              )}
              <div></div>
              <h3 className="text-xs text-white">PICK A DATE</h3>
            </div>
          ) : (
            <p className="bg-white text-gray-900 font-black text-center flex justify-center items-center leading-none">
              PICK A DATE
            </p>
          )}
        </h3>
      </div>
      <div className={'w-full border-t-2 border-l-2 border-b-2 border-primary'}>
        {dates_for_select.map((day) => {
          return (
            <button
              key={day.day}
              className={
                selectedDay == day.day
                  ? styles.day.selected
                  : styles.day.unselected
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
              <p className="leading-none">{day.day}</p>
              <p className="leading-none">{day.date}</p>
            </button>
          );
        })}
      </div>

      {selected_date.date ? (
        <div className={'h-32 w-full'}>
          <div className={'w-full border-l-2 border-b-2 border-primary '}>
            {selected_date.timeslots.map((time) => {
              return (
                <button
                  key={time}
                  className={
                    selectedTime == time
                      ? styles.time.selected
                      : styles.time.unselected
                  }
                  onClick={() => {
                    setSelectedTime(time);
                    setOrder({
                      ...order,
                      pickup_time: time,
                    });
                  }}
                >
                  {time}
                </button>
              );
            })}
          </div>
        </div>
      ) : null}
    </div>
  );
};

export default ScheduleSelector;

const styles = {
  container: 'w-full flex-row justify-start items-center ',
  heading:
    'text-center my-2 mt-2 text-base font-black  tracking-wide text-gray-900 leading-0 mb-1',
  day: {
    unselected:
      'w-1/5 inline-block border-r-2 border-primary py-2 text-gray-900 font-black text-sm text-center focus:outline-none',
    selected:
      'w-1/5 inline-block border-r-2 border-primary py-2 font-black text-sm text-center bg-primary text-white focus:outline-none',
  },
  time: {
    unselected:
      'w-1/3 inline-block border-r-2 border-primary py-1 px-4 text-gray-900 font-black text-sm text-center focus:outline-none',
    selected:
      'w-1/3 inline-block border-r-2 border-primary py-1 px-4 font-black text-sm text-center bg-primary text-white focus:outline-none',
  },
};
