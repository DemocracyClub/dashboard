require 'open-uri'
require 'json'

def get_el_data
  url = "https://electionleaflets.org/api/stats?format=json"
  JSON.parse(open(url).read)
end

def get_cvs_count
  url = "http://cv.democracyclub.org.uk/cvs.json"
  x = JSON.parse(open(url).read).length
end


def update_all
  # Election Leaflets
  el_data = get_el_data
  send_event('total_leaflets', { current: el_data['leaflets']['total']})
  send_event('leaflets_24_hours', { current: el_data['leaflets']['last_24_hours']})

  # CVs
  csv_count = get_cvs_count
  send_event('total_cvs', { current: csv_count })
end

update_all

SCHEDULER.every '30m' do
  update_all
end

