#!/usr/bin/env bash

## TODO: Fix
set -e

vagrant_dir=$PWD

sudo adduser nfsuser

source "${vagrant_dir}/scripts/functions.sh"
resetNestingLevel
current_script_name=`basename "$0"`
initLogFile ${current_script_name}

debug_vagrant_project="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "debug_vagrant_project")"
if [[ ${debug_vagrant_project} -eq 1 ]]; then
    set -x
fi

config_path="${vagrant_dir}/etc/config.yaml"
if [[ ! -f "${config_path}" ]]; then
    status "Initializing etc/config.yaml using defaults from etc/config.yaml.dist"
    cp "${config_path}.dist" "${config_path}"
fi

magento_ce_dir="${vagrant_dir}/magento"
magento_ce_sample_data_dir="${magento_ce_dir}/magento2ce-sample-data"
magento_ee_dir="${magento_ce_dir}/magento2ee"
magento_ee_sample_data_dir="${magento_ce_dir}/magento2ee-sample-data"
host_os="$(bash "${vagrant_dir}/scripts/host/get_host_os.sh")"
use_nfs="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "guest_use_nfs")"
nfs_server_ip="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "guest_nfs_server_ip")"
repository_url_ce="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "repository_url_ce")"
#repository_url_checkout="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "repository_url_checkout")"
repository_url_ee="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "repository_url_ee")"
composer_project_name="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "composer_project_name")"
composer_project_url="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "composer_project_url")"
checkout_source_from="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "checkout_source_from")"

function checkoutSourceCodeFromGit()
{
    if [[ ! -d ${magento_ce_dir} ]]; then
#        if [[ ${host_os} == "Windows" ]]; then
#            status "Configuring git for Windows host"
#            git config --global core.autocrlf false
#            git config --global core.eol LF
#            git config --global diff.renamelimit 5000
#        fi

        initMagentoCeGit
        initMagentoCeSampleGit

        # By default EE repository is not specified and EE project is not checked out
        if [[ -n "${repository_url_ee}" ]]; then
            initMagentoEeGit
        fi
        # By default EE sample data repository is not specified and EE project is not checked out
        repository_url_ee_sample_data="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "repository_url_ee_sample_data")"
        if [ -n "${repository_url_ee_sample_data}" ]; then
            initMagentoEeSampleGit
        fi
    fi
}

function initMagentoCeGit()
{
    initGitRepository ${repository_url_ce} "CE" "${magento_ce_dir}"
}

function initMagentoEeGit()
{
    initGitRepository ${repository_url_ee} "EE" "${magento_ee_dir}"
}

function initMagentoCeSampleGit()
{
    repository_url_ce_sample_data="$(bash "${vagrant_dir}/scripts/get_config_value.sh" "repository_url_ce_sample_data")"
    initGitRepository ${repository_url_ce_sample_data} "CE sample data" "${magento_ce_sample_data_dir}"
}

function initMagentoEeSampleGit()
{
    initGitRepository ${repository_url_ee_sample_data} "EE sample data" "${magento_ee_sample_data_dir}"
}

# Initialize the cloning and checkout of a git repository
# Arguments:
#   Url of repository
#   Name of repository (CE, EE)
#   Directory where the repository will be cloned to
function initGitRepository()
{
    local repository_url=${1}
    local repository_name=${2}
    local directory=${3}

    if [[ ${repository_url} == *"::"* ]]; then
        local branch=$(getGitBranch ${repository_url})
        local repo=$(getGitRepository ${repository_url})
    else
        local repo=${repository_url}
    fi

    status "Checking out ${repository_name} repository"
    git clone ${repo} "${directory}" 2> >(logError) > >(log)

    if [[ -n ${branch} ]]; then
        status "Checking out branch ${branch} of ${repository_name} repository"
        cd "${directory}"
        git fetch 2> >(logError) > >(log)
        git checkout ${branch} 2> >(log) > >(log)
    fi
    cd "${vagrant_dir}"
}

# Get the git repository from a repository_url setting in config.yaml
function getGitRepository()
{
    local repo="${1%::*}" # Gets the substring before the '::' characters
    echo ${repo}
}

# Get the git branch from a repository_url setting in config.yaml
function getGitBranch()
{
    local branch="${1#*::}" # Gets the substring after the '::' characters
    echo ${branch}
}

