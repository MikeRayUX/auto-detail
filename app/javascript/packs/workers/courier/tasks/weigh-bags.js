import { showLoader } from '../../../simple_loader';

const weightFields = document.querySelectorAll('.bag-weight__field');
const totalWeightField = document.querySelector('.weight-total');
const hiddenFormField = document.querySelector('input[name="weight"]');

function calculateWeight() {
  let totalWeight = 0;
  let result = 0;
  weightFields.forEach((item) => {
    let value = item.value;
    if (value) {
      totalWeight += parseFloat(value);
      // console.log(totalWeight);
    }
  });
  totalWeight = (totalWeight * 10) / 10;
  result = totalWeight.toFixed(2);
  totalWeightField.innerText = result;
  hiddenFormField.value = result;
}

weightFields.forEach((item) => {
  item.addEventListener('input', () => {
    calculateWeight();
  });
});

// data confirm window dismiss loader on cancel
let _confirm = window.confirm;

window.confirm = function () {
  let confirmed = _confirm.apply(window, arguments);
  if (confirmed) {
    showLoader();
    document.querySelector('.stop-form').submit();
  } else {
  }
};
