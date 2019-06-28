#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && devbox_dir=$PWD

source "${devbox_dir}/scripts/functions.sh"

status "Creating configuration for Magento Tests"
incrementNestingLevel

magento_tests_root="${devbox_dir}/$(getContext)/dev/tests"
magento_host_name="$(bash "${devbox_dir}/scripts/get_config_value.sh" "magento_host_name")"
magento_admin_frontname="$(bash "${devbox_dir}/scripts/get_config_value.sh" "magento_admin_frontname")"
magento_admin_user="$(bash "${devbox_dir}/scripts/get_config_value.sh" "magento_admin_user")"
magento_admin_password="$(bash "${devbox_dir}/scripts/get_config_value.sh" "magento_admin_password")"

# Unit tests
if [[ ! -f "${magento_tests_root}/unit/phpunit.xml" ]] && [[ -f "${magento_tests_root}/unit/phpunit.xml.dist" ]]; then
    status "Creating configuration for Unit tests"
    cp "${magento_tests_root}/unit/phpunit.xml.dist" "${magento_tests_root}/unit/phpunit.xml"
fi

# Integration tests
if [[ ! -f "${magento_tests_root}/integration/phpunit.xml" ]] && [[ -f "${magento_tests_root}/integration/phpunit.xml.dist" ]]; then
    status "Creating configuration for Integration tests"
    cp "${magento_tests_root}/integration/phpunit.xml.dist" "${magento_tests_root}/integration/phpunit.xml"
    sed -i.back "s|<const name=\"TESTS_CLEANUP\" value=\"enabled\"/>|<const name=\"TESTS_CLEANUP\" value=\"disabled\"/>|g" "${magento_tests_root}/integration/phpunit.xml"
    rm -f "${magento_tests_root}/integration/phpunit.xml.back"

    if [[ ! -f "${magento_tests_root}/integration/etc/install-config-mysql.php" ]] && [[ -f "${magento_tests_root}/integration/etc/install-config-mysql.php.dist" ]]; then
        cp "${magento_tests_root}/integration/etc/install-config-mysql.php.dist" "${magento_tests_root}/integration/etc/install-config-mysql.php"
        sed -i.back "s|'db-host' => 'localhost'|'db-host' => 'magento2-mysql'|g" "${magento_tests_root}/integration/etc/install-config-mysql.php"
        sed -i.back "s|'db-name' => 'magento_integration_tests'|'db-name' => 'magento_$(getContext)_integration_tests'|g" "${magento_tests_root}/integration/etc/install-config-mysql.php"
        sed -i.back "s|'amqp-host' => 'localhost'|'amqp-host' => 'magento2-rabbitmq'|g" "${magento_tests_root}/integration/etc/install-config-mysql.php"
        sed -i.back "s|'amqp-user' => 'guest'|'amqp-user' => 'admin'|g" "${magento_tests_root}/integration/etc/install-config-mysql.php"
        sed -i.back "s|'amqp-password' => 'guest'|'amqp-password' => '123123q'|g" "${magento_tests_root}/integration/etc/install-config-mysql.php"
        rm -f "${magento_tests_root}/integration/etc/install-config-mysql.php.back"
    fi
fi

# Web API tests (api-functional)
if [[ ! -f "${magento_tests_root}/api-functional/phpunit_rest.xml" ]] && [[ -f "${magento_tests_root}/api-functional/phpunit_rest.xml.dist" ]]; then
    status "Creating configuration for REST tests"
    cp "${magento_tests_root}/api-functional/phpunit_rest.xml.dist" "${magento_tests_root}/api-functional/phpunit_rest.xml"
    sed -i.back "s|http://magento.url|http://${magento_host_name}|g" "${magento_tests_root}/api-functional/phpunit_rest.xml"
    sed -i.back "s|http://magento-ee.localhost|http://${magento_host_name}|g" "${magento_tests_root}/api-functional/phpunit_rest.xml"
    sed -i.back "s|<const name=\"TESTS_CLEANUP\" value=\"enabled\"/>|<const name=\"TESTS_CLEANUP\" value=\"disabled\"/>|g" "${magento_tests_root}/api-functional/phpunit_rest.xml"
    rm -f "${magento_tests_root}/api-functional/phpunit_rest.xml.back"
