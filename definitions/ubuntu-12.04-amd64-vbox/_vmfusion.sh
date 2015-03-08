set -ex

cd /tmp

set +e
/etc/init.d/virtualbox-ose-guest-utils stop
/etc/init.d/virtualbox-ose-guest-x11 stop
rmmod vboxguest
apt-get -y purge virtualbox-ose-guest-x11 virtualbox-ose-guest-dkms virtualbox-ose-guest-utils
set -e

export VMTOOLS_ARCHIVE=/home/vagrant/_latest_vmware_tools.tar.gz

VMTOOLS_MOUNT_OPTIONS=${VMTOOLS_MOUNT_OPTIONS:-ro}
SHA=34150fba41a2c62b016f83d9de9ff8c75aa7274c
VMTOOLS_PATCHES=/tmp/vmware-tools-patches-$SHA/

if [ "$USER" != "root" ]; then 
  echo "Can not run this as \"$USER\". Please sudo"
  exit 255
fi

DISTRIB=$(uname -r | cut -d- -f3)
if ! dpkg -L linux-headers-$DISTRIB >/dev/null 2>&1; then
  echo -n "Installing linux-headers-$DISTRIB: "
  if apt-get -qq -y install linux-headers-$DISTRIB >/dev/null 2>&1; then
    echo "Ok"
  else
    echo "Error"
    exit 7
  fi
fi

if ! dpkg -L linux-headers-$(uname -r) >/dev/null 2>&1; then
  echo -n "Installing linux-headers-$(uname -r): " 
  if apt-get -qq -y install linux-headers-$(uname -r) >/dev/null 2>&1; then
    echo "Ok"
  else
    echo "Error"
    exit 7
  fi
fi

if ! dpkg -L build-essential >/dev/null 2>&1; then 
  echo -n "Installing build-essential: "
  if apt-get -qq -y install build-essential >/dev/null 2>&1; then
    echo "Ok"
  else
    echo "Error"
    exit 7
  fi
fi


rm -rf $VMTOOLS_PATCHES
curl -q -L# https://github.com/rasa/vmware-tools-patches/archive/${SHA}.tar.gz | tar -C /tmp -xz

cd  $VMTOOLS_PATCHES

# Something about the lts-trusty-kernel image means the versions are wrong
cat > patches/vmhgfs/99-vmhgfs-inode-hack-hack-bodge.patch   <<EOF
--- vmhgfs-only/inode.c.oirg    2015-03-06 14:56:04.344130628 +0000
+++ vmhgfs-only/inode.c 2015-03-06 14:56:14.583830707 +0000
@@ -1922,11 +1922,7 @@
                            p,
 #endif
                            &inode->i_dentry,
-#if LINUX_VERSION_CODE < KERNEL_VERSION(3, 18, 1) && !defined(__GENKSYMS__) && !defined(D_ALIAS_IS_A_MEMBER_OF_UNION_D_U)
-                           d_alias) {
-#else
                            d_u.d_alias) {
-#endif
          int dcount = hgfs_d_count(dentry);
          if (dcount) {
             LOG(4, ("Found %s %d \n", dentry->d_name.name, dcount));
@@ -1979,11 +1975,7 @@
       /* Find a dentry with valid d_count. Refer bug 587879. */
       list_for_each(pos, &inode->i_dentry) {
          int dcount;
-#if LINUX_VERSION_CODE < KERNEL_VERSION(3, 18, 1) && !defined(__GENKSYMS__) && !defined(D_ALIAS_IS_A_MEMBER_OF_UNION_D_U)
-         struct dentry *dentry = list_entry(pos, struct dentry, d_alias);
-#else
          struct dentry *dentry = list_entry(pos, struct dentry, d_u.d_alias);
-#endif
          dcount = hgfs_d_count(dentry);
          if (dcount) {
             LOG(4, ("Found %s %d \n", (dentry)->d_name.name, dcount));
EOF

./untar-and-patch-and-compile.sh $VMTOOLS_ARCHIVE

###################

set -x

# Load the hgfs module immediately at boot. This makes 'vagrant up' faster at
# the at "Waiting for HGFS kernel module to load" stage.
echo vmhgfs >> /etc/modules
