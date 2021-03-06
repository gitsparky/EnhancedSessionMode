# Install Hyper-V Enhanced Session Mode on Fedora 29

# Load the Hyper-V kernel module
echo "hv_sock" | sudo tee -a /etc/modules-load.d/hv_sock.conf > /dev/null

# Configure SELinux
# ATTENTION: This makes your system much more insecure!
sudo sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config

# Recompile XRDP with Hyper-V enabled
sudo dnf install -y rpmdevtools rpm-build
rpmdev-setuptree
dnf download --source xrdp
rpm -ivh xrdp*.src.rpm
sudo dnf builddep -y xrdp
sed -i '/^%configure/ s/$/ --enable-vsock/' ~/rpmbuild/SPECS/xrdp.spec
rpmbuild -bb ~/rpmbuild/SPECS/xrdp.spec

# Install XRDP with Hyper-V enabled
rm -f ~/rpmbuild/RPMS/x86_64/xrdp-d*
rm -f ~/rpmbuild/RPMS/x86_64/xrdp-s*
sudo dnf install -y ~/rpmbuild/RPMS/x86_64/xrdp*.x86_64.rpm
sudo systemctl enable xrdp
sudo systemctl start xrdp

# Configure xrdp
sudo sed -i "/^use_vsock=.*/c\use_vsock=true" /etc/xrdp/xrdp.ini
sudo sed -i "/^security_layer=.*/c\security_layer=rdp" /etc/xrdp/xrdp.ini
sudo sed -i "/^crypt_level=.*/c\crypt_level=none" /etc/xrdp/xrdp.ini
sudo sed -i "/^bitmap_compression=.*/c\bitmap_compression=false" /etc/xrdp/xrdp.ini
sudo sed -i "/^max_bpp=.*/c\max_bpp=24" /etc/xrdp/xrdp.ini

sudo sed -i "/^X11DisplayOffset=.*/c\X11DisplayOffset=0" /etc/xrdp/sesman.ini
echo "allowed_users=anybody" | sudo tee -a /etc/X11/Xwrapper.conf > /dev/null

# Prevent dnf from reinstalling or upgrading xrdp to a version without Hyper-V support
echo "exclude=xrdp" | sudo tee -a /etc/dnf/dnf.conf > /dev/null






