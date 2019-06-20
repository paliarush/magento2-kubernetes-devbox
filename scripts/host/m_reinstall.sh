#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && devbox_dir=$PWD

source "${devbox_dir}/scripts/functions.sh"

# TODO: parameterize container

executeInMagento2Container "${devbox_dir}/scripts/guest/m-reinstall" 2> >(logError)
# Explicit exit is necessary to bypass incorrect output from devbox in case of errors
exit 0
