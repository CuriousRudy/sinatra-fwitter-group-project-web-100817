require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "fwitter_secret"
  end

  helpers do
  def logged_in?
    session[:user_id]
  end

  def current_user
    User.find(session[:user_id])
  end
end

  get '/' do #home page
    if logged_in?
      id = session[:user_id]
      redirect "/users/#{id}"
    else
      erb :index
    end
  end

  get '/users' do
    erb :users
  end

  get '/users/signup' do #get the form for a new user
    erb :'users/signup'
  end

  post '/users/signup' do #submit the form for new users, direct to users page
    if User.find_by(:username => params[:username]) == nil
      @user = User.create(
        :username => params[:username],
        :email => params[:email],
        :password => params[:password])
        session[:user_id] = @user.id
        erb :'users/show'
    else
        "This username is taken, go back to try again"
    end
  end

  get '/users/login' do #get the user login form
    erb :'users/login'
  end

  post '/users/login' do #submit the login form and redirect to the user page
    @user = User.find_by(:username => params[:username], :password => params[:password])
    if @user != nil
      session[:user_id] = @user.id
      redirect :'/'
    else
      redirect '/users/new'
    end
  end

  get '/users/:id' do #navigate to the user's page
    if User.find(params[:id])
      @user = User.find(params[:id])
      erb :'/users/show'
    else
      erb :index
    end
  end


  get '/tweets/new' do #get the form for post tweets
    if session[:user_id]
      erb :'tweets/create_tweet'
    else
      redirect 'users/login'
    end
  end

  post '/tweets/new' do #post the new tweet, direct to the tweet's view
    @tweet = Tweet.new(:content => params[:content])
    @tweet.user_id = session[:user_id]
    @tweet.save
    # binding.pry
    erb :'tweets/show_tweet'
  end

  get '/tweets/:id' do #the view for an individual tweet
    @tweet = Tweet.find(params[:id])
    erb :'tweets/show_tweet'
  end

  get '/logout' do #logs out the the user
    session.destroy
    redirect '/'
  end



end
