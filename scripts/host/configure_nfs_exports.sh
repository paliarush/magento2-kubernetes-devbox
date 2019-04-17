#!/usr/bin/env bash

set -e

cd "$(dirname "${BASH_SOURCE[0]}")/../.." && vagrant_dir=$PWD

source "${vagrant_dir}/scripts/functions.sh"
resetNestingLevel
current_script_name=`basename "$0"`
initLogFile ${current_script_name}

debug_vagrant_project="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "debug_vagrant_project")"
if [[ ${debug_vagrant_project} -eq 1 ]]; then
    set -x
fi

host_os="$(bash "${vagrant_dir}/scripts/host/get_host_os.sh")"
nfs_exports_record="$(bash "${vagrant_dir}/scripts/host/get_nfs_exports_record.sh")"
if [[ ${host_os} == "OSX" ]]; then
    if [[ -z "$(grep "${nfs_exports_record}" /etc/exports)" ]]; then
        status "Updating /etc/exports to enable codebase sharing with containers via NFS (${nfs_exports_record})"
        echo "${nfs_exports_record}" | sudo tee -a "/etc/exports" 2> >(logError) > >(log)
        sudo nfsd restart
        # TODO: Implement NFS exports clean up on project removal to prevent NFS mounting errors
    else
        warning "NFS exports are properly configured and do not need to be updated"
    fi
fi

if [[ ${host_os} == "Linux" ]]; then
    if [[ -z "$(grep "${nfs_exports_record}" /etc/exports)" ]]; then
        status "Updating /etc/exports to enable codebase sharing with containers via NFS (${nfs_exports_record})"
        echo "${nfs_exports_record}" | sudo tee -a "/etc/exports" 2> >(logError) > >(log)
        sudo service nfs-kernel-server restart
        sudo systemctl status rpc-statd.service
        sudo systemctl add-wants multi-user.target rpcbind.service
        sudo systemctl start rpcbind
        sudo systemctl status rpc-statd.service
        # TODO: Implement NFS exports clean up on project removal to prevent NFS mounting errors
    else
        warning "NFS exports are properly configured and do not need to be updated"
    fi
fi

info "$(regular)See details in $(bold)${vagrant_dir}/log/${current_script_name}.log$(regular). For debug output set $(bold)debug:vagrant_project$(regular) to $(bold)1$(regular) in $(bold)etc/config.yaml$(regular)"
