class CreatePokemons < ActiveRecord::Migration[6.0]
  def change
    create_table :pokemons do |t|
      t.string :name
      t.integer :weight
      t.integer :height
      t.integer :base_experience
      t.string :pokemon_type

      t.timestamps
    end

    add_index :pokemons, :name, unique: true
  end
end
