export const seconds = (seconds) => {
  return seconds * 1000;
};

export const minutes = (minutes) => {
  return minutes * 60 * 1000;
};

export const sleep = (secs) => {
  return new Promise((resolve) => setTimeout(resolve, seconds(secs)));
};
