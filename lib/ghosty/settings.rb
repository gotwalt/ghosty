require 'settingslogic'

module Ghosty
  class Settings < Settingslogic
    source File.expand_path('../../../config.yml', __FILE__)
  end
end
