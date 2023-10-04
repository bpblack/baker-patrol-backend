Rails.configuration.after_initialize do
  ior = User.joins(:roles).where(roles: {name: :cprior})[0]
  Rails.application.config.cpr_ior = {
    name: ior.name,
    email: ior.email
  }
end