## Ubuntu Linux System Preparation Repository

This repository hosts a collection of utility scripts and templates tailored for system administrators and IT professionals who work with cloned Ubuntu Linux systems. It focuses on key aspects of system preparation (sysprep) after cloning, including logical volume management, machine ID regeneration, and network configuration. These tools are essential for ensuring that each cloned system operates with unique identifiers and optimal storage and network configurations, vital for maintaining system integrity and network functionality in cloned environments.



## Scripts

### ubuntu-init.sh

```shell
wget https://raw.githubusercontent.com/hongyanca/shell-script-utilities/main/sysprep-ubuntu/ubunut-init.sh
```

The `ubuntu-init.sh` script is used for Ubuntu server initialization. It performs the following tasks:

1. Setup user `ubuntu` to use `sudo` without password prompt.
2. Remove `/etc/motd`.
3. Turn off swap.
4. Set timezone.
5. Add git-lfs and Docker repo.
6. Install common packages.
7. Install Ubuntu HWE kernel.

### prepare-k8s-install.sh

The `prepare-k8s-install.sh` scrip is used for Kubernetes installation preparation. It performs the following tasks:

1. Enable forwarding IPv4 and letting iptables see bridged traffic.
2. Override the sandbox (pause) image from `registry.k8s.io/pause:3.6` to `registry.k8s.io/pause:3.9`.
3. Use the `SystemdCgroup` driver in `/etc/containerd/config.toml` with `runc`.
4. Discard the compressed layer data after unpacking.

### new-machine-id.sh

The `new-machine-id.sh` script is used for regenerating the machine ID of your Linux system. This might be necessary in cases where you've cloned a system and need to ensure it has a unique identifier.

#### Usage

Run this script as a root user. It will remove the current machine IDs and generate new ones.

```
sudo ./new-machine-id.sh
```

### extend-root-lv.sh

The `extend-root-lv.sh` script is designed to extend the logical volume that is mounted at the root (`/`) directory. This is particularly useful when you've added a new disk or extended the size of the virtual disk and want to extend your root filesystem.

#### Usage

Ensure you have root privileges before running this script. It's also recommended to backup any important data before proceeding.

```bash
sudo ./extend-root-lv.sh
```



## Netplan Configuration Template

The repository also includes a template for Netplan, which is a network configuration utility in Ubuntu. The template is set up to use a MAC address as a `dhcp-identifier`. 

### Usage

Edit the template to include your specific configuration details. Save it to `/etc/netplan/00-installer-config.yaml`. Then, apply the configuration using Netplan.

```
sudo netplan apply
```



## Contributions

Contributions to this repository are welcome. Please ensure that you test any changes thoroughly before submitting a pull request.



## License

This project is licensed under the MIT License.

------

Note: It's always important to use these scripts and configurations with caution, especially in production environments. Always backup your data and configuration files before making changes.