function composerCreateProject()
{
    if [[ ! -d ${magento_ce_dir} ]]; then
        status "Downloading Magento codebase using 'composer create-project'"
        bash "${vagrant_dir}/scripts/host/composer.sh" create-project ${composer_project_name} "${magento_ce_dir}" --repository-url=${composer_project_url}

        # TODO: Workaround for Magento 2.2+ until PHP is upgraded to 7.1 on the guest
        cd "${magento_ce_dir}"
        composer_dir="${vagrant_dir}/scripts/host"
        composer_phar="${composer_dir}/composer.phar"
        php_executable="$(bash "${vagrant_dir}/scripts/host/get_path_to_php.sh")"
        project_version="$("${php_executable}" "${composer_phar}" show --self | grep version)"
        matching_version_pattern='2.[23].[0-9]+'
        if [[ ${project_version} =~ ${matching_version_pattern} ]]; then
            status "Composer require zendframework/zend-code:~3.1.0 (needed for Magento 2.2+ only)"
            cd "${magento_ce_dir}"
            bash "${vagrant_dir}/scripts/host/composer.sh" require "zendframework/zend-code:~3.1.0"
        fi
    fi
}

bash "${vagrant_dir}/scripts/host/check_requirements.sh"

# Clean up the project before initialization if "-f" option was specified. Remove codebase if "-fc" is used.
force_project_cleaning=0
force_codebase_cleaning=0
force_phpstorm_config_cleaning=0
disable_nfs=0
enable_checkout=0
while getopts 'fcpde' flag; do
  case "${flag}" in
    f) force_project_cleaning=1 ;;
    c) force_codebase_cleaning=1 ;;
    p) force_phpstorm_config_cleaning=1 ;;
    d) disable_nfs=1 ;;
    e) enable_checkout=1 ;;
    *) error "Unexpected option" && exit 1;;
  esac
done
if [[ ${force_project_cleaning} -eq 1 ]]; then
    status "Cleaning up the project before initialization since '-f' option was used"

# TODO: Remove if not needed in the future
#    if [[ $(isMinikubeInitialized) -eq 1 ]]; then
#        bash "${vagrant_dir}/scripts/host/k_rebuild_environment.sh"
#    fi


#    if [[ $(isMinikubeRunning) -eq 1 ]]; then
#        minikube stop 2> >(logError) | {
#          while IFS= read -r line
#          do
#            filterVagrantOutput "${line}"
#            lastline="${line}"
#          done
#          filterVagrantOutput "${lastline}"
#        }
#    fi
#    if [[ $(isMinikubeStopped) -eq 1 ]]; then
#        minikube delete 2> >(logError) | {
#          while IFS= read -r line
#          do
#            filterVagrantOutput "${line}"
#            lastline="${line}"
#          done
#          filterVagrantOutput "${lastline}"
#        }
#    fi

    mv "${vagrant_dir}/etc/guest/.gitignore" "${vagrant_dir}/etc/.gitignore.back"
    rm -rf "${vagrant_dir}/.vagrant" "${vagrant_dir}/etc/guest"
    mkdir "${vagrant_dir}/etc/guest"
    mv "${vagrant_dir}/etc/.gitignore.back" "${vagrant_dir}/etc/guest/.gitignore"
    cd "${vagrant_dir}/log" && mv email/.gitignore email_gitignore.back && rm -rf email && mkdir email && mv email_gitignore.back email/.gitignore
    if [[ ${force_codebase_cleaning} -eq 1 ]]; then
        status "Removing current Magento codebase before initialization since '-c' option was used"
        rm -rf "${magento_ce_dir}"
    fi
fi

if [[ ! -d ${magento_ce_dir} ]]; then
    if [[ "${checkout_source_from}" == "composer" ]]; then
        composerCreateProject
    elif [[ "${checkout_source_from}" == "git" ]]; then
        checkoutSourceCodeFromGit
    else
        error "Value specified for 'checkout_source_from' is invalid. Supported options: composer OR git"
        exit 1
    fi
fi

status "Initializing dev box"
cd "${vagrant_dir}"

#if [[ $(isMinikubeInitialized) -eq 1 ]]; then
#    warning "The project has already been initialized.
#    To re-initialize the project add the '-f' flag (using just '-f' will not affect Magento codebase or PHP Storm settings).
#    To delete Magento codebase and initialize it from scratch based on etc/config.yaml add '-c' flag.
#    To reconfigure PHP Storm add '-p' flag."
#    exit 0
#fi

if [[ $(isMinikubeRunning) -eq 0 ]]; then
    status "Starting minikube"
    minikube start --cpus=2 --memory=4096
    minikube addons enable ingress
    minikube addons enable heapster
    # hanged in some cases todo
