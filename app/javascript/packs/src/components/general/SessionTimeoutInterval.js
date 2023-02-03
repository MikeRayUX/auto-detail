import React, { useState, useEffect } from 'react';
import { minutes, seconds } from '../../../helpers';
import FlashModal from './FlashModal';

const SessionTimeoutInterval = ({
  MINUTES_TO_EXPIRE,
  onInterval,
  onExpire,
}) => {
  const [session_expired_message, setSessionExpiredMessage] = useState('');

  useEffect(() => {
    let refreshCount = 0;

    let interval = setInterval(() => {
      onInterval();
      refreshCount += 1;

      if (refreshCount >= MINUTES_TO_EXPIRE) {
        clearInterval(interval);
        setSessionExpiredMessage('Your Session has Expired.');
      }
    }, minutes(1));

    return () => clearInterval(interval);
  }, []);

  return (
    <>
      <FlashModal flash_message={session_expired_message} onClose={onExpire} />
    </>
  );
};

export default SessionTimeoutInterval;
