lang en_US.UTF-8
keyboard us
timezone --utc Etc/UTC
auth --useshadow --enablemd5
selinux --permissive
bootloader --timeout=1 --append="acpi=force"
# root password is "redhat" but the account is locked
rootpw --iscrypted $1$_redhat_$i3.3Eg7ko/Peu/7Q/1.wJ/
part / --size 8000 --fstype ext4 --ondisk sda

xconfig --startxonboot

services --disabled=network,sshd --enabled=NetworkManager
