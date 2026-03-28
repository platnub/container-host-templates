- [Tools](#tools)
   - [Parted - Drive management](#parted---drive-management)
- [Manuals](#manuals)
   - [Passthrough drives to VM](#passthrough-drives-to-vm-source)
   - [VM Crash](#vm-crash)
   - [iGPU Passthrough Intel CPU](#igpu-passthrough-intel-cpu-source)
   - [Update device firmware](#update-device-firmware)

# Tools
## Parted - Drive management
```
parted
```

# Manuals

## Passthrough drives to VM _[source](https://pve.proxmox.com/wiki/Passthrough_Physical_Disk_to_Virtual_Machine_(VM))_
```
find /dev/disk/by-id/ -type l|xargs -I{} ls -l {}|grep -v -E '[0-9]$' |sort -k11|cut -d' ' -f9,10,11,12
```
```
qm set <vm> -scsi0 /dev/disk/by-id/...
```

## VM Crash

Sometimes a VM crashed with error:
```
trying to acquire lock...
TASK ERROR: can't lock file '/var/lock/qemu-server/lock-90010.conf' - got timeout
```
To fix this, restart the service pve-cluster

## iGPU Passthrough Intel CPU _[source](https://3os.org/infrastructure/proxmox/gpu-passthrough/igpu-passthrough-to-vm/#proxmox-configuration-for-igpu-full-passthrough)_

‼️ Proxmox loses GPU capabilities

1. SSH into Proxmox
2. Blacklist GPU drivers _[Proxmox Wiki](https://pve.proxmox.com/wiki/PCI_Passthrough#GPU_passthrough)_
   ```
   # AMD GPUs
   echo "blacklist amdgpu" >> /etc/modprobe.d/blacklist.conf
   echo "blacklist radeon" >> /etc/modprobe.d/blacklist.conf
   ```
   ```
   # NVIDIA GPUs
   echo "blacklist nouveau" >> /etc/modprobe.d/blacklist.conf 
   echo "blacklist nvidia*" >> /etc/modprobe.d/blacklist.conf
   ```
   ```
   # Intel GPUs
   echo "blacklist i915" >> /etc/modprobe.d/blacklist.conf
   ```
3.  ```
    nano /etc/default/grub
    ```
4. Edit `GRUB_CMDLINE_LINUX_DEFAULT="quiet"` to
    ```
    GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt pcie_acs_override=downstream,multifunction initcall_blacklist=sysfb_init video=simplefb:off video=vesafb:off video=efifb:off video=vesa:off disable_vga=1 vfio_iommu_type1.allow_unsafe_interrupts=1 kvm.ignore_msrs=1 modprobe.blacklist=radeon,nouveau,nvidia,nvidiafb,nvidia-gpu,snd_hda_intel,snd_hda_codec_hdmi,i915"
    ```
5. Run `update-grub`
6.  ```
    nano /etc/modules
    ```
7. Append this to the end of the file
    ```
    # Modules required for PCI passthrough
    vfio
    vfio_iommu_type1
    vfio_pci
    vfio_virqfd
    ```
8. Run `update-initramfs -u -k all`
9. Reboot Proxmox
10. Run `dmesg | grep -e DMAR -e IOMMU` and you should see `DMAR: IOMMU enabled`
11. <img width="921" height="236" alt="image" src="https://github.com/user-attachments/assets/096b208b-f95c-4e0e-9db1-685909cc55c1" />

## Update device firmware

Example: CPU, GPU drivers

1. ```
   apt update && apt upgrade -y && apt install fwupd
   ```
2. Follow [instructions from Github](https://github.com/fwupd/fwupd?tab=readme-ov-file#basic-usage-flow-command-line)

   If you have a device with firmware supported by fwupd, this is how you can check for updates and apply them using fwupd's command line tools.
   
   `fwupdmgr get-devices`
   
   This will display all devices detected by fwupd.
   
   `fwupdmgr refresh`
   
   This will download the latest metadata from LVFS.
   
   `fwupdmgr get-updates`
   
   If updates are available for any devices on the system, they'll be displayed.
   
   `fwupdmgr update`
   
   This will download and apply all updates for your system.
   - Updates that can be applied live will be done immediately.
   - Updates that run at boot-up will be staged for the next reboot.
