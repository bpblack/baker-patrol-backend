json.(@duty_day, :season_id, :date)
json.swapable @duty_day.date >= Date.current
json.team do |json|
  json.(@duty_day.team, :id, :name)
end
json.patrols @sorted_patrols do |p|
  json.(p, :id)
  json.patroller do |json|
    if(p.user.nil?)
      json.id nil
      json.name 'Not Assigned'
      json.skills 'N/A'
      json.phone 'N/A' if @isAdmin
      json.email nil if @isAdmin
    else
      json.(p.user, :id, :name)
      if p.user.season_roster_spot(@duty_day.season_id).nil?
        json.skills ''
      else 
        json.skills p.user.season_roster_spot(@duty_day.season_id).team_all_roles_string
      end
      json.(p.user, :phone) if @isAdmin
      json.(p.user, :email) if @isAdmin
    end
  end
  json.responsibility do |json|
    json.(p.patrol_responsibility, :id, :name, :version)
    if (@isAdmin) 
      json.role p.patrol_responsibility.role.name.to_sym
    end
  end
  if @isAdmin
    if p.latest_substitution.nil? 
      json.latest_substitution nil
    else
      json.latest_substitution do |json|
        json.(p.latest_substitution, :id, :accepted, :sub_id)
      end
    end
  end
end
