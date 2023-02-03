import React, { useState, useRef, useEffect } from 'react';
import ReactDOM from 'react-dom';
import {
  withScriptjs,
  withGoogleMap,
  GoogleMap,
  Marker,
} from 'react-google-maps';
import HomeIcon from '../../../../../assets/images/home_icon.png';
import CarIcon from '../../../../../assets/images/car_icon.png';
import InactiveWasherIcon from '../../../../../assets/images/washer-inactive.png';
import { calcRegion, googleMapURL } from '../../../../../location/location';

const region = document.querySelector('input[name="region"]').value;
const coverage_areas = document.querySelector(
  'input[name="coverage_areas"]'
).value;
const customers = document.querySelectorAll('input[name="customer-lat-lng"]');
const washers = document.querySelectorAll('input[name="washer-lat-lng"]');
const inactive_washers = document.querySelectorAll(
  'input[name="washer-inactive-lat-lng"]'
);
const business_open = document.querySelector(
  'input[name="business_open"]'
).value;
const business_close = document.querySelector(
  'input[name="business_close"]'
).value;

// region attributes
const region_id = document.querySelector('input[name="region_id"]').value;
const price_per_bag = document.querySelector(
  'input[name="price_per_bag"]'
).value;
const max_concurrent_offers = document.querySelector(
  'input[name="max_concurrent_offers"]'
).value;
const failed_pickup_fee = document.querySelector(
  'input[name="failed_pickup_fee"]'
).value;
const stripe_tax_rate_id = document.querySelector(
  'input[name="stripe_tax_rate_id"]'
).value;
const tax_rate = document.querySelector('input[name="tax_rate"]').value;
const washer_count = document.querySelector('input[name="washer_count"]').value;
const customers_count = document.querySelector(
  'input[name="customers_count"]'
).value;
const washer_pay_percentage = document.querySelector(
  'input[name="washer_pay_percentage"]'
).value;
const washer_ppb = document.querySelector('input[name="washer_ppb"]').value;

const Map = () => {
  const [customer_markers, setCustomerMarkers] = useState([]);
  const [washer_markers, setWasherMarkers] = useState([]);
  const [inactive_washer_markers, setInactiveWasherMarkers] = useState([]);

  const [customers_not_mappable, setCustomersNotMappable] = useState(0);
  const [washers_not_mappable, setWashersNotMappable] = useState(0);

  useEffect(() => {
    setMarkers(
      customers,
      customer_markers,
      setCustomerMarkers,
      customers_not_mappable,
      setCustomersNotMappable
    );
    setMarkers(
      washers,
      washer_markers,
      setWasherMarkers,
      washers_not_mappable,
      setWashersNotMappable
    );

    setMarkers(
      inactive_washers,
      inactive_washer_markers,
      setInactiveWasherMarkers,
      washers_not_mappable,
      setWashersNotMappable
    );
  }, []);

  useEffect(() => {
    console.log(inactive_washer_markers);
  }, [inactive_washer_markers]);

  const setMarkers = (
    elements,
    markers_array,
    setMarkers,
    not_mappable,
    setNotMappable
  ) => {
    let markers = [...markers_array];
    let notMappableCount = not_mappable;
    if (elements.length) {
      elements.forEach((elem) => {
        if (elem.value.length) {
          markers.push({
            latitude: parseFloat(elem.value.split('/')[0]),
            longitude: parseFloat(elem.value.split('/')[1]),
          });
        } else {
          notMappableCount++;
        }
      });
      setNotMappable(notMappableCount);
      setMarkers(markers);
    }
  };

  return (
    <div className="w-full h-full mb-8">
      <div className="flex flex-row justify-between items-center bg-gray-800 border-b border-gray-600 shadow">
        <h3 className="px-2 text-xs py-1 font-bold text-white">{region}</h3>
        <h3 className="px-4 text-xs py-1 font-bold text-white">
          STRIPE_TAX_ID:
          <a
            href={`https://dashboard.stripe.com/tax-rates/${stripe_tax_rate_id}`}
            className="pl-2 text-xs font-bold text-white underline"
          >
            {stripe_tax_rate_id}
          </a>
        </h3>
      </div>
      <div
        style={{ height: '100%' }}
        className="relative w-full shadow bg-white"
      >
        <div className="w-full h-full relative">
          <div
            style={{ height: '100%' }}
            className="w-full mb-2 shadow-inner relative"
          >
            <ReactGoogleMap
              googleMapURL={googleMapURL}
              loadingElement={<div style={{ height: '100%' }} />}
              containerElement={<div style={{ height: '100%' }} />}
              mapElement={<div style={{ height: '100%' }} />}
              customer_markers={customer_markers}
              washer_markers={washer_markers}
              inactive_washer_markers={inactive_washer_markers}
            />
          </div>

          <RegionDetails />
        </div>
      </div>
    </div>
  );
};

