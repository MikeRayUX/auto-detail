import React, { useState, useEffect, useRef } from 'react';
import {
  withScriptjs,
  withGoogleMap,
  GoogleMap,
  Marker,
} from 'react-google-maps';
import HomeIcon from '../../assets/images/home_icon.png';
import CarIcon from '../../assets/images/car_icon.png';
import { getMapZoomAdjustment } from '../../location/location';

const Map = withScriptjs(
  withGoogleMap(({ customer, washer, current_region }) => {
    const mapRef = useRef(null);

    const defaultMapOptions = {
      fullscreenControl: false,
      backgroundColor: '#000',
      // hides controls with zoom button pegman etc
      disableDefaultUI: true,
    };

    useEffect(() => {
      if (
        current_region &&
        washer &&
        washer.location.lat &&
        washer.location.lng
      ) {
        fitMarkersWithinBounds();
      }
    }, [current_region]);

    const fitMarkersWithinBounds = () => {
      const bounds = new window.google.maps.LatLngBounds();

      bounds.extend(customer.location);
      bounds.extend(washer.location);

      let padding;
      if (windowExpanded()) {
        mapRef.current.fitBounds(bounds);
        padding = 50;
      } else {
        padding = 300;
      }
      mapRef.current.fitBounds(bounds, padding);
    };

    const windowExpanded = () => {
      let maxWidth = window.matchMedia('(max-width: 640px)');
      return maxWidth.matches;
    };

    return (
      <GoogleMap
        ref={mapRef}
        defaultZoom={10}
        defaultCenter={
          current_region
            ? {
                lat: current_region.latitude,
                lng: current_region.longitude,
              }
            : {
                lat: customer.location.lat,
                lng: customer.location.lng,
              }
        }
        center={
          current_region
            ? {
                lat: current_region.latitude,
                lng: current_region.longitude,
              }
            : {
                lat: customer.location.lat,
                lng: customer.location.lng,
              }
        }
        defaultOptions={defaultMapOptions}
      >
        <Marker
          icon={HomeIcon}
          position={{
            lat: customer.location.lat,
            lng: customer.location.lng,
          }}
        />

        {washer && washer.location.lat && washer.location.lng ? (
          <Marker
            icon={CarIcon}
            position={{
              lat: washer.location.lat,
              lng: washer.location.lng,
            }}
          />
        ) : null}
      </GoogleMap>
    );
  })
);

export default Map;
