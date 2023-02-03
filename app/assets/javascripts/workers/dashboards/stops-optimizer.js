// window.addEventListener('load', () => {
//   const MAPBOX_PUBLIC_TOKEN = document.querySelector('meta[name=mapbox-public-token]').content
//   const stopsList = document.querySelector('meta[name=stops-list]').content
//   const jobsContainer = document.querySelector('.worker-offers__container-inner');
//   const url = `https://api.mapbox.com/optimized-trips/v1/mapbox/driving/${stopsList}?access_token=${MAPBOX_PUBLIC_TOKEN}`

//   function getOptimizedWaypoints() {
//     // console.log(url);
//     let waypointIndexOrder = []
//     fetch(url, {
//       method: 'GET'
//     }).then(response => response.json()).then(data => {
//       // console.log(data)
//       data.waypoints.forEach(item => {
//         waypointIndexOrder.push(item.waypoint_index);
//       })
//       sortJobs(waypointIndexOrder);
//     });
//   }

//   function sortJobs(index) {
//     const jobs = Array.from(document.querySelectorAll('.worker-offers__item'));

//     for (var i = 0; i < jobs.length; i++) {
//       jobs[i].setAttribute('order', index[i + 1]);
//     }
//     jobs.sort((a, b) => {
//       a = a.getAttribute('order')
//       b = b.getAttribute('order')
//       return a - b
//     });

//     jobs.forEach(job => {
//       jobsContainer.appendChild(job);
//     })

//   }

//   // getOptimizedWaypoints();

// })

// // https://api.mapbox.com/optimized-trips/v1/mapbox/driving/-122.201428,48.001818;-122.284689,47.475208;-122.355404,47.509862;-122.386209,47.58176;-122.354481,47.514992?access_token=pk.eyJ1IjoiYXJyaWFnYTU2MiIsImEiOiJjand6bHJkMzYxaG43M3luNWhxdjlzcDVhIn0.dtvrJf3AppUbW60TVMSEMg
