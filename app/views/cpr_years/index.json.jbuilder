json.array! @years do |y|
  json.(y, :id)
  json.year y.year.strftime('%Y')
  json.expired y.expired
end