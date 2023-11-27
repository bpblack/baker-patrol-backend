json.open_subs @cansub do |o|
  json.(o, :duty_day_id, :team, :responsibility)
  #json.team o.patrol.team.name
  json.date o.date.strftime('%m/%d/%Y')
  json.name o.user.name
  json.email o.user.email
end