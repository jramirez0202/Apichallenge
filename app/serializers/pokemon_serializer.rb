class PokemonSerializer < ActiveModel::Serializer
  attributes  :name, :pokemon_type, :height, :weight, :base_experience
end
