import React from 'react';

const OrderDetail = ({
  detergent,
  softener,
  est_delivery,
  bag_count,
  order_grandtotal,
}) => {
  return (
    <div className={'px-6 py-2 border-b border-gray-200'}>
      <div>
        <p className={'text-sm tracking-tight font-black text-gray-900'}>
          YOUR ORDER
        </p>
        <p className={'text-sm tracking-tight font-bold text-gray-900'}>
          BAGS: {bag_count}
        </p>
        <p className={'text-sm tracking-tight font-bold text-gray-900'}>
          DETERGENT: {detergent}
        </p>
        <p className={'text-sm tracking-tight font-bold text-gray-900'}>
          SOFTENER: {softener}
        </p>

        <p className={'text-sm tracking-tight font-bold text-green-700'}>
          ORDER TOTAL: {order_grandtotal}
        </p>
      </div>
      <div>
        <p className={'text-sm tracking-tight font-black text-gray-900'}>
          EST. DELIVERY
        </p>
        <p className={'text-sm tracking-tight font-bold text-gray-900'}>
          {est_delivery}
        </p>
      </div>
    </div>
  );
};

export default OrderDetail;
