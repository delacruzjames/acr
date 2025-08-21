SEED_PRODUCTS = [
  { code: "GR1", name: "Green Tea",    price: 3.11 },
  { code: "SR1", name: "Strawberries", price: 5.00 },
  { code: "CF1", name: "Coffee",       price: 11.23 }
]

SEED_PRODUCTS.each do |attrs|
  prod = Product.find_or_initialize_by(code: attrs[:code])
  prod.assign_attributes(name: attrs[:name], price: attrs[:price])
  prod.save!
end

puts "Seeded #{Product.count} products."
