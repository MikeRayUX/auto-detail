export const getInputValue = (name) => {
  return document.querySelector(`input[name='${name}']`).value;
};

export const floatFromInput = (name) => {
  return parseFloat(document.querySelector(`input[name='${name}']`).value);
};

export const getMetaContent = (name) => {
  return document.querySelector(`meta[name='${name}']`).content;
};

export const getElement = (element) => {
  return document.querySelector(`${element}`);
};
