json.name @team.name
if @team.leader.nil?
  json.leader nil
else
  json.leader do |json|
    json.(@team.leader.user, :id, :name)
  end
end
json.patrollers @team.roster_spots do |rs|
  json.(rs.user, :id, :name) unless @team.leader && rs.id == @team.leader.id
end
json.duty_days @team.duty_days, :id, :date

