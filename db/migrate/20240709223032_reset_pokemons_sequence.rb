class ResetPokemonsSequence < ActiveRecord::Migration[7.1]
  def up
    ActiveRecord::Base.connection.reset_pk_sequence!('pokemons')
  end

  def down
  end
end
