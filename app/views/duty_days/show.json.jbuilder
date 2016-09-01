json.(@duty_day, :season_id, :date)
json.team do |json|
  json.(@duty_day.team, :id, :name)
end
json.patrols @duty_day.patrols.sort_by { |p| p.patrol_responsibility.name }.rotate(@duty_day.patrols.size - 1) do |p|
  json.(p, :id)
  json.patroller do |json|
    json.(p.user, :id, :name)
  end
  json.responsibility do |json|
    json.(p.patrol_responsibility, :id, :name, :version)
  end
  if p.substitutions.exists?
    json.has_substitutions true
    json.has_pending_substitutions p.substitutions.where(accepted: false).exists?
  else
    json.has_subsubstitutions false
    json.has_pending_substitutions false
   end
end
