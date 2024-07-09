module Api
  module V1
    class PokemonController < ApplicationController
      before_action :set_pokemon, only: [:show, :update, :destroy]

      def index
        @pokemon = Pokemon.all
        render json: @pokemon, each_serializer: PokemonSerializer, status: :ok
      end

      def create
        @pokemon = Pokemon.find_or_initialize_by(name: pokemon_params[:name])

        if @pokemon.new_record?
          @pokemon.attributes = pokemon_params.except(:id)

          if @pokemon.save
            render json: { message: "Pokemon created successfully", pokemon: @pokemon }, status: :created
          else
            render json: { error: @pokemon.errors.full_messages }, status: :unprocessable_entity
          end
        else
          render json: { error: "Pokemon with name '#{pokemon_params[:name]}' already exists" }, status: :conflict
        end
      end


      def show
        @pokemon = Pokemon.find_by(id: params[:id])
        if @pokemon
          render json: @pokemon, serializer: PokemonSerializer, status: :ok
        else
          render json: { error: "Pokemon not found" }, status: :not_found
        end
      end

      def update
        if @pokemon.update(pokemon_params)
          render json: @pokemon
        else
          render json: { error: @pokemon.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        if @pokemon.destroy
          render json: { message: "Pokemon deleted successfully"} , status: :ok
        else
          render json: { error: @pokemon.errors.full_messages }, status: :unprocessable_entity
        end
      end

        private

        def set_pokemon
          @pokemon = Pokemon.find_by(id: params[:id])
        end

      def pokemon_params
        params.require(:pokemon).permit(:name, :pokemon_type, :height, :weight, :base_experience)
      end


      # Otros métodos del controlador
    end
  end
end
