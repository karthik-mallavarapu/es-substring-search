require 'faker'
require 'yaml'
require 'date'

output_yml = File.open('purchases.yml', 'a')
500000.times do |t|
  product = {}
  product['name'] = Faker::Commerce.product_name
  product['department'] = Faker::Commerce.department
  product['price'] = Faker::Commerce.price
  product['user_email'] = Faker::Internet.free_email
  product['purchase_date'] = Faker::Date.between(Date.today - 30, Date.today).strftime("%Y-%m-%d")
  output_yml.write(product.to_yaml)
end
output_yml.close
