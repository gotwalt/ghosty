# Raspberry Pi Instructions
This project is perfect for a spare Raspberry Pi. Configured properly, you can plug it in to an ethernet port and forget about it. It'll do its thing automatically on boot. Below is an attempt at recalling the steps needed to get it going.

# Installation
1. Use raspbian, the Debian build for the board.
1. Install the following packages: `sudo apt-get install ruby-dev runit`.
1. Clone and chown the repo: `cd /opt; sudo git clone https://github.com/gotwalt/ghosty.md; sudo chown -R pi /opt/ghosty`.
1. Disable ruby documentation to make install faster: `sudo echo gem: --no-rdoc --no-ri > /etc/gemrc`.
1. Update rubygems & bundler: `sudo gem install rubygems-update; sudo update_rubygems; sudo gem install bundler`.
1. Bundle install: `cd /opt/ghosty; bundle install`.
1. Generate the upstart configuration: `sudo foreman export runit /etc/sv -a ghosty -l /var/log -u pi`
1. Set your timezone using `sudo dpkg-reconfigure tzdata`.

# Runit control
* Start and stop the daemon using `sudo sv <START|STOP> ghosty-daemon-1`.
* Start and stop the web server using `sudo sv <START|STOP> ghosty-web-1`.
* Monitor daemon output using `tail -f /var/log/daemon-1/current`.
