json.name @team.name
json.leader do |json|
  json.(@team.leader.user, :id, :name)
end
json.patrollers @team.roster_spots do |rs|
  json.(rs.user, :id, :name) unless rs.id == @team.leader.id
end
json.duty_days @team.duty_days, :id, :date

