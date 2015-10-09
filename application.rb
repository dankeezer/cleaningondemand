require "rubygems"
require "bundler/setup"
require "sinatra"
require File.join(File.dirname(__FILE__), "environment")

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
  set :show_exceptions, :after_handler
end

configure :production, :development do
  enable :logging
end

helpers do
  # add your helpers here
end

# root page
get "/" do
  erb :root
end


post '/' do 
  configure_pony
  name = params[:name]
  sender_email = params[:email]
  message = params[:message]
  logger.error params.inspect
  begin
    Pony.mail(
      :from => "#{name}<#{sender_email}>",
      :to => 'dankeezer@gmail.com',
      :subject =>"#{name} has contacted you from cleaningondemand.com",
      :body => "#{message}",
    )
    redirect '/success'
  rescue
    @exception = $!
    erb :boom
  end
end

def configure_pony
  Pony.options = {
    :via => :smtp,
    :via_options => { 
      :address              => 'smtp.sendgrid.net', 
      :port                 => '587',  
      :user_name            => ENV['SENDGRID_USERNAME'], 
      :password             => ENV['SENDGRID_PASSWORD'], 
      :authentication       => :plain, 
      :enable_starttls_auto => true,
      :domain               => 'heroku.com'
    }    
  }
end