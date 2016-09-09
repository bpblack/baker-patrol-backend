json.patrols @patrols do |p|
  json.id p.id
  if p.duty_day.date < Date.today
    json.swappable false
  else 
    json.swappable true
  end
  if !p.latest_substitution.nil? && !p.latest_substitution.accepted
    json.pending_substitution do |json|
      json.(p.latest_substitution, :id, :sub_id)
      if p.latest_substitution.sub_id.nil?
        json.sub_name nil
      else 
        json.sub_name p.latest_substitution.sub.name
      end
    end
  else 
    json.pending_substitution nil
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
