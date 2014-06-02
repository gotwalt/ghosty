require 'sonos'

class Sonos::Device::Speaker
  def playing?
    state = get_player_state[:state]
    !['PAUSED_PLAYBACK', 'STOPPED'].include?(state)
  end
end

module Sonos::Endpoint::AVTransport
  def select_track(index)
    parse_response send_transport_message('Seek', "<Unit>TRACK_NR</Unit><Target>#{index}</Target>")
  end
end
