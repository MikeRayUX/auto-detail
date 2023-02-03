import { DateTime } from 'luxon';

// import {
//   activeTabStyles,
//   inactiveTabStyles,
//   invalidFormButtonStyles,
//   validFormButtonStyles,
// } from './element_styles';

export const today = DateTime.local().toFormat('yyyy-MM-dd').toString();

export const toggleTab = (active, inactive) => {
  setStyle(activeTabStyles, active);
  setStyle(inactiveTabStyles, inactive);
};

export const toggleForm = (
  activeTab,
  inactiveTab,
  activeForm,
  inactiveForm
) => {
  toggleTab(activeTab, inactiveTab);
  showElement(activeForm);
  hideElement(inactiveForm);
};

const showElement = (element) => {
  element.classList.add('active');
  element.classList.remove('hidden');
};

const hideElement = (element) => {
  element.classList.remove('active');
  element.classList.add('hidden');
};

export const clearStyles = (element) => {
  element.className = '';
};

export const clearMutipleStyles = (elements) => {
  elements.forEach((elem) => {
    elem.className = '';
  });
};

export const setStyle = (styleList, element) => {
  clearStyles(element);
  styleList.forEach((style) => {
    element.classList.add(style);
  });
};

export const setStyles = (styleList, elements) => {
  elements.forEach((element) => {
    setStyle(styleList, element);
  });
};

export const clearField = (field) => {
  field.value = '';
};

export const clearFields = (fields) => {
  fields.forEach((field) => {
    clearField(field);
  });
};

export const clearElement = (elem) => {
  elem.innerHTML = '';
};

export const clearElements = (elements) => {
  elements.forEach((elem) => {
    elem.innerHTML = '';
  });
};

export const setField = (field, value) => {
  field.value = value;
};

export const disableElement = (styles, elem) => {
  setStyle(styles, elem);
  elem.classList.add('pointer-events-none');
};

export const isButtonDisabled = (button) => {
  return button.classList.contains('pointer-events-none');
};

export const getElem = (selector) => {
  return document.querySelector(selector);
};

export const getElems = (selector) => {
  return document.querySelectorAll(selector);
};

export const fillElem = (element, node) => {
  element.innerHTML = node;
};

export const validateForm = () => {
  let valid = true;
  let required = getElems('.requiredField');
  let submitBtn = getElem('#submitBtn');

  required.forEach((field) => {
    if (field.value == '') {
      valid = false;
      return;
    }
  });

  if (valid) {
    enableForm(submitBtn);
  } else {
    disableForm(submitBtn);
  }
};

export const disableForm = (btn) => {
  btn.setAttribute('disabled', 'disabled');
  setStyle(invalidFormButtonStyles, submitBtn);
};

export const enableForm = (btn) => {
  btn.removeAttribute('disabled');
  setStyle(validFormButtonStyles, submitBtn);
};
