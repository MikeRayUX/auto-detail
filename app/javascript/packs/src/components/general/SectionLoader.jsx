import React from 'react';
import Loader from 'react-loader-spinner';

const SectionLoader = ({ color, width, height, noMarginAuto }) => {
  return (
    <div className={noMarginAuto ? '' : 'mx-auto'} style={{ width: width }}>
      <Loader
        type="ThreeDots"
        color={color}
        height={height}
        width={width}
        timeout={300000}
      />
    </div>
  );
};

export default SectionLoader;
