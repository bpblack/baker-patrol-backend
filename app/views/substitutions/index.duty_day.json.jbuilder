json.substitutions @substitutions do |s|
  json.(s, :id, :accepted) #date was joined to record
  json.patrol_id s.patrol_id
  json.sub do |json|
    json.id s.sub.id
    json.name s.sub.name
  end
end
json.timestamp Time.now.utc.iso8601

