import { env } from '@documenso/lib/utils/env';

export const APP_DOCUMENT_UPLOAD_SIZE_LIMIT =
  Number(env('NEXT_PUBLIC_DOCUMENT_SIZE_UPLOAD_LIMIT')) || 50;

export const NEXT_PUBLIC_WEBAPP_URL = () =>
  env('NEXT_PUBLIC_WEBAPP_URL') ?? 'http://localhost:3000';

export const NEXT_PRIVATE_INTERNAL_WEBAPP_URL =
  env('NEXT_PRIVATE_INTERNAL_WEBAPP_URL') ?? NEXT_PUBLIC_WEBAPP_URL();

export const IS_BILLING_ENABLED = () => env('NEXT_PUBLIC_FEATURE_BILLING_ENABLED') === 'true';

export const API_V2_BETA_URL = '/api/v2-beta';

export const SUPPORT_EMAIL = 'support@documenso.com';

// Branding constants
export const APP_NAME = () => env('NEXT_PUBLIC_APP_NAME') ?? 'Documenso';
export const APP_SHORT_NAME = () => env('NEXT_PUBLIC_APP_SHORT_NAME') ?? 'Documenso';

// Email branding
export const EMAIL_FROM_NAME = () => env('NEXT_PRIVATE_SMTP_FROM_NAME') ?? APP_NAME();
export const EMAIL_FROM_ADDRESS = () => env('NEXT_PRIVATE_SMTP_FROM_ADDRESS') ?? 'noreply@documenso.com';
export const SERVICE_USER_EMAIL = () => env('NEXT_PRIVATE_SERVICE_USER_EMAIL') ?? 'serviceaccount@documenso.com';

// 2FA and Authenticator branding
export const AUTH_ISSUER = () => env('NEXT_PRIVATE_AUTH_ISSUER') ?? APP_NAME();
export const AUTH_RP_NAME = () => env('NEXT_PRIVATE_AUTH_RP_NAME') ?? APP_NAME();

// Webhook branding
export const WEBHOOK_SECRET_HEADER = () => env('NEXT_PRIVATE_WEBHOOK_SECRET_HEADER') ?? `X-${APP_NAME()}-Secret`;

// Signing certificate branding
export const SIGNING_CERTIFICATE_TEXT = () => env('NEXT_PRIVATE_SIGNING_CERTIFICATE_TEXT') ?? `Signed by ${APP_NAME()}`;

// Analytics domain
export const ANALYTICS_DOMAIN = () => env('NEXT_PRIVATE_ANALYTICS_DOMAIN') ?? 'documenso.com';

// Company branding
export const COMPANY_NAME = () => env('NEXT_PUBLIC_COMPANY_NAME') ?? `${APP_NAME()}, Inc.`;
export const COMPANY_NAME_NO_COMMA = () => env('NEXT_PUBLIC_COMPANY_NAME_NO_COMMA') ?? `${APP_NAME()} Inc.`;
