# README

# Prerequisites

- Internet Connection
- Visual Studio Code
- An AWS account for instances to start in (Test Kitchen)
- Windows Subsystem for Linux, if on Window
- Docker installed in WSL 2 or on MacOS

Alternative: Open in GitHub DevContainers and provide AWS credentials. This will fulfill all prerequisites

# Getting Started

## Visual Studio Code

- Open folder in Visual Studio Code
- When asked "Dev Container detected" select to open in Dev Container. Initial build can take 5-10 minutes due to dependencies
- You will end up in a preconfigured environment and can open a Terminal inside of it (if not done automatically)
- If you want to use Test Kitchen on AWS, you need to set the `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_REGION` environment variables in VS Code

## GitHub Codespaces

- Create a Codespace from the repository
- Add values for the `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_REGION` secrets if you want to use Test Kitchen on AWS

# Handling Changes in the Fork Branches

Whenever changes in any of the external repositories (usually in the `thheinen/target-mode` branches) occur, you need to rebuild the container. It will automatically execute the `import-patches.sh` script which bakes in the differences from those branches.

You can trigger a rebuild of the container via Ctrl-Shift-P and then "Dev Container: Rebuild Container". It is not necessary to build without cache. After the rebuild, apply the patches with the mentioned script again.

# Local Development

1. Remove the `name: train` transport configuration in `kitchen.yml` before creating a Test Kitchen Instance, this is a known bug (see below)
2. Ensure the `KITCHEN_LOCAL_YML` variable is set to `kitchen.ec2.yml`. This adds AWS-specific configuration on top of the general cookbook one
  - the config will limit access to the instance via SSH to the current IP
  - it also copies the auto-generated SSH key to root to enable root login
3. Run `kitchen create` in the container terminal window.
4. Enable the `name: train` transport configuration again and run `kitchen converge` to run the converge in Target Mode
  - the run will be around 1:30 - 2:00 minutes
5. Change code
  - if you need to change code in the upstream projects, you can put the corresponding files into the matching subdirectories in `tk_code`
  - you can redeploy those with the `reapply-ktt.sh` script or by clicking "Deploy chef_target" in the lower line of VS Code/CodeSpaces (cyan color)

# Known Issues / Remediations

## Test Kitchen: Could not load the 'chef_target' provisioner

__Error:__

After any `kitchen` command, the following error is shown:
```
>>>>>> Message: Could not load the 'chef_target' provisioner from the load path
```

__Reason:__

The required patches were not applied, which is weird (see "Getting Started" and execute `import-patches.sh` against clean Chef Workstation)

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

Chef Target Mode provisioner requires a Train-based transport like kitchen-transport-train to converge a machine remotely.

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
- create a fake Net:HTTP using `curl`/`wget` to allow redirected http requests without changing call signature? -> ohai EC2 mixin as example
- `user` does not get current state right: `Error executing action create on resource 'linux_user[chef]'` gives error code 9
- `git` does fail first time on `checkout` with error `128` although directory + command seem right. environment variable issue?
- need to make an alternative for `Shadow`: `Chef::Exceptions::MissingLibrary: linux_user[chef] (tktm_test::tm_2019 line 80) had an error: Chef::Exceptions::MissingLibrary: You must have ruby-shadow installed for password support!`