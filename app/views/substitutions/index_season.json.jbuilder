json.open_subs @cansub do |o|
  json.(o, :duty_day_id, :date, :team, :responsibility)
  #json.team o.patrol.team.name
  json.name o.user.name
  json.email o.user.email
end