json.requests @requests do |r|
  json.(r, :id, :accepted, :reason) #date was joined to record
  json.patrol_id r.patrol_id
  json.duty_day do |json|
    json.id r.patrol.duty_day.id
    json.date r.patrol.duty_day.date
  end  
  if r.sub
    json.sub_id r.sub.id
    json.sub_name r.sub.name
  else 
    json.sub_id nil
    json.sub_name nil
  end
end
json.substitutions @substitutions do |s|
  json.(s, :id, :accepted, :reason) #date was joined to record
  json.patrol_id s.patrol_id
  json.duty_day do |json|
    json.id s.patrol.duty_day.id
    json.date s.patrol.duty_day.date
    json.team do |json|
      json.id s.patrol.duty_day.team.id
      json.name s.patrol.duty_day.team.name
    end
  end
  json.sub_for do |json|
    if s.user.nil?
      json.id nil
      json.name 'Not Assigned'
    else 
      json.id s.user.id
      json.name s.user.name
    end
  end
  json.responsibility do |json|
    json.name s.patrol.patrol_responsibility.name
    json.version s.patrol.patrol_responsibility.version
  end      
end
json.timestamp Time.now.utc.iso8601
