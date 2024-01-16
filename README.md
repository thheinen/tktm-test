# README

# Prerequisites

- Internet Connection
- Visual Studio Code
- An AWS account for instances to start in (Test Kitchen)
- Windows Subsystem for Linux, if on Window
- Docker installed in WSL 2 or on MacOS

Alternative: Open in GitHub DevContainers and provide AWS credentials. This will fulfill all prerequisites

# Getting Started

- Open in Visual Studio Code
- When asked "Dev Container detected" select to open in Dev Container. Initial build can take 5-10 minutes due to dependencies
- You will end up in a preconfigured environment and can open a Terminal inside of it (if not done automatically)

Workaround:
- execute `./import-patches.sh` initially to apply various patches to the stock projects (Chef, Kitchen, Kitchen Driver, Train, ...)

# Remark on Handling Changes in the Fork Branches

Whenever changes in any of the external repositories (usually in the `thheinen/target-mode` branches) occur, you need to rebuild the container and rerun the `import-patches.sh` script

You can trigger a rebuild of the container via Ctrl-Shift-P and then "Dev Container: Rebuild Container". It is not necessary to build without cache. After the rebuild, apply the patches with the mentioned script again.

# Known Issues / Remediations

## Test Kitchen: Could not load the 'chef_target_provisioner'

__Error:__

After any `kitchen` command, the following error is shown:
```
>>>>>> Message: Could not load the 'chef_target' provisioner from the load path
```

__Reason:__

The required patches were not applied (see "Getting Started" and `import-patches.sh`)

## Test Kitchen: No instances for regex

__Error:__

After `kitchen list` or similar commands the following error is shown:
```
No instances for regex `', try running `kitchen list'
```

__Reason:__

All provider (AWS) specific resources are in `kitchen.ec2.yml` which is not the standard file for a local Kitchen configuration.
Execute `export KITCHEN_LOCAL_YML="kitchen.ec2.yml"` and execute the kitchen command again

## Test Kitchen: "requires a Train-based transport"

__Error:__

Chef Target Mode provisioner requires a Train-based transport like kitchen-transport-train

__Reason:__

You need to switch the Train transport to `name: train` to enable exchange of connection data between the transport and Chef itself.

## Test Kitchen: "can't modify frozen String"

__Error:__

After executing `kitchen create` the following error is displayed:

```
Failed to complete #create action: [can't modify frozen String: "" in the specified region eu-west-1.
```

__Reason:__

_Unknown_

Usually happens when SSH connection to a newly created instance on AWS does not work. Works on GitHub Codespaces, but fails locally - while permitted IPs are set in `kitchen.ec2.yml` dynamically.

_Caution:_ sometimes does not remove the faulty instance, which continues to run and incur costs.