const ReactGoogleMap = withScriptjs(
  withGoogleMap(
    ({ customer_markers, washer_markers, inactive_washer_markers }) => {
      const mapRef = useRef(null);

      const [current_region, setCurrentRegion] = useState({
        lat: -34.397,
        lng: 150.644,
      });

      const [zoom, setZoom] = useState(0);

      useEffect(() => {
        const bounds = new window.google.maps.LatLngBounds();
        customer_markers.forEach((marker) => {
          bounds.extend({ lat: marker.latitude, lng: marker.longitude });
        });

        washer_markers.forEach((marker) => {
          bounds.extend({ lat: marker.latitude, lng: marker.longitude });
        });

        inactive_washer_markers.forEach((marker) => {
          bounds.extend({ lat: marker.latitude, lng: marker.longitude });
        });
        mapRef.current.fitBounds(bounds, 80);
      }, [current_region]);

      return (
        <div className="relative w-full h-full">
          <GoogleMap
            ref={mapRef}
            defaultZoom={zoom}
            defaultCenter={current_region}
            zoom={zoom}
            center={current_region}
            defaultOptions={{
              fullscreenControl: false,
              backgroundColor: '#000',
              // hides controls with zoom button pegman etc
              disableDefaultUI: true,
            }}
            onZoomChanged={() => {
              // if (customer_markers.length == 1) {
              //   setZoom(10);
              // }
            }}
          >
            {customer_markers.length
              ? customer_markers.map((marker) => {
                  return (
                    <Marker
                      key={marker.latitude}
                      icon={HomeIcon}
                      position={{
                        lat: marker.latitude,
                        lng: marker.longitude,
                      }}
                    />
                  );
                })
              : null}

            {washer_markers.length
              ? washer_markers.map((marker) => {
                  return (
                    <Marker
                      key={marker.latitude}
                      icon={CarIcon}
                      position={{
                        lat: marker.latitude,
                        lng: marker.longitude,
                      }}
                    />
                  );
                })
              : null}

            {inactive_washer_markers.length
              ? inactive_washer_markers.map((marker) => {
                  return (
                    <Marker
                      key={marker.latitude}
                      icon={InactiveWasherIcon}
                      position={{
                        lat: marker.latitude,
                        lng: marker.longitude,
                      }}
                    />
                  );
                })
              : null}
          </GoogleMap>
        </div>
      );
    }
  )
);

const RegionDetails = () => {
  return (
    <div className="p-2 shadow border-t border-r border-b border-gray-600 bg-gray-300 absolute bottom-0 left-0 z-10">
      <div className="flex flex-row justify-between items-center">
        <h3 className="text-xs font-bold text-gray-900 leading-none px-2">
          BUSINESS HOURS
        </h3>

        <h3 className="text-xs font-bold text-gray-900 leading-none px-2">
          {`${business_open}-${business_close}`}
        </h3>
      </div>

      <div className="flex flex-row justify-between items-center">
        <h3 className="text-xs font-bold text-gray-900 leading-none px-2">
          COVERAGE AREAS
        </h3>

        <h3 className="text-xs font-bold text-gray-900 leading-none px-2">
          {coverage_areas}
        </h3>
      </div>

      <div className="flex flex-row justify-between items-center">
        <h3 className="text-xs font-bold text-gray-900 leading-none px-2">
          CUSTOMERS
        </h3>

        <h3 className="text-xs font-bold text-gray-900 leading-none px-2">
          {customers_count}
        </h3>
      </div>

      <div className="flex flex-row justify-between items-center">
        <h3 className="text-xs font-bold text-gray-900 leading-none px-2">
          WASHERS
        </h3>

        <h3 className="text-xs font-bold text-gray-900 leading-none px-2">
          {washer_count}
        </h3>
      </div>

      <div className="flex flex-row justify-between items-center">
        <h3 className="text-xs font-bold text-gray-900 leading-none px-2">
          BAG PRICE
        </h3>

        <h3 className="text-xs font-bold text-gray-900 leading-none px-2">
          {price_per_bag}
        </h3>
      </div>

      <div className="flex flex-row justify-between items-center">
        <h3 className="text-xs font-bold text-gray-900 leading-none px-2">
          TAX RATE
        </h3>

        <h3 className="text-xs font-bold text-gray-900 leading-none px-2">
          {tax_rate}%
        </h3>
      </div>

      <div className="flex flex-row justify-between items-center">
        <h3 className="text-xs font-bold text-gray-900 leading-none px-2">
          WASHER P.P
        </h3>

        <h3 className="text-xs font-bold text-gray-900 leading-none px-2">
          {washer_pay_percentage}%
        </h3>
      </div>

      <div className="flex flex-row justify-between items-center">
        <h3 className="text-xs font-bold text-gray-900 leading-none px-2">
          WASHER P.P.B
        </h3>

        <h3 className="text-xs font-bold text-gray-900 leading-none px-2">
          ${washer_ppb}
        </h3>
      </div>

      <div className="flex flex-row justify-between items-center">
        <h3 className="text-xs font-bold text-gray-900 leading-none px-2">
          MAX CONC. OFFERS
        </h3>

        <h3 className="text-xs font-bold text-gray-900 leading-none px-2">
          {max_concurrent_offers}
        </h3>
      </div>

      <div className="flex flex-row justify-between items-center">
        <h3 className="text-xs font-bold text-gray-900 leading-none px-2">
          FAILED PICKUP FEE
        </h3>

        <h3 className="text-xs font-bold text-gray-900 leading-none px-2">
          {failed_pickup_fee}
        </h3>
      </div>
    </div>
  );
};

const App = document.createElement('div');
App.setAttribute('id', 'App');
App.setAttribute('class', 'h-full');

const mapContainer = document.querySelector('#map');
document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(<Map />, mapContainer.appendChild(App));
});
