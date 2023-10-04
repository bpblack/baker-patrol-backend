json.name @team.name
if @leader.nil?
  json.leader nil
else
  json.leader do |json|
    json.(@leader.user, :id, :name)
  end
end
json.patrollers @team.sorted_members do |rs|
  json.(rs.user, :id, :name) unless @leader && rs.id == @leader.id
end
json.duty_days @duty_days do |d|
  json.(d, :id)
  json.date d.date.strftime('%m/%d/%Y')
end

