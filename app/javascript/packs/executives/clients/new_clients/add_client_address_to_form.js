const addAddressButton = document.querySelector('#addAddressButton');
const formContainer = document.querySelector('.formContainer');
const autoCompleteField = document.querySelector('#autocomplete');
const phoneNumberField = document.querySelector('#addressPhone');
const unitNumberField = document.querySelector('#unitNumber');
const pickUpDirectionsField = document.querySelector('#pickUpDirections');
const newClientForm = document.querySelector('#new_new_client');

const addressCountField = document.querySelector('#addressCountField');
const addressDisplayCount = document.querySelector('.addressDisplayCount');
const addressListContainer = document.querySelector('#addressListContainer');
let addresses = [];
let currentAddress = {
  id: '',
  street_address: '',
  city: '',
  state: '',
  zipcode: '',
  unit_number: '',
  pick_up_directions: '',
  phone: '',
};

// places autocomplete start
function initAutocomplete() {
  autocomplete = new google.maps.places.Autocomplete(
    document.querySelector('#autocomplete'),
    { types: ['geocode'] }
  );

  autocomplete.addListener('place_changed', () => {
    handleAddress(autocomplete.getPlace());
  });
}
function handleAddress(response) {
  if (addressContainsZipcode(response)) {
    let addressArray = response.formatted_address.split(', ');
    let address = {
      street_address: addressArray[0],
      city: addressArray[1],
      state: addressArray[2].split(' ')[0],
      zipcode: addressArray[2].split(' ')[1],
    };
    verifyAddress(address);
  } else {
    clearForm();
    showFlash('Invalid Address');
    disableAddressForm();
  }
}

const addressContainsZipcode = (response) => {
  return response.formatted_address.split(', ').length >= 4;
};

const storeExtraAddressData = (unitNumber, pickUpDirections) => {
  currentAddress.unit_number = unitNumber;
  currentAddress.pickUpDirections = pickUpDirections;
};
// autocomplete end

const verifyAddress = (address) => {
  clearFlashMessages();
  fetch(`/api/v1/verify_zipcodes/?zipcode=${address.zipcode}`, {
    method: 'GET',
    credentials: 'same-origin',
  })
    .then((response) => response.json())
    .then((json) => {
      // console.log(json.data.message);
      switch (json.data.message) {
        case 'available':
          storeAddress(address);
          enableAddressForm();
          break;
        case 'not_available':
          showFlash('Address Not Available.');
          disableAddressForm();
          break;
        default:
          break;
      }
    });
};

addAddressButton.addEventListener('click', () => {
  storeExtraFields();
  addAddressToList();
});

const storeAddress = (address) => {
  currentAddress = {
    id: generateId(),
    street_address: address.street_address,
    city: address.city,
    state: address.state,
    zipcode: address.zipcode,
  };

  // console.log(currentAddress);
};

const storeExtraFields = () => {
  let pickUpDirections = document.querySelector('#pickUpDirections').value;
  let unitNumber = document.querySelector('#unitNumber').value;
  let phone = phoneNumberField.value;
  currentAddress.pick_up_directions = pickUpDirections;
  currentAddress.unit_number = unitNumber;
  currentAddress.phone = phone;
};

const addAddressToList = () => {
  currentAddress.html = `<div class="addressesDisplayItem  w-full flex flex-row justify-between items-center mb-2 py-2 px-2 rounded-md bg-green-600">
  <ion-icon name="navigate-circle" class="text-white mr-1 text-2xl"></ion-icon>
  <h1 class="addressDisplay font-bold text-white mr-4 text-xs">
  ${currentAddress.street_address.toUpperCase()}, 
  ${currentAddress.city.toUpperCase()}, 
  ${currentAddress.state.toUpperCase()}, 
  ${currentAddress.zipcode.toUpperCase()},
  ${currentAddress.unit_number.toUpperCase()}
  ${currentAddress.pick_up_directions.toUpperCase()}
  </h1>
  <a href="#" class="deleteAddressButton py-1 px-1 rounded bg-white text-gray-800 text-xs font-bold flex flex-row justify-center items-center" target-id="${
    currentAddress.id
  }">
    Delete
  </a></div>`;

  addresses.push(currentAddress);
  addAddressFormFields();
  refreshAddressDisplayList();
};

