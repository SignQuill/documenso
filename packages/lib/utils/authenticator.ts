import { NEXT_PUBLIC_WEBAPP_URL, AUTH_RP_NAME } from '../constants/app';
import { PASSKEY_TIMEOUT } from '../constants/auth';

/**
 * Extracts common fields to identify the RP (relying party)
 */
export const getAuthenticatorOptions = () => {
  const webAppBaseUrl = new URL(NEXT_PUBLIC_WEBAPP_URL());
  const rpId = webAppBaseUrl.hostname;

  return {
    rpName: AUTH_RP_NAME(),
    rpId,
    origin: NEXT_PUBLIC_WEBAPP_URL(),
    timeout: PASSKEY_TIMEOUT,
  };
};
