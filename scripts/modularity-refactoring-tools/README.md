# Tools for module decomposition

## Extract UI modules

Allows to extract admin, storefront and WebAPI modules. Example usage

`php extract-ui-modules.php magento/app/code/Magento`

## Prepare composer.json for storefront specific instance

Allows to remove packages that are not need on UI instance from `composer.json` (on admin instance we don't need storefront and WebAPI modules). Example usage

`php prepare-composer-json.php magento/composer.json admin`

## Prepare admin instance

Should be able to install packages, Magento and login to admin.

1. Clone https://github.com/magento-architects/magento2/tree/distributed-deployment magento
2. `cp -r magento magento/` - this is needed to use composer path type repo
3. `php extract-ui-modules.php magento/magento/app/code/Magento`
4. `rm -rf magento/app/code/Magento/*`
5. `rm -rf magento/lib/internal/Magento/*`
6. `php prepare-composer-json.php magento/composer.json admin`
7. `cd magento`
8. `composer update`
