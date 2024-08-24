json.roster @teams.each do |team|
  json.id team.id
  json.name team.name
  json.members team.sorted_members do |rs|
    json.id rs.user.id
    json.name rs.user.name
    json.email rs.user.email
    json.phone rs.user.phone
    json.roles rs.team_all_roles_string
  end 
end