const addAddressFormFields = () => {
  addresses.forEach((address) => {
    let index = addresses.indexOf(address);
    // console.log(address);
    appendFieldToForm('street_address', address.street_address, index);
    appendFieldToForm('city', address.city, index);
    appendFieldToForm('state', address.state, index);
    appendFieldToForm('zipcode', address.zipcode, index);
    appendFieldToForm('unit_number', address.unit_number, index);
    appendFieldToForm('pick_up_directions', address.pick_up_directions, index);
    appendFieldToForm('phone', address.phone, index);
  });
};

const appendFieldToForm = (key, value, index) => {
  let field = document.createElement('input');
  field.setAttribute('type', 'hidden');
  field.setAttribute('name', `new_client[address_${key}_${index}]`);
  field.setAttribute('id', `new_client_address_${key}_${index}`);
  field.value = value;
  newClientForm.appendChild(field);
};

const refreshAddressDisplayList = () => {
  clearAddressDisplayList();
  clearForm();

  addresses.forEach((address) => {
    addressListContainer.innerHTML += address.html;
  });
  addressDisplayCount.innerText = `Addresses (${addresses.length})`;
  addressCountField.value = addresses.length;

  refreshDeleteListeners();
};

const refreshDeleteListeners = () => {
  document.querySelectorAll('.deleteAddressButton').forEach((deleteButton) => {
    deleteButton.addEventListener('click', (event) => {
      let id = event.target.getAttribute('target-id');
      // console.log(id);
      deleteAddress(id);
    });
  });
};

const clearAddressDisplayList = () => {
  addressListContainer.innerHTML = '';
};

const deleteAddress = (id) => {
  // console.log(`deleting id:${id}`);
  addresses = addresses.filter((item) => {
    return item.id != id;
  });

  refreshAddressDisplayList();

  // console.log(addresses);
};

const clearCurrentAddress = () => {
  currentAddress = {
    id: '',
    street_address: '',
    city: '',
    state: '',
    zipcode: '',
    unit_number: '',
    pick_up_directions: '',
    phone: '',
  };
};

const disableAddressForm = () => {
  // console.log('disableling');
  addAddressButton.disabled = true;
  clearElementStyles(addAddressButton);
  [
    'px-2',
    'block',
    'bg-gray-200',
    'py-2',
    'rounded',
    'text-gray-600',
    'flex',
    'flex-row',
    'justify-center',
    'items-center',
    'text-sm',
    'border',
  ].forEach((style) => {
    addAddressButton.classList.add(style);
    addAddressButton.innerHTML = `
      <ion-icon name="checkmark" class=" text-white-500 mr-1"></ion-icon>
      Add
    `;
  });
};

const enableAddressForm = () => {
  addAddressButton.disabled = false;
  clearElementStyles(addAddressButton);
  [
    'px-2',
    'block',
    'bg-green-600',
    'py-2',
    'rounded',
    'text-white',
    'flex',
    'flex-row',
    'justify-center',
    'items-center',
    'text-sm',
    'border',
  ].forEach((style) => {
    addAddressButton.classList.add(style);
    addAddressButton.innerHTML = `
      <ion-icon name="checkmark-circle" class=" text-white-500 mr-1"></ion-icon>
      Add
    `;
  });
};

const clearElementStyles = (element) => {
  element.removeAttribute('class');
};

autoCompleteField.addEventListener('input', () => {
  if (autoCompleteField.value == '') {
    clearForm();
    clearCurrentAddress();
  }
});

const clearForm = () => {
  disableAddressForm();
  autoCompleteField.value = '';
  unitNumberField.value = '';
  pickUpDirectionsField.value = '';
};

const showFlash = (message) => {
  errorContainer.innerHTML = `<div class="flash w-full py-4 mb-4 px-4 rounded bg-gray-300">
  <h1 class="text-base font-bold text-center text-gray-900">
    ${message}
  </h1>
</div>`;
};

const clearFlashMessages = () => {
  document.querySelector('#errorContainer').innerHTML = '';
};

const generateId = () => {
  return (
    Math.random().toString(16).substring(2, 6) +
    Math.random().toString(16).substring(2, 6)
  );
};

initAutocomplete();
disableAddressForm();
