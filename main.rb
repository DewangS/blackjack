require 'rubygems'
require 'sinatra'
require 'shotgun'

enable :sessions
set :session_secret, 'bond007'



get '/form' do
  erb :user
end

post '/userName' do 
  redirect :bet
end

get '/bet' do 
 erb :bet
end

post '/getBetAmount' do
  "You are betting for $#{params['bet_amount']}" 
end