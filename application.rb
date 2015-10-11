require "rubygems"
require "bundler/setup"
require "sinatra"
require 'pony'
require 'dotenv'
Dotenv.load

require File.join(File.dirname(__FILE__), "environment")

configure do
  set :views, "#{File.dirname(__FILE__)}/views"
  # set :show_exceptions, :after_handler
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

get "/success" do
  erb :"success.js"
end

get "/error" do
  erb :error
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
      :to => ENV['CONTACT_EMAIL'],
      :subject =>"New message from #{name} via cleaningondemand.com",
      :body => "#{message}",
    )
    redirect "/"
  rescue
    @exception = $!
    erb :error
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