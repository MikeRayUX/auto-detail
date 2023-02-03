const loaderBackdrop = document.createElement('div');
const loaderContainer = document.createElement('div');
const noticeText = document.createElement('p');
noticeText.textContent = 'Please Wait';
const loader = document.createElement('div');

loaderContainer.appendChild(noticeText);
loaderContainer.appendChild(loader);

loaderBackdrop.style.cssText = `
      height: 100%;
      width: 100%;
      background: #D70CF5;
      position: absolute;
      z-index: 100;
      opacity: .95;
      color: white;
      visibility: hidden;
    `;
loaderContainer.style.cssText = `
      width: 125px;
      height: 125px;
      border-radius: 10px;
      z-index: 200;
      /* background: white; */
      position: absolute;
      margin-top: auto;
      margin-right: auto;
      margin-bottom: auto;
      margin-left: auto;
      top: 0;
      right: 0;
      bottom: 0;
      left: 0;
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      align-content: center;
      visibility: hidden;
    `;
noticeText.style.cssText = `
      padding-bottom: 10px;
      font-size: 16px;
      color:#D70CF5;
      color:white;
      visibility: hidden;
    `;
loader.style.cssText = `
      border: 8px solid white;
      border-radius: 50%;
      border-top: 8px solid #D70CF5;
      width: 50px;
      height: 50px;
      -webkit-animation: spin 2s linear infinite; /* Safari */
      animation: spin 2s linear infinite;
      visibility: hidden;
    `;
document.body.insertBefore(loaderContainer, document.body.firstChild);
document.body.insertBefore(loaderBackdrop, document.body.firstChild);

export const showLoader = () => {
  loaderContainer.style.visibility = 'visible';
  loaderBackdrop.style.visibility = 'visible';
  noticeText.style.visibility = 'visible';
  loader.style.visibility = 'visible';
};

export const hideLoader = () => {
  loaderContainer.style.visibility = 'hidden';
  loaderBackdrop.style.visibility = 'hidden';
  noticeText.style.visibility = 'hidden';
  loader.style.visibility = 'hidden';
};