fi
if [[ ! -f "${magento_tests_root}/api-functional/phpunit_soap.xml" ]] && [[ -f "${magento_tests_root}/api-functional/phpunit_soap.xml.dist" ]]; then
    status "Creating configuration for SOAP tests"
    cp "${magento_tests_root}/api-functional/phpunit_soap.xml.dist" "${magento_tests_root}/api-functional/phpunit_soap.xml"
    sed -i.back "s|http://magento.url|http://${magento_host_name}|g" "${magento_tests_root}/api-functional/phpunit_soap.xml"
    sed -i.back "s|http://magento-ee.localhost|http://${magento_host_name}|g" "${magento_tests_root}/api-functional/phpunit_soap.xml"
    sed -i.back "s|<const name=\"TESTS_CLEANUP\" value=\"enabled\"/>|<const name=\"TESTS_CLEANUP\" value=\"disabled\"/>|g" "${magento_tests_root}/api-functional/phpunit_soap.xml"
    rm -f "${magento_tests_root}/api-functional/phpunit_soap.xml.back"
fi
if [[ ! -f "${magento_tests_root}/api-functional/phpunit_graphql.xml" ]] && [[ -f "${magento_tests_root}/api-functional/phpunit_graphql.xml.dist" ]]; then
    status "Creating configuration for GraphQL tests"
    cp "${magento_tests_root}/api-functional/phpunit_graphql.xml.dist" "${magento_tests_root}/api-functional/phpunit_graphql.xml"
    sed -i.back "s|http://magento.url|http://${magento_host_name}|g" "${magento_tests_root}/api-functional/phpunit_graphql.xml"
    sed -i.back "s|http://magento-ee.localhost|http://${magento_host_name}|g" "${magento_tests_root}/api-functional/phpunit_graphql.xml"
    sed -i.back "s|<const name=\"TESTS_CLEANUP\" value=\"enabled\"/>|<const name=\"TESTS_CLEANUP\" value=\"disabled\"/>|g" "${magento_tests_root}/api-functional/phpunit_graphql.xml"
    rm -f "${magento_tests_root}/api-functional/phpunit_graphql.xml.back"
fi

# Functional tests
# TODO: Eliminate MTF tests since they are deprecated in favor of MFTF
if [[ ! -f "${magento_tests_root}/functional/phpunit.xml" ]] && [[ -f "${magento_tests_root}/functional/phpunit.xml.dist" ]]; then
    status "Creating configuration for Functional tests"
    cp "${magento_tests_root}/functional/phpunit.xml.dist" "${magento_tests_root}/functional/phpunit.xml"

    # For Magento 2.0 and 2.1
    sed -i.back "s|http://localhost|http://${magento_host_name}|g" "${magento_tests_root}/functional/phpunit.xml"
    # For Magento 2.2
    sed -i.back "s|http://127.0.0.1|http://${magento_host_name}|g" "${magento_tests_root}/functional/phpunit.xml"
    # For Magento 2.3
    sed -i.back "s|http://magento2ce.com/|http://${magento_host_name}|g" "${magento_tests_root}/functional/phpunit.xml"
    sed -i.back "s|http://magento2ee.com/|http://${magento_host_name}|g" "${magento_tests_root}/functional/phpunit.xml"

    sed -i.back "s|/backend/|/${magento_admin_frontname}/|g" "${magento_tests_root}/functional/phpunit.xml"
    rm -f "${magento_tests_root}/functional/phpunit.xml.back"

    if [[ ! -f "${magento_tests_root}/functional/etc/config.xml" ]] && [[ -f "${magento_tests_root}/functional/etc/config.xml.dist" ]]; then
        cp "${magento_tests_root}/functional/etc/config.xml.dist" "${magento_tests_root}/functional/etc/config.xml"
        sed -i.back "s|http://magento2ce.com|http://${magento_host_name}|g" "${magento_tests_root}/functional/etc/config.xml"
        sed -i.back "s|admin/|${magento_admin_frontname}/|g" "${magento_tests_root}/functional/etc/config.xml"
        sed -i.back "s|<backendLogin>admin</backendLogin>|<backendLogin>${magento_admin_user}</backendLogin>|g" "${magento_tests_root}/functional/etc/config.xml"
        sed -i.back "s|<backendPassword>123123q</backendPassword>|<backendPassword>${magento_admin_password}</backendPassword>|g" "${magento_tests_root}/functional/etc/config.xml"
        rm -f "${magento_tests_root}/functional/etc/config.xml.back"
    fi
fi

status "Configuring MFTF tests using build:project"
${devbox_dir}/$(getDevBoxContext)/vendor/bin/mftf build:project --MAGENTO_BASE_URL="http://magento.$(getDevBoxContext)/" 2> >(logError) > >(log)

decrementNestingLevel
