module TripDestinations
  extend ActiveSupport::Concern

  # check state/country results
  # http://api.wunderground.com/api/37f2fcd1fbfbe9b0/conditions/q/AT.json

  # API call
  # p_depart = t.depart_at.strftime('%m%d')
  # p_return = t.return_at.strftime('%m%d')
  # s = Trip::DESTINATION_NAME_MAPPING[:BZE][:weather_lookup]
  # http://api.wunderground.com/api/#{Trip::WEATHER_API_KEY}/planner_#{p_depart}#{p_return}/q/#{destination}.json

  # upload image to s3:
  # aws s3 cp app/assets/images/XXX.jpg s3://getoutofnyc/XXX.jpg --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers --profile chhhris

  DESTINATION_NAME_MAPPING = {
    ANU: { name: 'Antigua', weather_lookup: 'AT' },
    BGI: { name: 'Barbados', weather_lookup: 'BGI' },
    BZE: { name: 'Belize', weather_lookup: 'BZE' },
    CUN: { name: 'Tulum', weather_lookup: 'QR/Cancun_International' },
    MGA: { name: 'Nicaragua', weather_lookup: 'NI/Bluefields' },
    STT: { name: 'Saint Thomas', weather_lookup: 'STT' },
    POS: { name: 'Port of Spain', weather_lookup: 'TT/Piarco' },
    PTP: { name: 'Guadalupe', weather_lookup: 'PTP' },
    PSE: { name: 'Ponce, Puerto Rico', weather_lookup: 'PSE' },
    PLS: { name: 'Turks and Caicos', weather_lookup: 'PLS' },
    SDQ: { name: 'Santo Domingo, Dominican Republic', weather_lookup: 'SDQ' },
    AUA: { name: 'Aruba', weather_lookup: 'AW/AUA' },
    PUJ: { name: 'Punta Cana', weather_lookup: 'PUJ' },
    SXM: { name: 'Sint Maarten', weather_lookup: 'SXM' },
    ECP: { name: 'Panama City', weather_lookup: 'ECP' }
  }
end

# aws s3 cp app/assets/images/sxm.jpg s3://getoutofnyc/sxm.jpg --grants read=uri=http://acs.amazonaws.com/groups/global/AllUsers --profile chhhris