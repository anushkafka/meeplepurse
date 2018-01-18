require 'sinatra'
require 'sinatra/reloader'
require 'pry'
require 'pg'
require 'httparty'
require_relative 'db_config'
require_relative 'models/user'
require_relative 'models/boardgame'
require_relative 'models/budget'
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

get '/purse' do
  # validate budget header
  @budget = Budget.where(user_id: session[:user_id])

  # -----------------------
  @bg_list
  @is_bg_maintained = false
  # validate game list
  # usr = User.find(session[:user_id])
  # @bg_list = Boardgame.where(user_id: usr.id)
 
  # if @bg_list.nil?
  #   @is_bg_maintained = false
  # else
  #   @is_bg_maintained = true
  # end
  # -----------------
  
  erb :purse
end

get '/signup' do
  erb :signup
end

post '/signup' do
  usr = User.new
  binding.pry
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

post '/save_budget' do
  usr = User.find(session[:user_id])
  budget = Budget.new
  budget.user_id = usr.id
  budget.fiscal_year = params[:year]
  budget.est_budget = params[:budget]
  budget.currency = usr.currency
  # session[:budget_id] = 
  if budget.save
    session[:budget_id] = budget.id
    redirect '/purse'
    # redirect "/purse?est_budget=#{params[:budget]}"
  else
    return 'Error!'
  end
end

post '/update_budget' do
  act_budget = act_budget - params[:new_price]
  # sql = 'UPDATE budget SET act_budget = 'Adam B.', birth_year = 1986 WHERE name = 'Adam Bray';'
  redirect '/purse'
end

post '/add_game' do
  sql = "INSERT INTO boardgames (user_id,budget_id,bg_name,currency,price) 
  values (#{user_id},#{budget_id},#{params[:new_bg]},#{params[:new_curr]},#{params[:new_price]});"

  conn = PG.connect(dbname: 'meeplepurse')
  res = conn.exec(sql)
  conn.close
  redirect '/update_budget'
end

get '/add' do
  @boardgames = []
  if params[:game_name]
    game_name = params[:game_name].downcase
    url = "http://localhost:3000/?game=#{game_name}"
    result = HTTParty.get(url)
    result.parsed_response["results"].each do |boardgame|
      boardgame = {
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

get '/add_1' do
  @boardgames = []
  if params[:game_name]
    game_name = URI.encode_www_form_component(params[:game_name].downcase)
    game_name_search_url = "https://www.boardgamegeek.com/xmlapi/search?search=#{game_name}"

    game_name_search_results = HTTParty.get(game_name_search_url)

  
    game_name_search_results.parsed_response["boardgames"]["boardgame"].each do |boardgame|
      game_id = boardgame["objectid"]
      url_2 = "https://www.boardgamegeek.com/xmlapi2/thing?id=#{game_id}"
      res_2 = HTTParty.get(url_2)
      boardgame = {
        :id => boardgame["objectid"],
        :name => res_2.parsed_response["items"]["item"]["name"]["value"],
        :thumbnail => res_2.parsed_response["items"]["item"]["thumbnail"],
        :img_url => res_2.parsed_response["items"]["item"]["image"],
        :year => res_2.parsed_response["items"]["item"]["yearpublished"]["value"],
        :desc => res_2.parsed_response["items"]["item"]["description"]
      }
      @boardgames << boardgame
    end
  end
  erb :add
end

get '/test' do
  erb :test
end

put '/user/:id' do
  
end