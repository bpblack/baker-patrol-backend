json.patrols @patrols do |p|
  json.id p.id
  if p.duty_day.date < Date.today
    json.swappable false
  else 
    json.swappable true
  end
  json.duty_day do |json|
    json.(p.duty_day, :id, :season_id, :date)
    json.team do |json|
      json.(p.duty_day.team, :id, :name)
    end
  end
  json.responsibility do |json|
    json.(p.patrol_responsibility, :id, :name, :version)
  end
end
