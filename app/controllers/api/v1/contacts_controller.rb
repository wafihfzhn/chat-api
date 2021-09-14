class Api::V1::ContactsController < ApplicationController
  before_action :authenticate_api_user!

  def index
    contacts = User.where.not(id: current_api_user)

    render json: { data: contacts, status: :success }
  end
end