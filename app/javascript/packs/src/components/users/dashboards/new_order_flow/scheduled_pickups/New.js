import React, { useState, useEffect, useContext } from 'react';
import ReactDOM from 'react-dom';
import { getInputValue } from '../../../../../../utilities/getValue';
import api from '../../../../../api/v1/api';
import { users_dashboards_new_order_flow_scheduled_timeslots_path } from '../../../../../api/v1/routes';
import FlashModal from '../../../../general/FlashModal';
import SectionLoader from '../../../../general/SectionLoader';
import RailsForm from './RailsForm';
import redirectTo from '../../../../../../utilities/redirectTo';
import SessionTimeoutInterval from '../../../../general/SessionTimeoutInterval';
import Day from './Day';
import Time from './Time';

const bag_count = getInputValue('bag_count');
const detergent_value = getInputValue('detergent_value');
const softener_value = getInputValue('softener_value');

const New = () => {
  const [flash_message, setFlashMessage] = useState('');
  const [form_submitting, setFormSubmitting] = useState(false);

  // dates
  const [dates_for_select, setDatesForSelect] = useState([]);
  const [selectedDay, setSelectedDay] = useState('');
  const [selected_date, setSelectedDate] = useState({});
  const [selectedTime, setSelectedTime] = useState('');

  const [order, setOrder] = useState({
    pickup_type: 'scheduled',
    detergent: detergent_value,
    softener: softener_value,
    bag_count: bag_count,
    pickup_date: '',
    pickup_time: '',
  });

  useEffect(() => {
    getDates();
  }, []);

  const getDates = async () => {
    try {
      const { data } = await api.get(
        users_dashboards_new_order_flow_scheduled_timeslots_path
      );

      // console.log(data.dates_for_select);
      switch (data.message) {
        case 'dates_returned':
          setDatesForSelect(data.dates_for_select);
          break;
        default:
          break;
      }
    } catch (err) {
      setFlashMessage(err.message);
    }
  };

  return (
    <div className={styles.container}>
      <FlashModal
        flash_message={flash_message}
        onClose={() => setFlashMessage('')}
      />

      <SessionTimeoutInterval
        MINUTES_TO_EXPIRE={7}
        onInterval={() => {
          getDates();
        }}
        onExpire={() => {
          redirectTo('/users/dashboards/new_order_flow/pickups/new');
        }}
      />

      <div className={''}>
        {/* order form */}
        <div className={styles.order_form.container}>
          {dates_for_select.length ? (
            <div className={styles.order_form.datepicker.container}>
              <div className={styles.order_form.datepicker.header_container}>
                <div
                  className={
                    styles.order_form.datepicker.header_container_inner
                  }
                >
                  <h3 className={styles.order_form.datepicker.heading}>
                    PICK A DATE
                  </h3>
                </div>
              </div>
              <div
                className={
                  styles.order_form.datepicker.days_for_select_container
                }
              >
                {dates_for_select.map((day) => {
                  return (
                    <Day
                      key={day.day}
                      day={day}
                      selectedDay={selectedDay}
                      setSelectedDay={setSelectedDay}
                      setSelectedDate={setSelectedDate}
                      order={order}
                      setOrder={setOrder}
                      setSelectedTime={setSelectedTime}
                    />
                  );
                })}
              </div>

              {selected_date.date ? (
                <div
                  className={
                    styles.order_form.datepicker.times_for_select_container
                  }
                >
                  <div className={'w-full py-2'}>
                    <div
                      className={
                        styles.order_form.datepicker
                          .time_for_select_heading_container
                      }
                    >
                      <h3
                        className={
                          styles.order_form.datepicker.time_for_select_heading
                        }
                      >
                        PICK A TIME
                      </h3>
                    </div>
                  </div>
                  <div
                    className={
                      styles.order_form.datepicker.time_for_select_container
                    }
                  >
                    {selected_date.timeslots.map((time) => {
                      return (
                        <Time
                          key={time}
                          time={time}
                          selectedTime={selectedTime}
                          setSelectedTime={setSelectedTime}
                          order={order}
                          setOrder={setOrder}
                        />
                      );
                    })}
                  </div>
                </div>
              ) : null}

              <div className={styles.order_form.success_container}>
                {selectedDay && selectedTime ? (
                  <ion-icon
                    class="text-3xl text-center text-green-600"
                    name="checkmark-circle"
                  ></ion-icon>
                ) : null}
              </div>

              <div className={styles.rails_form_container_outer}>
                <div className={styles.rails_form_container_inner}>
                  <RailsForm
                    order={order}
                    form_valid={selectedDay && selectedTime}
                    form_submitting={form_submitting}
                    setFormSubmitting={setFormSubmitting}
                    submitText={'Continue'}
                  />
                </div>
              </div>
            </div>
          ) : (
            <div className={styles.loader_container}>
              <SectionLoader color="#d70cf5" height={40} width={40} />
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

const styles = {
  container: 'h-full bg-white',
  order_form: {
    container:
      'w-full border-gray-200 rounded bg-white p-2 sm:max-w-lg sm:mt-8 sm:py-2 sm:px-8 mx-auto',
    datepicker: {
      container: 'max-w-xl w-full px-4 mt-4',
      header_container: 'w-full py-2',
      header_container_inner:
        'w-full flex flex-row justify-center items-center mb-2',
      heading:
        'w-full text-base text-white font-black text-center text-gray-900',
      days_for_select_container:
        'w-full flex flex-row justify-center items-center border-t-2 border-l-2 border-b-2 border-gray-900 mb-2',
      times_for_select_container:
        'w-full rounded-b flex-column justify-between items-center',
      time_for_select_heading_container:
        'w-full flex justify-center items-center mb-2',
      time_for_select_heading:
        'w-full text-base text-white font-black text-center text-gray-900',
      time_for_select_container:
        'w-full items-center border-t-2 border-l-2 border-b-2 border-gray-900 flex-row justify-start items-center flex-wrap rounded-b',
    },
    success_container: 'w-full flex flex-row justify-center items-center mt-4',
  },
  rails_form_container_outer: 'w-full flex justify-center items-center mt-6',
  rails_form_container_inner: 'max-w-xl w-full',
  loader_container: 'flex-1 flex justify-center items-center',
};

const App = document.createElement('div');

App.setAttribute('id', 'App');

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(<New />, document.body.appendChild(App));
});
