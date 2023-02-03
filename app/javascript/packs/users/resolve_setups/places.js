window.addEventListener('load', () => {
  function initAutocomplete() {
    autocomplete = new google.maps.places.Autocomplete(
      (document.querySelector('#autocomplete')),
      { types: ['geocode'] }
    );

    autocomplete.addListener('place_changed', () => {
      handleAddress(autocomplete.getPlace());
    })
  }
  function handleAddress(response) {
    let splitAddress = response.formatted_address.split(', ');

    if (addressContainsZipcode(splitAddress)) {
      let address = {
        street_address: splitAddress[0],
        city: splitAddress[1],
        state: splitAddress[2].split(' ')[0],
        zipcode: splitAddress[2].split(' ')[1]
      }

      fillInFormFields(address);
    }
  }

  const addressContainsZipcode = (address) => {
    return address.length >= 4;
  }

  function fillInFormFields(address) {
    document.querySelector('#address_street_address').value = address.street_address
    document.querySelector('#address_city').value = address.city
    document.querySelector('#address_state').value = address.state
    document.querySelector('#address_zipcode').value = address.zipcode
  }

  initAutocomplete();
})