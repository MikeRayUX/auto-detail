import React, { useState, useEffect } from 'react';
import ReactDOM from 'react-dom';
import FlashModal from './FlashModal';

const rails_flash = document.querySelector('#flash').value;

// if rails falsh is not blank, show a the flash modal
const FlashRenderer = () => {
  const [flash, setFlash] = useState(rails_flash);
  return (
    <div>
      <FlashModal flash_message={flash} onClose={() => setFlash('')} />
    </div>
  );
};

const App = document.createElement('div');
App.setAttribute('id', 'App');

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(<FlashRenderer />, document.body.appendChild(App));
});
