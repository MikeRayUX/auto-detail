import React from 'react';

const OnDemandEstimation = ({ estimate }) => {
  return (
    <div className={styles.container}>
      <h3 className={styles.heading}>ESTIMATED PICKUP BY</h3>

      <h3
        className={
          'rounded-full px-2 py-1 font-black text-white bg-primary text-center text-base w-64 mx-auto'
        }
      >
        {estimate}
      </h3>
    </div>
  );
};

const styles = {
  container:
    'w-full flex-column justify-center items-center mt-4 px-4 sm:px-16 mb-12',
  heading:
    'text-center my-2 mt-2 text-base font-black tracking-wide text-gray-900 leading-0 mb-1 flex flex-row justify-center items-center',
};

export default OnDemandEstimation;
