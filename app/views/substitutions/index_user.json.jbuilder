json.requests @requests do |r|
  json.(r, :id, :accepted, :reason, :patrol_id) #date was joined to record
  json.duty_day do |json|
    json.id r.duty_day_id
    json.date r.duty_day_date.strftime('%m/%d/%Y')
  end 
  json.sub do |json|
    if r.sub
      json.sub_id r.sub.id
      json.sub_name r.sub.name
    else 
      json.sub_id nil
      json.sub_name nil
    end
  end
end
json.substitutions @substitutions do |s|
  json.(s, :id, :accepted, :reason, :patrol_id) #date was joined to record
  json.duty_day do |json|
    json.id s.duty_day_id
    json.date s.duty_day_date.strftime('%m/%d/%Y')
    json.team do |json|
      json.id s.team_id
      json.name s.team
    end
  end
  json.responsibility do |json|
    json.id s.pr_id
    json.name s.pr_name
    json.version ''
    json.role s.pr_role
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
end
json.timestamp Time.now.utc.iso8601
