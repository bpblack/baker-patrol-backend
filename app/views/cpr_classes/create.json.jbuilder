json.(@class, :id, :students_count, :class_size)
json.time @class.time_str
json.classroom do
  json.id @class.classroom.id
  json.name @class.classroom.name
end