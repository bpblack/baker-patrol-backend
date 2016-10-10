json.requests @requests do |r|
  json.(r, :id, :date, :accepted, :reason) #date was joined to record
  if r.sub
    json.sub_id r.sub.id
    json.sub_name r.sub.name
  else 
    json.sub_id -1
    json.sub_name ''
  end
end
json.substitutions @substitutions do |s|
  json.(s, :id, :accepted, :reason) #date was joined to record
  json.duty_day do |json|
    json.id s.duty_day_id
    json.date s.date
  end
  json.sub_for do |json|
    json.id s.user.id
    json.name s.user.name
  end
  json.responsibility do |json|
    json.name s.patrol.patrol_responsibility.name
    json.version s.patrol.patrol_responsibility.version
  end      
end
json.timestamp Time.now.utc.iso8601
