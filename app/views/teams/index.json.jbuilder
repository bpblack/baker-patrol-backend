json.roster @teams.each do |team|
  json.name team.name
  json.members team.sorted_members do |rs|
    json.name rs.user.name
    json.email rs.user.email
    json.phone rs.user.phone
    json.roles "#{rs.team_roles_string}, #{rs.team_roles_extra_string}"
  end 
end