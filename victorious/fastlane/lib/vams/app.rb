module VAMS
  class App < OpenStruct
    module STATE
      ON_DECK = 'on_deck'
    end

    def sanitized_bundle_id
      bundle_id.gsub(/\$\{.*\}/, '') if bundle_id
    end
  end
end
