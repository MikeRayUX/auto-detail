import React, { useEffect } from 'react';
import SectionLoader from '../../../../general/SectionLoader';
// import form_authenticity_token from '../../../../../api/v1/form_authenticity_token';

const RailsForm = ({
  order,
  form_valid,
  form_submitting,
  setFormSubmitting,
  submitText,
}) => {
  const fillFormFields = () => {
    document.querySelector("input[name='new_order[pickup_type]'").value =
      order.pickup_type;
    document.querySelector("input[name='new_order[pickup_date]'").value =
      order.pickup_date;
    document.querySelector("input[name='new_order[pickup_time]'").value =
      order.pickup_time;
    document.querySelector("input[name='new_order[detergent]'").value =
      order.detergent;
    document.querySelector("input[name='new_order[softener]'").value =
      order.softener;
    document.querySelector("input[name='new_order[bag_count]'").value =
      order.bag_count;
  };

  useEffect(() => {
    fillFormFields();
  }, [order]);

  return (
    <>
      <div className={styles.container}>
        <form
          action="/users/dashboards/new_order_flow/confirm_pickups/new"
          acceptCharset="UTF-8"
          method="get"
        >
          <input name="utf8" type="hidden" value="✓"></input>
          {/* <input
            type="hidden"
            name="authenticity_token"
            value={form_authenticity_token()}
          ></input> */}
          <input
            type="hidden"
            name="new_order[pickup_type]"
            id="new_order_pickup_type"
          ></input>

          <input
            type="hidden"
            name="new_order[pickup_date]"
            id="new_order_pickup_date"
          ></input>
          <input
            type="hidden"
            name="new_order[pickup_time]"
            id="new_order_pickup_time"
          ></input>
          <input
            type="hidden"
            name="new_order[detergent]"
            id="new_order_detergent"
          ></input>
          <input
            type="hidden"
            name="new_order[softener]"
            id="new_order_softener"
          ></input>
          <input
            type="hidden"
            name="new_order[bag_count]"
            id="new_order_bag_count"
          ></input>
          <button
            type="submit"
            name="commit"
            onClick={() => setFormSubmitting(true)}
            className={
              form_valid ? styles.button.enabled : styles.button.disabled
            }
            disabled={!form_valid}
          >
            {form_submitting ? (
              <SectionLoader color="white" width={30} height={24} />
            ) : (
              submitText
            )}
          </button>
        </form>
      </div>
    </>
  );
};

export default RailsForm;

const styles = {
  container: 'w-full ',
  button: {
    enabled:
      'block w-full py-4 mt-4 bg-green-600 text-white font-black focus:outline-none mb-4 transition-all ease-in-out duration-500 transform',
    disabled:
      'block w-full py-4 mt-4 bg-gray-300 text-gray-800 font-black focus:outline-none mb-4 transition-all ease-in-out duration-600 transform',
  },
};
