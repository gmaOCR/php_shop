<?php

/**
 * Router script for PHP built-in web server.
 * Serves static files directly and routes other requests to index.php
 */

// Decode the URL
$requestUri = urldecode(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH));

// Build the full path to the requested file in the public directory
$filePath = __DIR__ . '/public' . $requestUri;

// If it's a file in the public directory, serve it directly
if (is_file($filePath)) {
    // Let PHP's built-in server handle the file
    return false;
}

// Otherwise, route through Symfony's front controller
require __DIR__ . '/public/index.php';
