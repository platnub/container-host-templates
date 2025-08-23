# Disk Management
## Parted
```
parted
```
## Passthrough drives to VM _[source](https://pve.proxmox.com/wiki/Passthrough_Physical_Disk_to_Virtual_Machine_(VM))_
```
find /dev/disk/by-id/ -type l|xargs -I{} ls -l {}|grep -v -E '[0-9]$' |sort -k11|cut -d' ' -f9,10,11,12
```
```
qm set <vm> -scsi0 /dev/disk/by-id/...
```
# Manuals
## iGPU Passthrough Intel CPU _[source](https://3os.org/infrastructure/proxmox/gpu-passthrough/igpu-passthrough-to-vm/#proxmox-configuration-for-igpu-full-passthrough)_

‼️ Proxmox lose GPU capabilities

1. SSH into Proxmox # https://pve.proxmox.com/wiki/PCI_Passthrough#GPU_passthrough
2.  ```
    nano /etc/default/grub
    ```
3. Edit `GRUB_CMDLINE_LINUX_DEFAULT="quiet"` to
    ```
    GRUB_CMDLINE_LINUX_DEFAULT="quiet intel_iommu=on iommu=pt pcie_acs_override=downstream,multifunction initcall_blacklist=sysfb_init video=simplefb:off video=vesafb:off video=efifb:off video=vesa:off disable_vga=1 vfio_iommu_type1.allow_unsafe_interrupts=1 kvm.ignore_msrs=1 modprobe.blacklist=radeon,nouveau,nvidia,nvidiafb,nvidia-gpu,snd_hda_intel,snd_hda_codec_hdmi,i915"
    ```
4. Run `update-grub`
5.  ```
    nano /etc/modules
    ```
6. Append this to the end of the file
    ```
    # Modules required for PCI passthrough
    vfio
    vfio_iommu_type1
    vfio_pci
    vfio_virqfd
    ```
7. Run `update-initramfs -u -k all`
8. Reboot Proxmox
9. Run `dmesg | grep -e DMAR -e IOMMU` and you should see `DMAR: IOMMU enabled`
10. <img width="921" height="236" alt="image" src="https://github.com/user-attachments/assets/096b208b-f95c-4e0e-9db1-685909cc55c1" />

