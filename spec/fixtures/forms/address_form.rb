class AddressForm < Rectify::Form
  attribute :street,    String
  attribute :town,      String
  attribute :city,      String
  attribute :post_code, String
end
