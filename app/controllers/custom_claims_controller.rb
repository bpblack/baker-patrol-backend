class CustomClaimsController < ApplicationController
  before_action :authenticate_user
  
  def index
    token = params[:token] || request.headers['Authorization'].split.last
    auth_payload = JWT.decode(token, (Knock.token_public_key || Knock.token_secret_signature_key.call), true)
    user = User.includes(:seasons).find(params[:user_id])  
    claims = { 
      exp: auth_payload[0]['exp'],
      aud: auth_payload[0]['aud']
    }
    payload = JSON.parse(
      user.to_json(
        only: [:name], 
        include: [
          {seasons: {only: [:id, :name, :start, :end]}}
        ]
      )
    )
    @custom_claims = JWT.encode(claims.merge(payload), Knock.token_secret_signature_key.call, Knock.token_signature_algorithm)
    render json: { extra: @custom_claims}, status: :created
  end
end
