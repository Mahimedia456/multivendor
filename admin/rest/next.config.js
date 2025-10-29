/** @type {import('next').NextConfig} */

const { i18n } = require('./next-i18next.config');

const nextConfig = {
  reactStrictMode: true,
  i18n,
  images: {
    domains: [
      'via.placeholder.com',
      'res.cloudinary.com',
      's3.amazonaws.com',
      '18.141.64.26',
      '127.0.0.1',
      '127.0.0.1:8000',
      'localhost',
      'picsum.photos',
      'pickbazar-sail.test',
      'pickbazarlaravel.s3.ap-southeast-1.amazonaws.com',
      'lh3.googleusercontent.com',
      'chawkbazarlaravel.s3.ap-southeast-1.amazonaws.com',
      // ✅ add your Render API host so Next Image can optimize
      'multivendor-kg7y.onrender.com',
    ],
  },
  ...(process.env.APPLICATION_MODE === 'production' && {
    typescript: { ignoreBuildErrors: true },
    eslint: { ignoreDuringBuilds: true },
  }),
};

module.exports = nextConfig;
