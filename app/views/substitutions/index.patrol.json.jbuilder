json.date @patrol_with_subs.duty_day.date
json.patrol_responsibility @patrol_with_subs.patrol_responsibility.name
json.sub_history @patrol_with_subs.substitutions do |s|
  json.(s, :id, :accepted)
  json.subbed do
   json.(s.user, :id, :name)
  end
  json.sub do
    if s.sub
      json.sub_id s.sub.id
      json.sub_name s.sub.name
    else 
      json.sub_id -1
      json.sub_name ''
    end
  end
end
