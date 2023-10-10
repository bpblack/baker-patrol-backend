json.classrooms @classrooms.each do |c|
  json.(c, :id, :name, :address, :map_link)
end