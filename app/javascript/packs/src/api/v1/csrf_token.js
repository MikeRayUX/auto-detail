export default () => {
  return document.querySelector("meta[name='csrf-token']").content;
};
