import React, { useState, useEffect } from 'react';
// import { readableDecimal } from '../../../../../../../utilities/currency';

const BagCount = ({ order, setOrder, setBagInfoModalVisible }) => {
  const ppb = document.querySelector('#ppb').value;

  // state
  const [price, setPrice] = useState('');
  const [price_breakdown, setPriceBreakdown] = useState('');

  useEffect(() => {
    setPrice(ppb);
    displayPrice();
  }, []);

  useEffect(() => {
    displayPrice();
  }, [order.bag_count, price]);

  const displayPrice = () => {
    let price = parseInt(ppb) * order.bag_count;

    setPrice(price);
    setPriceBreakdown(`(${order.bag_count}x$${ppb})`);
  };
  return (
    <div className={styles.container}>
      <div className={'w-full flex-column justify-center items-center pb-2'}>
        <div className={'flex flex-row justify-center items-center'}>
          <h1
            className={
              'text-center text-base font-black tracking-wide text-gray-900 leading-none'
            }
          >
            TUMBLE BAGS {`($${ppb} EACH)`}
          </h1>

          <button
            className={'focus:outline-none ml-1 mt-1'}
            onClick={() => setBagInfoModalVisible(true)}
          >
            <ion-icon
              class="text-xl text-gray-900 font-black"
              name="help-circle-outline"
            ></ion-icon>
          </button>
        </div>

        <h1
          className={
            'text-center mb-2 text-sm font-bold tracking-wide text-gray-900 leading-none'
          }
        >
          (holds 2-3 standard loads)
        </h1>
      </div>
      <div className={'flex flex-row justify-between items-center'}>
        <div className={styles.options.container}>
          <button
            className={styles.options.selected}
            onClick={() => {
              if (order.bag_count > 1) {
                setOrder({
                  ...order,
                  bag_count: order.bag_count - 1,
                });
              }
            }}
          >
            -
          </button>
          <button className={styles.options.unselected}>
            {order.bag_count}
          </button>
          <button
            className={styles.options.selected}
            onClick={() => {
              setOrder({
                ...order,
                bag_count: order.bag_count + 1,
              });
            }}
          >
            +
          </button>
        </div>

        <div className={'flex flex-row justify-start items-center mb-6'}>
          <div className={'flex flex-row items-center'}>
            <h1
              className={
                'text-3xl font-black flex flex-row justify-start items-start text-right'
              }
            >
              ${price}
            </h1>
            <p className={'pl-1 text-right text-sm font-black'}>
              {price_breakdown}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default BagCount;

const styles = {
  container:
    'w-full flex-column justify-center items-center px-4 mt-8 sm:px-10',
  heading:
    'text-center text-base font-black tracking-wide text-gray-900 leading-none mb-2',
  text:
    'text-center my-2 mt-2 text-sm font-black tracking-wide text-gray-900 mb-1 h-6',
  options: {
    container: `w-1/2 flex flex-row justify-start items-center mb-6 break-all border-b-3 border-primary`,
    selected: `w-1/3 inline-block border-primary py-1 px-1 bg-primary text-white font-black text-2xl text-center focus:outline-none tracking-wide`,
    unselected: `w-1/3 inline-block border-primary py-1 px-1 text-black-900 font-black text-2xl text-center focus:outline-none tracking-wide bg-gray-300`,
  },
};
