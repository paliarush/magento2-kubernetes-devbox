#!/usr/bin/env bash

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/functions.sh"
incrementNestingLevel

# TODO: Calculate network IP
host_os="$(bash "${vagrant_dir}/scripts/host/get_host_os.sh")"
if [[ ${host_os} == "OSX" ]]; then
    nfs_exports_record="\"${vagrant_dir}\" -alldirs -mapall=$(id -u):$(id -g) -mask 255.0.0.0 -network 192.0.0.0"
elif [[ ${host_os} == "Linux" ]]; then
    nfs_exports_record="\"${vagrant_dir}\" *(rw,sync,no_root_squash,no_all_squash)"
else
    error "Host OS is not supported"
    exit 1
fi

echo "${nfs_exports_record}"

decrementNestingLevel
