json.sub_history @patrol_with_subs.substitutions.each_with_index.to_a do |s, i|
  json.(s, :id, :reason, :accepted)
  json.subbed do
    if (s.user.nil?) 
      json.id nil
      json.name 'Not Assigned'
      json.phone 'N/A'
      json.skills 'N/A'
    else
      json.(s.user, :id, :name)
      if (i == 0)
        json.phone s.user.phone
        json.skills s.user.season_roster_spot(@patrol_with_subs.duty_day.season_id).team_all_roles_string
      end
    end
  end
  json.sub do
    if s.sub
      json.id s.sub.id
      json.name s.sub.name
      if (i == 0)
        json.phone s.sub.phone
        json.skills s.sub.season_roster_spot(@patrol_with_subs.duty_day.season_id).team_all_roles_string
      end
    else 
      json.id nil
      json.name ''
    end
  end
end
