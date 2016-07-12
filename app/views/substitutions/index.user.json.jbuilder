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
  json.(s, :id, :date, :accepted, :reason) #date was joined to record
  json.sub_for_id s.user.id
  json.sub_for_name s.user.name
end
