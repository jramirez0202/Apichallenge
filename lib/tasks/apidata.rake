require 'httparty'
require 'json'
require 'concurrent-ruby'
require 'redis'

namespace :apidata do
  desc "Get API data from the API and save to the database"

  task get_api_data: :environment do
    puts "Getting API data"

    BASE_URL = 'https://pokeapi.co/api/v2'
    POKEMON_LIST_URL = "#{BASE_URL}/pokemon?limit=151&offset=0"

    response = HTTParty.get(POKEMON_LIST_URL)

    if response.code == 200
      puts "Data fetched successfully."
      pokemons = JSON.parse(response.body)['results']

      # Procesa las solicitudes en lotes para no saturar el pool de conexiones
      pokemons.each_slice(10) do |pokemon_batch|
        promises = pokemon_batch.map do |pokemon|
          Concurrent::Promises.future do
            fetch_and_cache_pokemon_data(pokemon['url'])
          end
        end

        # Espera a que se completen todas las promesas del lote antes de continuar
        Concurrent::Promises.zip(*promises).value!
      end

      save_cached_data_to_db

      puts "Data fetching task completed."
    else
      puts "Error fetching data: #{response.code} #{response.message}"
    end
  end

  def fetch_and_cache_pokemon_data(url)
    pokemon_response = HTTParty.get(url)

    if pokemon_response.code == 200
      pokemon_data = JSON.parse(pokemon_response.body)
      pokemon_id = pokemon_data['id']
      pokemon_name = pokemon_data['name']
      pokemon_weight = pokemon_data['weight']
      pokemon_height = pokemon_data['height']
      pokemon_base_experience = pokemon_data['base_experience']
      pokemon_types = pokemon_data['types'].map { |type| type['type']['name'] }.join(', ')

      # Guardar en Redis
      $redis.set(pokemon_id, {
        id: pokemon_id,
        name: pokemon_name,
        weight: pokemon_weight,
        height: pokemon_height,
        base_experience: pokemon_base_experience,
        pokemon_type: pokemon_types
      }.to_json)

      puts "Cached Pokemon: #{pokemon_name}"
    else
      puts "Error fetching data for #{url}: #{pokemon_response.code} #{pokemon_response.message}"
    end
  rescue => e
    puts "Exception occurred while processing #{url}: #{e.message}"
  end

  def save_cached_data_to_db
    keys = $redis.keys

    keys.each do |key|
      pokemon_data = JSON.parse($redis.get(key))

      unless Pokemon.exists?(id: pokemon_data['id'])
        Pokemon.create(
          id: pokemon_data['id'],
          name: pokemon_data['name'],
          weight: pokemon_data['weight'],
          height: pokemon_data['height'],
          base_experience: pokemon_data['base_experience'],
          pokemon_type: pokemon_data['pokemon_type']
        )

        puts "Saved Pokemon to DB: #{pokemon_data['name']}"
      else
        puts "Pokemon #{pokemon_data['name']} already exists in DB."
      end
    end
  end
end
