if @latest
  json.(@latest, :id)
  json.year @latest.year.strftime('%Y')
  json.expired @latest.expired
end