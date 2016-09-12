json.(@duty_day, :season_id, :date)
json.swapable @duty_day.date >= Date.current
json.team do |json|
  json.(@duty_day.team, :id, :name)
end
json.patrols @duty_day.patrols.sort_by { |p| p.patrol_responsibility.name }.rotate(@duty_day.patrols.size - 1) do |p|
  json.(p, :id)
  json.patroller do |json|
    json.(p.user, :id, :name)
    json.(p.user, :phone) if @isAdmin
  end
  json.responsibility do |json|
    json.(p.patrol_responsibility, :id, :name, :version)
  end
  if @isAdmin
    if p.latest_substitution.nil? 
      json.latest_substitution nil
    else
      json.latest_substitution do |json|
        json.(p.latest_substitution, :accepted, :sub_id)
      end
    end
  end
end
