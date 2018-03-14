require 'sinatra'
# require 'sinatra/reloader'
require 'pry'
require 'httparty'
require_relative 'db_config'
require_relative 'models/user'
require_relative 'models/purchase'
require 'uri'

enable :sessions

get '/' do
  erb :index
end

post '/signin' do
  usr = User.find_by(email: params[:email])
  if usr && usr.authenticate(params[:pwd])
    session[:user_id] = @user_id = usr.id
    redirect '/purse'
  else
    return "Error!"
  end
end

get '/signup' do
  erb :signup
end

post '/signup' do
  usr = User.new
  # binding.pry
  usr.usrname = params[:usrname]
  usr.password = params[:pwd]
  usr.email = params[:email]
  usr.currency = params[:currency]
  if usr.save
    redirect '/'
  else
    return 'Error!'
  end
  
end

get '/purse' do
  # validate if budget is maintained
  usr = User.find(session[:user_id])
  usr.est_budget
 
  erb :purse
end

put '/purse' do
  usr = User.find(session[:user_id])
  usr.est_budget = params[:budget]
  if usr.save
    redirect '/purse'
  else
    return "Error!"
  end
end

# Talk to dt about changing this to PUT and DELETE!!
post '/purse/:action' do
  purchase_id = params[:action].split(',')[1]
  purchase = Purchase.find(purchase_id)

  if params[:action].split(',')[0] == 'confirm'
    purchase.is_confirmed = true
    purchase.price = params[:purchase_price]
    
    if purchase.save
      redirect '/purse'
    else
      return 'Error!'
    end
  else
    if purchase.destroy
      redirect '/purse'
    else
      return 'Error!'
    end
  end

end

# post '/save_budget' do
#   usr = User.find(session[:user_id])
#   budget = Budget.new
#   budget.user_id = usr.id
#   budget.fiscal_year = params[:year]
#   budget.est_budget = params[:budget]
#   budget.currency = usr.currency
#   # session[:budget_id] = 
#   if budget.save
#     session[:budget_id] = budget.id
#     redirect '/purse'
#     # redirect "/purse?est_budget=#{params[:budget]}"
#   else
#     return 'Error!'
#   end
# end

get '/add' do
  @boardgames = []
  if params[:game_name]
    game_name = params[:game_name].downcase
    url = "https://bgapi.herokuapp.com/?game=#{game_name}"
    result = HTTParty.get(url)
    result.parsed_response["results"].each do |boardgame|
      boardgame = {
        :id => boardgame["bgg-id"],
        :name => boardgame["primary-name"],
        :thumbnail => boardgame["image"].first,
        :year => boardgame["year-published"],
        :min => boardgame["minimum-players"],
        :max => boardgame["maximum-players"]
      }
      @boardgames << boardgame
    end
  end

  erb :add
end

post '/add/:id' do
  purchase = Purchase.new
  purchase.user_id = session[:user_id]
  purchase.boardgame_id = params[:id].split(',')[0]
  purchase.boardgame_title = params[:id].split(',')[1]
  if purchase.save
    redirect "/purse?id=#{purchase.id}"
  else
    return 'Error!'
  end
end

# get '/add_1' do
#   @boardgames = []
#   if params[:game_name]
#     game_name = URI.encode_www_form_component(params[:game_name].downcase)
#     game_name_search_url = "https://www.boardgamegeek.com/xmlapi/search?search=#{game_name}"

#     game_name_search_results = HTTParty.get(game_name_search_url)

  
#     game_name_search_results.parsed_response["boardgames"]["boardgame"].each do |boardgame|
#       game_id = boardgame["objectid"]
#       url_2 = "https://www.boardgamegeek.com/xmlapi2/thing?id=#{game_id}"
#       res_2 = HTTParty.get(url_2)
#       boardgame = {
#         :id => boardgame["objectid"],
#         :name => res_2.parsed_response["items"]["item"]["name"]["value"],
#         :thumbnail => res_2.parsed_response["items"]["item"]["thumbnail"],
#         :img_url => res_2.parsed_response["items"]["item"]["image"],
#         :year => res_2.parsed_response["items"]["item"]["yearpublished"]["value"],
#         :desc => res_2.parsed_response["items"]["item"]["description"]
#       }
#       @boardgames << boardgame
#     end
#   end
#   erb :add
# end

