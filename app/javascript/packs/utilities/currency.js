export const readableDecimal = (float) => {
  return (Math.round(float * 100) / 100).toFixed(2);
};
