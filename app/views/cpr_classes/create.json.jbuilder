json.(@class, :id, :students_count, :class_size)
json.time @class.time_str
json.location @class.classroom.name