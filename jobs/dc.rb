require 'open-uri'
require 'json'

def get_el_data
  url = "https://electionleaflets.org/api/stats?format=json"
  JSON.parse(open(url).read)
end

def get_cvs_count
  url = "http://cv.democracyclub.org.uk/cvs.json"
  JSON.parse(open(url).read).length
end

def get_meet_count
  url = "http://meetyournextmp.com/numbers.json"
  JSON.parse(open(url).read)
end

def get_ynmp_counts
  url = "https://yournextmp.com/numbers/?format=json"
  JSON.parse(open(url).read)
end

def get_mentions_counts
  begin
      url = "https://www.electionmentions.com/statistics.json"
      res = JSON.parse(open(url).read)
    rescue
      res = {}
  end
  res
end


def update_all
  # Election Leaflets
  el_data = get_el_data
  send_event('total_leaflets', { current: el_data['leaflets']['total']})
  send_event('leaflets_24_hours', { current: el_data['leaflets']['last_24_hours']})

  # CVs
  csv_count = get_cvs_count
  send_event('total_cvs', { current: csv_count })

  # Meet
  meet_count = get_meet_count
  send_event('total_meet_events', { current: meet_count['countEventsTotal'] })
  send_event('meet_events_remaining', { current: meet_count['countEventsAfterNow'] })

  # YNMP
  ynmp_counts = get_ynmp_counts
  send_event('total_2015_candidates', { current: ynmp_counts['candidates_2015'] })

  # Mentions
  mentions_counts = get_mentions_counts
  if not mentions_counts.empty?
    send_event('mentions_total', { current: mentions_counts['candidates']['total_mentions'] })
    send_event('last_week_mentions', { current: mentions_counts['candidates']['last_week_mentions'] })
  end
end

update_all

SCHEDULER.every '30m' do
  update_all
end

