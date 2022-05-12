#!/usr/bin/env bash

set -eou pipefail

print_success() {
    lightcyan='\033[1;36m'
    nocolor='\033[0m'
    echo -e "${lightcyan}$1${nocolor}"
}

print_error() {
    lightred='\033[1;31m'
    nocolor='\033[0m'
    echo -e "${lightred}$1${nocolor}"
}

print_alert() {
    yellow='\033[1;33m'
    nocolor='\033[0m'
    echo -e "${yellow}$1${nocolor}"
}

print_alert "pulumi version = $(print_success $(pulumi version))"
print_alert "dotnet version = $(print_success $(dotnet --version))"
print_alert "golang version = $(print_success $(go version))"
print_alert "node version = $(print_success $(node --version))"
print_alert "python3 version = $(print_success $(python3 --version))"

print_alert "Java version below"
java -version

# Prepare variables with better common names
if [[ -n "${1}" ]]; then
    pulumi_path="${1}" && \
        cd "${pulumi_path}"
else
    print_error "Code path is empty or invalid, check the following tree output and see if it is as you expect - Error - LDO_PULUMI_CODE_PATH" && tree . && exit 1
fi

if [[ -n "${2}" ]]; then
    pulumi_stack_name="${2}"
else
    print_error "Pulumi stack variable appears to be empty or invalid, ensure that you can see - ${2} - if you cannot, set your workspace as a plain text chars and try again - Error - LDO_PULUMI_WORKSPACE" && exit 1
fi

if [[ -n "${3}" ]]; then
    pulumi_config_passphrase="${3}"
else
    print_error "Variable assignment for  failed  Pulumi state config or is invalid, ensure it is correct and try again - Error LDO_PULUMI_CONFIG_PASSPHRASE" && exit 1
fi

if [[ -n "${4}" ]]; then
    pulumi_backend_sa_name="${4}"
else
    print_error "Variable assignment for backend storage account name failed or is invalid, ensure it is correct and try again - Error LDO_PULUMI_BACKEND_SA_NAME" && exit 1
fi

if [[ -n "${5}" ]]; then
    pulumi_backend_url_prefix="${5}"
else
    print_error "Variable assignment for backend storage account name failed or is invalid, ensure it is correct and try again - Error LDO_PULUMI_BACKEND_SA_NAME" && exit 1
fi

if [[ -n "${6}" ]]; then
    pulumi_backend_blob_container_name="${6}"
else
    print_error "Variable assignment for backend storage account blob container failed or is invalid, ensure it is correct and try again - Error LDO_PULUMI_BACKEND_BLOB_CONTAINER_NAME" && exit 1
fi

if [[ -n "${7}" ]]; then
    pulumi_backend_storage_access_key="${7}"
else
    print_error "Variable assignment for backend storage access key name has failed or is invalid, ensure it is correct and try again - Error LDO_PULUMI_BACKEND_SA_ACCESS_KEY" && exit 1
fi

if [[ -n "${8}" ]]; then
    pulumi_provider_client_id="${8}"
else
    print_error "Variable assignment for provider client id has failed or is invalid,  ensure it is correct and try again - Error LDO_PULUMI_AZURERM_PROVIDER_CLIENT_ID" && exit 1
fi

if [[ -n "${9}" ]]; then
    pulumi_provider_client_secret="${9}"
else
    print_error "Variable assignment for provider client secret has failed or is invalid, ensure it is correct and try again - Error LDO_PULUMI_AZURERM_PROVIDER_CLIENT_SECRET" && exit 1
fi

if [[ -n "${10}" ]]; then
    pulumi_provider_client_subscription_id="${10}"
else
    print_error "Variable assignment for provider subscription id has failed or is invalid, ensure it is correct and try again - Error LDO_PULUMI_AZURERM_PROVIDER_SUBSCRIPTION_ID" && exit 1
fi

if [[ -n "${11}" ]]; then
    pulumi_provider_client_tenant_id="${11}"
else
    print_error "Variable assignment for provider tenant id has failed or is invalid, ensure it is correct and try again - Error LDO_PULUMI_AZURERM_PROVIDER_TENANT_ID" && exit 1
fi

if [[ -n "${12}" ]]; then
    run_pulumi_destroy="${12}"
else
    print_error "pulumi destroy is empty, it must be either true or false - change this and try again - Error code - LDO_PULUMI_pulumi_DESTROY" && exit 1
fi

if [[ -n "${13}" ]]; then
    run_pulumi_preview_only="${13}"
else
    print_error "pulumi Plan only is empty, it must be either true or false - change this and try again - Error code - LDO_PULUMI_pulumi_PLAN_ONLY" && exit 1
fi

export ARM_CLIENT_ID="${pulumi_provider_client_id}"
export ARM_CLIENT_SECRET="${pulumi_provider_client_secret}"
export ARM_SUBSCRIPTION_ID="${pulumi_provider_client_subscription_id}"
export ARM_TENANT_ID="${pulumi_provider_client_tenant_id}"
export PULUMI_CONFIG_PASSPHRASE="${pulumi_config_passphrase}"
export AZURE_STORAGE_ACCOUNT="${pulumi_backend_sa_name}"
export AZURE_STORAGE_KEY="${pulumi_backend_storage_access_key}"

# Run pulumi Plan Only
if [ "${run_pulumi_destroy}" = "false" ] && [ "${run_pulumi_preview_only}"  = "true" ]; then

    pulumi --color always --emoji login "${pulumi_backend_url_prefix}""${pulumi_backend_blob_container_name}"

    pulumi --color always --emoji preview --stack "${pulumi_stack_name}" --diff --color always --emoji

    print_success "Build ran successfully" || { print_error "Build Failed" ; exit 1; }

    # Run pulumi Plan and pulumi Apply
elif [ "${run_pulumi_destroy}" = "false" ] && [ "${run_pulumi_preview_only}"  = "false" ]; then

    pulumi --color always --emoji login "${pulumi_backend_url_prefix}""${pulumi_backend_blob_container_name}"

    pulumi --color always --emoji preview --stack "${pulumi_stack_name}" --diff

    pulumi --color always --emoji up --stack "${pulumi_stack_name}" --yes --diff

    print_success "Build ran successfully" || { print_error "Build Failed" ; exit 1; }

    # Run pulumi Plan -Destroy only
elif [ "${run_pulumi_destroy}" = "true" ] && [ "${run_pulumi_preview_only}"  = "true" ]; then

    pulumi --color always --emoji login "${pulumi_backend_url_prefix}""${pulumi_backend_blob_container_name}"

    pulumi --color always --emoji preview --stack "${pulumi_stack_name}" --diff

    print_success "It is not possible at this time to preview a destroy" || { print_error "Build Failed" ; exit 1; }

    # Run pulumi plan -destroy and pulumi apply
elif [ "${run_pulumi_destroy}" = "true" ] && [ "${run_pulumi_preview_only}"  = "false" ]; then

    pulumi --color always --emoji login "${pulumi_backend_url_prefix}""${pulumi_backend_blob_container_name}"

    pulumi --color always --emoji preview --stack "${pulumi_stack_name}" --diff

    pulumi --color always --emoji destroy --stack "${pulumi_stack_name}" --yes --diff

    print_success "Build ran successfully" || { print_error "Build Failed" ; exit 1; }

else

    print_error "Something went wrong with the build, check for errors and retry" ; exit 1

fi