<?php
/**
 * Copyright © Magento, Inc. All rights reserved.
 * See COPYING.txt for license details.
 */

// Packages that need to be added to admin instance because of modularity issues, need to remove in the future
$additionalPackages = [
    'admin-ui' => [
        'magento/module-catalog-rule-configurable-admin-ui' => '*',
        'magento/module-payment-ui' => '*',
        'magento/module-backend-ui' => '*',
        'magento/module-paypal-ui' => '*',
        'magento/module-catalog-ui' => '*',
        'magento/module-widget-ui' => '*',
        'magento/module-braintree-ui' => '*',
        'magento/module-message-queue' => '*',
        'magento/module-checkout-ui' => '*',
        'magento/module-webapi-async' => '*',
        'magento/module-webapi-async-ui' => '*',
        'magento/module-webapi-async-webapi' => '*',
        'magento/module-webapi-admin-ui' => '*',
        'magento/module-webapi' => '*',
        'magento/module-webapi-ui' => '*',
        'magento/module-asynchronous-operations-admin-ui' => '*',
        'magento/module-eav-webapi' => '*',
        'magento/module-catalog-url-rewrite-webapi' => '*',
        'magento/module-sales-webapi' => '*',
        'magento/module-persistent-webapi' => '*',
        'magento/module-quote-webapi' => '*',
        'magento/module-msrp-webapi' => '*',
        'magento/module-checkout-agreements-webapi' => '*',
        'magento/module-integration-webapi' => '*',
        'magento/module-catalog-search-webapi' => '*',
        'magento/module-catalog-webapi' => '*',
        'magento/module-tax-webapi' => '*',
        'magento/module-bundle-webapi' => '*',
        'magento/module-user-webapi' => '*',
        'magento/module-backend-webapi' => '*',
        'magento/module-downloadable-webapi' => '*',
        'magento/module-directory-webapi' => '*',
        'magento/module-checkout-webapi' => '*',
        'magento/module-search-webapi' => '*',
        'magento/module-cms-webapi' => '*',
        'magento/module-catalog-inventory-webapi' => '*',
        'magento/module-gift-message-webapi' => '*',
        'magento/module-asynchronous-operations-webapi' => '*',
        'magento/module-catalog-rule-webapi' => '*',
        'magento/module-configurable-product-webapi' => '*',
        'magento/module-customer-webapi' => '*',
        'magento/module-analytics-webapi' => '*',
        'magento/module-reports-webapi' => '*',
        'magento/module-store-webapi' => '*',
        'magento/module-sales-rule-webapi' => '*',
        'magento/framework-message-queue' => '*',
        'magento/module-admin-notification-ui' => '*',
        'magento/module-theme-ui' => '*',
        'magento/module-require-js' => '*',
        'magento/module-require-js-ui' => '*',
        'magento/module-translation-ui' => '*',
        'magento/module-captcha-ui' => '*',
        'magento/module-release-notification-ui' => '*',
        'magento/module-analytics-ui' => '*',
        'magento/module-asynchronous-operations-ui' => '*',
    ],
    'ui' => [
        'magento/module-webapi-async' => '*',
        'magento/module-webapi-async-ui' => '*',
        'magento/module-webapi-async-webapi' => '*',
        'magento/module-webapi-admin-ui' => '*',
        'magento/module-webapi' => '*',
        'magento/module-webapi-ui' => '*',
        'magento/module-eav-webapi' => '*',
        'magento/module-catalog-url-rewrite-webapi' => '*',
        'magento/module-sales-webapi' => '*',
        'magento/module-persistent-webapi' => '*',
        'magento/module-quote-webapi' => '*',
        'magento/module-msrp-webapi' => '*',
        'magento/module-checkout-agreements-webapi' => '*',
        'magento/module-integration-webapi' => '*',
        'magento/module-catalog-search-webapi' => '*',
        'magento/module-catalog-webapi' => '*',
        'magento/module-tax-webapi' => '*',
        'magento/module-bundle-webapi' => '*',
        'magento/module-user-webapi' => '*',
        'magento/module-backend-webapi' => '*',
        'magento/module-downloadable-webapi' => '*',
        'magento/module-directory-webapi' => '*',
        'magento/module-checkout-webapi' => '*',
        'magento/module-search-webapi' => '*',
        'magento/module-cms-webapi' => '*',
        'magento/module-catalog-inventory-webapi' => '*',
        'magento/module-gift-message-webapi' => '*',
        'magento/module-asynchronous-operations-webapi' => '*',
        'magento/module-catalog-rule-webapi' => '*',
        'magento/module-configurable-product-webapi' => '*',
        'magento/module-customer-webapi' => '*',
        'magento/module-analytics-webapi' => '*',
        'magento/module-reports-webapi' => '*',
        'magento/module-store-webapi' => '*',
        'magento/module-sales-rule-webapi' => '*',
    ],
    'webapi' => [],
];

// TODO: Path must be parameterized
$pathTypeConfig = [
    "minimum-stability" => "dev",
    'repositories' => [
        [
            "type" => "path",
            "url" => "./magento/app/code/Magento/*/*"
        ],
        [
            "type" => "path",
            "url" => "./magento/app/code/Magento/*"
        ],
        [
            "type" => "path",
            "url" => "./magento/lib/internal/Magento/Framework/*/*"
        ],
        [
            "type" => "path",
            "url" => "./magento/lib/internal/Magento/Framework/*"
        ],
        [
            "type" => "path",
            "url" => "./magento/lib/internal/Magento/*"
        ]
    ]
];

$allowedInstances = ['admin-ui', 'ui', 'webapi'];

$composerJsonPath = $argv[1];

$instance = $argv[2];

if (!in_array($instance, $allowedInstances)) {
    echo 'Second argument must be one of the following ' . implode(', ', $allowedInstances);
    exit;
}

if (!file_exists($composerJsonPath) || !is_file($composerJsonPath)) {
    echo 'Can\'t read composer.json file';
    exit;
}

$rootComposerJsonContent = file_get_contents($composerJsonPath);
$rootComposerJsonData = json_decode($rootComposerJsonContent, true);

$addToRequire = [];
foreach ($rootComposerJsonData['replace'] as $moduleName => $version) {
    if (preg_match('/-' . $instance . '$/', $moduleName)) {
        $addToRequire[$moduleName] = '*';
        unset($rootComposerJsonData['replace'][$moduleName]);
        unset($rootComposerJsonData['replace'][str_replace('-' . $instance, '', $moduleName)]);
    }
    if (strpos($moduleName, 'magento/') === 0
        && strpos($moduleName, 'magento/theme') === false
        && strpos($moduleName, 'magento/language') === false
    ) {
        unset($rootComposerJsonData['replace'][$moduleName]);
    }
}

$rootComposerJsonData['require'] = array_merge($rootComposerJsonData['require'], $addToRequire, $additionalPackages[$instance]);
$rootComposerJsonData = array_merge($rootComposerJsonData, $pathTypeConfig);

file_put_contents($composerJsonPath, json_encode($rootComposerJsonData, JSON_PRETTY_PRINT));
