require 'rubygems'
require 'sinatra'
require 'shotgun'
require 'pry'

set :sessions, true
#set :session_secret, 'bond007'
helpers do  
      def calculate_total(cards)
        total=0
        arr = cards.map{|element| element[1]}
        arr.each do  |a| 
          if a == 'A'
            total += 11
          else
            total += a.to_i == 0? 10 : a.to_i
          end
        end

        arr.select{|element| element == 'A'}.count.times do
          break if total <= 21
          total -= 10
        end
        total
      end
      def card_image(card)
        suit = case card[0]
          when 'H' then 'hearts'
          when 'D' then 'diamonds'
          when 'C' then 'clubs'
          when 'S' then 'spades'  
        end

        value = card[1]
        if ['J', 'Q', 'K', 'A'].include?(value)
          value = case card[1] 
            when 'J' then 'jack'
            when 'Q' then 'queen'
            when 'K' then 'king'
            when 'A' then 'ace'  
          end
        end

        "<img src='/images/cards/#{suit}_#{value}.jpg' class='card_image'"
      end
end

before do
  @show_hit_or_stay_buttons = true
end

get '/' do
  if params['player_name']
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/new_player' do
  erb :new_player
end

post '/new_player' do
  session[:player_name] = params[:player_name] 
  redirect '/bet'
end

get '/bet' do 
 erb :bet
 #redirect '/game'
end

post '/bet' do
  "#{session[:player_name]} You are betting for $#{params['bet_amount']}" 
  redirect '/game'
end

get '/game' do
  #create deck and put in a session
  suits = ['H','D','C','S']
  values = ['2','3','4','5','6','7','8','9','10','J','Q','K','A']
  session[:deck] = suits.product(values).shuffle!

  # deal cards
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop 
  
  erb :game
end

post '/game' do

  if params[:player_choice] == 'hit'
      redirect '/hit'
    elsif params[:player_choice] == 'stay'
      redirect '/stay'
    end
end

post '/game/player/hit' do 
  session[:player_cards] << session[:deck].pop
  if calculate_total(session[:player_cards]) > 21
      @error = "Sorry, looks like you've busted"
      @show_hit_or_stay_buttons = false
  end
  erb :game
end

post '/game/player/stay' do
  @success = "You have chosen to stay."
  @show_hit_or_stay_buttons = false
  erb :game
end