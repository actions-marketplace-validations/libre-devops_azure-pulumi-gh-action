# Libre DevOps - Azure Pulumi GitHub Action

Hello :wave:

This is a repository for the heavily opinionated GitHub Action to run Pulumi, mainly targetting Azure. As stated, this action is opinionated, in that it expects all parameters to provided to it, and will only run on the assumption these work - or else, it should error.  It is mainly used for the development of Libre DevOps pulumi modules - but could be used by others, but be aware that it is not for everyone!

## What it does

- Pulls a Docker container - `ghcr.io/libre-devops/azure-pulumi-gh-action-base:latest`
- Runs a Standard Pulumi Workflow as Follows:
```shell
pulumi login
pulumi preview
``` 

- Then, based on some parameters to the action, will run other parts:
```shell
pulumi up
pulumi destroy
```

### Example Usage

Check out the [workflows](https://github.com/libre-devops/azure-pulumi-gh-action/tree/main/.github/workflows) folder for more examples

```yaml
name: 'Pulumi Up'

#Allow run manually or on push to main or in PR closure
on:
  workflow_dispatch:

jobs:
  azure-pulumi-job:
    name: 'Pulumi Build'
    runs-on: ubuntu-latest
    environment: tst

    # Use the Bash shell regardless whether the GitHub Actions runner is ubuntu-latest, macos-latest, or windows-latest
    defaults:
      run:
        shell: bash

    steps:
      - uses: actions/checkout@v3

      - name: Libre DevOps - Run Pulumi for Azure - GitHub Action
        id: pulumi-build
        uses: libre-devops/azure-pulumi-gh-action@v1
        with:
          pulumi-path: "pulumi/hello-world"
          pulumi-stack-name: "dev"
          pulumi-config-passphrase: ${{ secrets.SpokeSaRgName }}
          pulumi-backend-storage-account-name: ${{ secrets.SpokePulumiPassphrase }}
          pulumi-backend-url-prefix: "azblob://"
          pulumi-backend-blob-container-name: ${{ secrets.SpokeSaBlobContainerName }}
          pulumi-backend-storage-access-key: ${{ secrets.SpokeSaPrimaryKey }}
          pulumi-provider-client-id: ${{ secrets.SpokeSvpClientId }}
          pulumi-provider-client-secret: ${{ secrets.SpokeSvpClientSecret }}
          pulumi-provider-subscription-id: ${{ secrets.SpokeSubId }}
          pulumi-provider-tenant-id: ${{ secrets.SpokeTenantId }}
          run-pulumi-destroy: "false"
          run-pulumi-preview-only: "false"

```

### Logic

```
if run-pulumi-destroy = false AND run-pulumi-preview-only = true == Run pulumi plan but NEVER run pulumi apply
if run-pulumi-destroy = true AND run-pulumi-preview-only = true == Run pulumi plan -destroy but NEVER run pulumi apply
if run-pulumi-destroy = false AND run-pulumi-preview-only = false == Run pulumi plan AND run pulumi apply
if run-pulumi-destroy = run AND run-pulumi-preview-only = false == Run pulumi plan -destroy AND run pulumi apply
```


### Inputs

```yaml
  # action.yml
name: 'Libre DevOps - Run Pulumi for Azure -  GitHub Action'
description: 'The heavily opinionated Libre DevOps Action to run Pulumi in Azure.'
author: "Craig Thacker <craig@craigthacker.dev>"
branding:
  icon: 'terminal'
  color: 'red'

inputs:
  pulumi-path:
    description: 'The absolute path in Linux format to your pulumi code'
    required: true

  pulumi-stack-name:
    description: 'The name of a pulumi stack, should be in plain text string'
    required: true

  pulumi-config-passphrase:
    description: 'The secret passphrase to your state, needed for security'
    required: true

  pulumi-backend-storage-account-name:
    description: 'The name of your storage account , needed for state file storage'
    required: true

  pulumi-backend-url-prefix:
    description: 'The backend url of your backend, for Azure. it should be azblob:// needed for state file storage'
    required: true

  pulumi-backend-blob-container-name:
    description: 'The name of your storage account blob container, needed for state file storage'
    required: true

  pulumi-backend-storage-access-key:
    description: 'The key to access your storage account, needed for state file storage'
    required: true

  pulumi-provider-client-id:
    description: 'The client ID for your service principal, needed to authenticate to your tenant'
    required: true

  pulumi-provider-client-secret:
    description: 'The client secret for your service principal, needed to authenticate to your tenant'
    required: true

  pulumi-provider-subscription-id:
    description: 'The subscription id of the subscription you wish to deploy to, needed to authenticate to your tenant'
    required: true

  pulumi-provider-tenant-id:
    description: 'The tenant id of which contains subscription you wish to deploy to, needed to authenticate to your tenant'
    required: true

  run-pulumi-destroy:
    description: 'Do you want to run pulumi destroy? - Set to true to trigger pulumi plan -destroy'
    required: true
    default: "false"
    
  run-pulumi-preview-only:
    description: 'Do you only want to run pulumi plan & never run the apply or apply destroy? - Set to true to trigger pulumi plan only.'
    required: true
    default: "true"

runs:
  using: 'docker'
  image: 'Dockerfile'
  args:
    - ${{ inputs.pulumi-path }}
    - ${{ inputs.pulumi-stack-name }}
    - ${{ inputs.pulumi-config-passphrase }}
    - ${{ inputs.pulumi-backend-storage-account-name }}
    - ${{ inputs.pulumi-backend-url-prefix }}
    - ${{ inputs.pulumi-backend-blob-container-name }}
    - ${{ inputs.pulumi-backend-storage-access-key }}
    - ${{ inputs.pulumi-provider-client-id }}
    - ${{ inputs.pulumi-provider-client-secret }}
    - ${{ inputs.pulumi-provider-subscription-id }}
    - ${{ inputs.pulumi-provider-tenant-id }}
    - ${{ inputs.run-pulumi-destroy }}
    - ${{ inputs.run-pulumi-preview-only }}
```

### Outputs

None
