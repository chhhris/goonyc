module TripDestinations
  extend ActiveSupport::Concern

  DESTINATION_NAME_MAPPING = {
    ANU: { name: 'Antigua', weather_lookup: 'AT' },
    CUN: { name: 'Tulum', weather_lookup: 'QR/Cancun_International' },
    STT: { name: 'Saint Thomas', weather_lookup: 'STT' },
    POS: { name: 'Port of Spain', weather_lookup: 'TT/Piarco' }
  }
end