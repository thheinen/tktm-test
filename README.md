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

1. You need to switch the Train transport to `name: train` to enable exchange of connection data between the transport and Chef itself in __converge state__

2. You might have run `kitchen converge` as an all-in-one lifecycle step to create and converge the machine. As due to a bug you have to switch the Kitchen trainsport between standard `ssh` and `train` between both phases, run `kitchen create` first with the standard setting and then modify `kitchen.yml` to use the `name: train` statement for the `kitchen converge` step.

## Test Kitchen: "can't modify frozen String"

__Error:__

After executing `kitchen create` the following error is displayed:

```
Failed to complete #create action: [can't modify frozen String: "" in the specified region eu-west-1.
```

__Reason:__

_Unknown_

Usually happens when SSH connection to a newly created instance on AWS does not work. Seems to work on GitHub Codespaces, but fails locally - while permitted IPs are set in `kitchen.ec2.yml` dynamically.

_Caution:_ sometimes does not remove the faulty instance, which continues to run and incur costs.

Likely cause: Not reverting from the `train` transport to the standard one

## Performance Optimization Ideas

- reuse SSH connection (cuts down overhead)
- parallelize Ohai plugin execution
  - Threads? Makes debugging harder
  - Bulk execute commands (which are Read and side-effect free) and cut output. Might need different Plugin architecture (command map?)
- use port redirection or similar for the 169.25.169.254 connection
- cache files (e.g. `/etc/password`) but add invalidations after write(!)
- cache ohai across runs (for a certain time)
    - kind of dangerous, as cookbook runs will change this
    - but as runs are rarely writing, this could speed things up
    - should invalidate on explicit execution via `ohai` resource then

# TODOs

- support with `file_cache_path`, which currently points to the workstation, but needs to point at the target node