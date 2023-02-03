import axios from 'axios';
import { getInputValue } from '../../../utilities/getValue';

// WHEN USING PC BROWSER
const base_url = getInputValue('base_url');

// WHEN USING MOBILE BROWSER (IPV4)
// const base_url = 'http://192.168.0.12:3001';

export default axios.create({
  baseURL: base_url,
  withCredentials: true,
});

// EXAMPLES
// const doSomething = async () => {
//   try {
//     const response = await api.post(
//       'api/v1/users/dashboards/new_order_flow/on_demand/pickup_estimations',
//       {},
//       {
//         headers: {
//           'X-CSRF-Token': csrf_token(),
//         },
//       }
//     );

//     console.log(response.data);
//   } catch (err) {
//     console.log(err.message);
//   }
// };

// const doSomething = async () => {
//   try {
//     const response = await api.post(
//       'api/v1/users/dashboards/new_order_flow/on_demand/pickup_estimations',
//       {},
//       {
//         headers: {
//           'X-CSRF-Token': form_authenticity_token(),
//         },
//       }
//     );

//     console.log(response.data);
//   } catch (err) {
//     console.log(err.message);
//   }
// };
