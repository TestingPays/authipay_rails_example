require 'nokogiri'

class SaleController < ApplicationController
  before_action :set_sale, only: [:create]

  include Sale

  def create
    @response = new_request(@sale)
    @pp = Nokogiri::XML(@response.body)
  end

private

  def set_sale
    @sale = ActionController::Parameters.new({
      card_number: params["card_number"],
      expiry_month: params["expiry_month"],
      expiry_year: params["expiry_year"],
      card_code: params["card_code"],
      charge_total: params["charge_total"],
    })
  end
end
