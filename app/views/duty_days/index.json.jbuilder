json.array! @duty_days do |dd| 
  json.(dd, :id)
  json.date dd.date.strftime('%m/%d/%Y')
  json.team do |json|
    json.id dd.team_id
    json.name dd.team_name
  end
end