import haversine from 'haversine';
import { getElement } from '../../utilities/getValue';

export const googleMapURL = `https://maps.googleapis.com/maps/api/js?key=${
  getElement('meta[name="google-api-key"]').content
}&v=3.exp&libraries=geometry,drawing,places`;

export const calcRegion = (start, end) => {
  // console.log('start', start);
  // console.log('end', end);
  let minLat = start.lat;
  let maxLat = start.lat;
  let minLng = start.lng;
  let maxLng = start.lng;

  minLat = Math.min(minLat, end.lat);
  maxLat = Math.max(maxLat, end.lat);
  minLng = Math.min(minLng, end.lng);
  maxLng = Math.max(maxLng, end.lng);

  const midLat = (minLat + maxLat) / 2;
  const midLng = (minLng + maxLng) / 2;

  let zoomAdjustment = getMapZoomAdjustment(start, end);

  const deltaLat = maxLat - minLat + zoomAdjustment;
  const deltaLng = maxLng - minLng + zoomAdjustment;

  const region = {
    latitude: midLat,
    longitude: midLng,
    latitudeDelta: deltaLat,
    longitudeDelta: deltaLng,
  };

  return region;
};
export const getMapZoomAdjustment = (start, end) => {
  // REQUIRES {latitude: val, longitude: val} object format for start/end
  return (
    Math.round(
      (haversine(
        {
          latitude: end.lat,
          longitude: end.lng,
        },
        {
          latitude: start.lat,
          longitude: start.lng,
        },
        { unit: 'mile' }
      ) +
        Number.EPSILON) *
        100
    ) /
    100 /
    100
  );
};
