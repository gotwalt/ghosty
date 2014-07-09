# Ghosty
Ghosty is a ghost for your Sonos system. It wakes up at night and plays scary noises at low volumes on randomly selected speakers. It covers its tracks, and tries not to play so frequently that it becomes predictable. Really, the only way to know for sure that it's responsible for the sound you're hearing is to watch the Sonos controller as it's happening.

Ghosty turns any Sonos-powered home into the haunted house of the future. This is meant to be funny, not mean spirited. Please use it in hilarious, good-natured ways.

## Requirements
* Ruby
* Python (used to serve audio assets)

## Configuration
*./config.yml* is used to configure runtime parameters.

* **port** sets the HTTP port that the daemon will expect files to be served from.
* **valid_hours** controls the hours during which the ghost is active.
* **minimum_frequency** controls how frequently the ghost will appear.

## Running
For normal ghost operations, `foreman start` will start a simple HTTP server to serve files and launch the daemon, which will randomly schedule plays.

## CLI Methods
* `ghosty daemon` - starts the scheduling daemon
* `ghosty trigger` - immediately triggers a single play
* `ghosty cli` - launches an IRB session with classes preloaded

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
