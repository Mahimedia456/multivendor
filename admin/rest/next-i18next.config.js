/** @type {import('next-i18next').UserConfig} */
const path = require('path');

// Safe fallbacks so build never crashes if envs aren't injected yet
const DEFAULT_LANG =
  process.env.NEXT_PUBLIC_DEFAULT_LANGUAGE && process.env.NEXT_PUBLIC_DEFAULT_LANGUAGE.trim()
    ? process.env.NEXT_PUBLIC_DEFAULT_LANGUAGE.trim()
    : 'en';

const ENABLE_MULTI =
  String(process.env.NEXT_PUBLIC_ENABLE_MULTI_LANG || 'false').toLowerCase() === 'true';

const AVAILABLE = (process.env.NEXT_PUBLIC_AVAILABLE_LANGUAGES || 'en')
  .split(',')
  .map((s) => s.trim())
  .filter(Boolean);

function generateLocales() {
  return ENABLE_MULTI && AVAILABLE.length ? AVAILABLE : [DEFAULT_LANG];
}

module.exports = {
  i18n: {
    defaultLocale: DEFAULT_LANG,
    locales: generateLocales(),
  },
  localePath: path.resolve('./public/locales'),
  reloadOnPrerender: process.env.NODE_ENV === 'development',
};