#    minikube start --cache-images --cpus=2 --memory=4096 2> >(logError) | {
#      while IFS= read -r line
#      do
#        filterVagrantOutput "${line}"
#        lastline="${line}"
#      done
#      filterVagrantOutput "${lastline}"
#    }
fi

config_content="$(cat ${config_path})"
default_nfs_server_ip_pattern="nfs_server_ip: \"0\.0\.0\.0\""
if [[ ! ${config_content} =~ ${default_nfs_server_ip_pattern} ]]; then
    status "Custom NFS server IP is already specified in etc/config.yaml (${nfs_server_ip})"
else
    nfs_server_ip="$(minikube ip | grep -oh ^[0-9]*\.[0-9]*\.[0-9]*\. | head -1 | awk '{print $1"1"}')"
    status "Saving NFS server IP to etc/config.yaml (${nfs_server_ip})"
    sed -i.back "s|${default_nfs_server_ip_pattern}|nfs_server_ip: \"${nfs_server_ip}\"|g" "${config_path}"
    rm -f "${config_path}.back"
fi

status "Configuring kubernetes cluster on the minikube"
# TODO: Optimize. Helm tiller must be initialized and started before environment configuration can begin
helm init --wait
#waitForKubernetesPodToRun 'tiller-deploy'

# TODO: change k-rebuild-environment to comply with formatting requirements
if [[ "${disable_nfs}" == 1 ]]; then
    if [[ "${enable_checkout}" == 1 ]]; then
        bash "${vagrant_dir}/scripts/host/k_rebuild_environment.sh" -d -e
    else
        bash "${vagrant_dir}/scripts/host/k_rebuild_environment.sh" -d
    fi
else
    if [[ "${enable_checkout}" == 1 ]]; then
        bash "${vagrant_dir}/scripts/host/k_rebuild_environment.sh" -e
    else
        bash "${vagrant_dir}/scripts/host/k_rebuild_environment.sh"
    fi
fi

monolith_ip="$(minikube service magento2-monolith --url | grep -oE '[0-9][^:]+' | head -1)"
status "Saving Magento monolith container IP to etc/config.yaml (${monolith_ip})"
sed -i.back "s|ip_address: \".*\"|ip_address: \"${monolith_ip}\"|g" "${config_path}"
sed -i.back "s|host_name: \".*\"|host_name: \"${monolith_ip}\"|g" "${config_path}"
rm -f "${config_path}.back"

bash "${vagrant_dir}/scripts/host/check_mounted_directories.sh"

if [[ ${force_project_cleaning} -eq 1 ]] && [[ ${force_phpstorm_config_cleaning} -eq 1 ]]; then
    status "Resetting PhpStorm configuration since '-p' option was used"
    rm -rf "${vagrant_dir}/.idea"
fi
if [[ ! -f "${vagrant_dir}/.idea/deployment.xml" ]]; then
    bash "${vagrant_dir}/scripts/host/configure_php_storm.sh"
fi
bash "${vagrant_dir}/scripts/host/configure_tests.sh"

#if [[ ${host_os} == "Windows" ]] || [[ ${use_nfs} == 0 ]]; then
#    # Automatic switch to EE during project initialization cannot be supported on Windows
#    status "Installing Magento CE"
#    bash "${vagrant_dir}/scripts/host/m_reinstall.sh" 2> >(logError)
#else
    if [[ -n "${repository_url_ee}" ]]; then
        bash "${vagrant_dir}/scripts/host/m_switch_to_ee.sh" -f 2> >(logError)
    else
        bash "${vagrant_dir}/scripts/host/m_switch_to_ce.sh" -f 2> >(logError)
    fi
#fi

success "Project initialization succesfully completed (make sure there are no errors in the log above)"

info "$(bold)[Important]$(regular)
    Please use $(bold)${vagrant_dir}$(regular) directory as PhpStorm project root, NOT $(bold)${magento_ce_dir}$(regular)."

#if [[ ${host_os} == "Windows" ]] || [[ ${use_nfs} == 0 ]]; then
#    info "$(bold)[Optional]$(regular)
#    To verify that deployment configuration for $(bold)${magento_ce_dir}$(regular) in PhpStorm is correct,
#        use instructions provided here: $(bold)https://github.com/paliarush/magento2-vagrant-for-developers/blob/2.0/docs/phpstorm-configuration-windows-hosts.md$(regular).
#    If not using PhpStorm, you can set up synchronization using rsync"
#fi

info "$(regular)See details in $(bold)${vagrant_dir}/log/${current_script_name}.log$(regular). For debug output set $(bold)debug:vagrant_project$(regular) to $(bold)1$(regular) in $(bold)etc/config.yaml$(regular)"
