# Installation on a Raspberry Pi

1. Use raspbian, the Debian build for the board.
1. Install the following packages: `sudo apt-get install ruby-dev upstart`.
1. Clone and chown the repo: `cd /opt; sudo git clone https://github.com/gotwalt/ghosty.md; sudo chown -R pi /opt/ghosty`.
1. Disable ruby documentation to make install faster: `sudo echo gem: --no-rdoc --no-ri > /etc/gemrc`.
1. Update rubygems & bundler: `sudo gem install rubygems-update; sudo update_rubygems; sudo gem install bundler`.
1. Bundle install: `cd /opt/ghosty; bundle install`.
