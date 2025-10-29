<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Cross-Origin Resource Sharing (CORS) Configuration
    |--------------------------------------------------------------------------
    */

    'paths' => ['api/*', 'sanctum/csrf-cookie', '*'],

    'allowed_methods' => ['*'],

    'allowed_origins' => [
        // ✅ Your live frontends
        'https://multivendor-shop-two.vercel.app',
        'https://multivendor-rest.vercel.app',
        // ✅ Local development
        'http://localhost:3000',
        'http://localhost:3002',
        'http://localhost:3003',
    ],

    'allowed_origins_patterns' => [],

    'allowed_headers' => ['*'],

    'exposed_headers' => [],

    'max_age' => 0,

    'supports_credentials' => false,
];
    