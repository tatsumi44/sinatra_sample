require 'sinatra'
require 'sinatra/reloader'
require 'open-uri'
require 'json'
require 'net/http'
require 'sinatra/activerecord'
require './models'
get '/' do
  p History.all
  if History.all != nil
  @historys = History.all.limit(10).order("created_at desc")
  @favorites = History.where(favorite: true)
    # p History.all
    erb :form
  end
end

post '/list' do
  uri = URI('http://express.heartrails.com/api/json')
  p params[:x]
  p params[:y]
  History.create!(x: params[:x], y: params[:y])
  uri.query = URI.encode_www_form({
                                      method: "getStations",
                                      x: params[:x],
                                      y: params[:y]
                                  })
  res = Net::HTTP.get_response(uri)
  json = JSON.parse(res.body)
  @stations = json["response"]["station"]
  p @stations
  erb :list
end
post "/api" do
  "hello"
  uri = URI("http://express.heartrails.com/api/json")
  uri.query = URI.encode_www_form({

                                      method: "getStations",
                                      line: params[:line],
                                      name: params[:name]
                                  })

  res = Net::HTTP.get_response(uri)
  json = JSON.parse(res.body)
  response = {
      next: json["response"]["station"][0]["next"]
  }
  JSON response
end

post '/:id/delete' do
  history = History.find(params[:id])
  history.delete
  redirect '/'
end

post '/:id/update' do
  history = History.find(params[:id])
  history.favorite = !history.favorite
  history.save
  redirect "/"
end
