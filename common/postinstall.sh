# postinstall.sh based upon Mitchell's old basebox example

# mark the build time
date > /etc/vagrant_box_build_time

# update the apt cache and packages
case $(lsb_release -cs) in
    'precise')
        apt-get clean
        rm -rf /var/lib/apt/lists/*
        apt-get clean
    ;;
    *)
    ;;
esac

apt-get -qy update
apt-get -qy upgrade

# install some oft used packages
apt-get -qy install linux-headers-$(uname -r) build-essential
apt-get -qy install zlib1g-dev libssl-dev
apt-get -qy install python-software-properties python-setuptools python-dev

case $(lsb_release -cs) in
    'lucid')
        apt-get -qy install ruby-full

        # manually install a mucher newer version of rubygems
        curl -O http://production.cf.rubygems.org/rubygems/rubygems-2.3.0.tgz
        tar -xf rubygems-2.3.0.tgz
        cd rubygems-2.3.0/
        ruby setup.rb --no-ri --no-rdoc --no-format-executable
        cd ../

        # and then update rdoc (force ensures the executable is overwritten)
        gem install rdoc -v 4.1.1 -no-ri --no-rdoc --force
        gem install rdoc-data; rdoc-data --install
    ;;
    *)
        apt-get -qy install ruby1.9.3
    ;;
esac

# configure password-less sudo
usermod -a -G sudo vagrant
echo "%vagrant ALL=NOPASSWD:ALL" > /tmp/vagrant
mv /tmp/vagrant /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant

# install the vagrant-provided ssh keys
mkdir -pm 700 /home/vagrant/.ssh
curl -Lo /home/vagrant/.ssh/authorized_keys \
  'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub'
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# clean up any artifacts
rm -f /home/vagrant/shutdown.sh

exit
