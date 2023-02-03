// window.addEventListener('load', () => {
//   const video = document.createElement("video");
//   const canvasElement = document.querySelector(".scan-viewer");
//   const canvas = canvasElement.getContext("2d");
//   const codeField = document.querySelector('#codeField');
//   const resetBagsListButton = document.querySelector('.reset-bags-list-button');
//   let tracks;

//   function drawLine(begin, end, color) {
//     canvas.beginPath();
//     canvas.moveTo(begin.x, begin.y);
//     canvas.lineTo(end.x, end.y);
//     canvas.lineWidth = 4;
//     canvas.strokeStyle = color;
//     canvas.stroke();
//   }

//   function startStream() {
//     // Use facingMode: environment to attemt to get the front camera on phones
//     navigator.mediaDevices.getUserMedia({ video: { facingMode: "environment" } }).then(function (stream) {
//       tracks = stream.getTracks();
//       video.srcObject = stream;
//       video.setAttribute("playsinline", true); // required to tell iOS safari we don't want fullscreen
//       video.play();
//       requestAnimationFrame(tick);
//     });

//     function tick() {
//       if (video.readyState === video.HAVE_ENOUGH_DATA) {
//         canvasElement.hidden = false;
//         canvasElement.height = video.videoHeight;
//         canvasElement.width = video.videoWidth;
//         canvas.drawImage(video, 0, 0, canvasElement.width, canvasElement.height);
//         var imageData = canvas.getImageData(0, 0, canvasElement.width, canvasElement.height);
//         var code = jsQR(imageData.data, imageData.width, imageData.height, {
//           inversionAttempts: "dontInvert",
//         });
//         if (code) {
//           drawLine(code.location.topLeftCorner, code.location.topRightCorner, "#E9FD49");
//           drawLine(code.location.topRightCorner, code.location.bottomRightCorner, "#E9FD49");
//           drawLine(code.location.bottomRightCorner, code.location.bottomLeftCorner, "#E9FD49");
//           drawLine(code.location.bottomLeftCorner, code.location.topLeftCorner, "#E9FD49");
//           filterCodeArray(code.data);
//         } else {
//         }
//       }
//       requestAnimationFrame(tick);
//     }
//   }

//   function filterCodeArray(code) {
//     pauseStream(milliseconds = 1500);
//     codeField.value = code;
//   }

//   function pauseStream(milliseconds) {
//     tracks.forEach(function (track) {
//       track.stop();
//     });
//     video.srcObject = null;
//     setTimeout(() => {
//       startStream();
//     }, milliseconds);
//   }

//   resetBagsListButton.addEventListener('click', () => {
//     resetBagsList();
//   })

//   function resetBagsList() {
//     codeField.value = '';
//   }

//   startStream();
// })
