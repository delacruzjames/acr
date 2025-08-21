class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :code
      t.string :name
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0

      t.timestamps
    end
    add_index :products, :code, unique: true
  end
end
