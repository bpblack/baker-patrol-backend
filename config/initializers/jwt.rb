
Rails.application.config.jwt = { 
  signature_algorithm: 'HS512',
  lifetime: 1.hour
}
