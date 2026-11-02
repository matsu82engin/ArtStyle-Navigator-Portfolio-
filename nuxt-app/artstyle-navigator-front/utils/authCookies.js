import Cookies from 'js-cookie'

const AUTH_COOKIE_KEYS = ['access-token', 'client', 'uid', 'token-type'];

export function clearAuthCookies() {
  const isProd = process.env.NODE_ENV === 'production';
  const options = { secure: isProd, sameSite: isProd ? 'None' : 'Lax' };
  AUTH_COOKIE_KEYS.forEach(key => Cookies.remove(key, options));
}