json.sub_history @patrol_with_subs.substitutions do |s|
  json.(s, :id, :reason, :accepted)
  json.subbed do
   json.(s.user, :id, :name)
  end
  json.sub do
    if s.sub
      json.id s.sub.id
      json.name s.sub.name
    else 
      json.id nil
      json.name ''
    end
  end
end
