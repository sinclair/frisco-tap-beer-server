require 'rubygems'
require 'sinatra'
require 'open-uri'
require 'hpricot'
require 'json'

get '/beers.json' do 
  status      =   200
  headers     =   {'Content-Type'=>'application/json'}
  beer_list   =   []
  body        =   {'beers'=>beer_list}
  key         =   'name'

  url        = 'http://friscogrille.com/beer.php'
  response   = ''
  open(url, "User-Agent" => "Ruby/#{RUBY_VERSION}",
    "From"    => "sinclair.bain@gmail.com",
    "Referer" => "http://www.friscogrille.com/") { |f|
    response = f.read
  }

  collector = []
  doc   =  Hpricot(response)
  (doc/'html/body/div#content/div#beer-list/div#keg-beers/ul/li').each do |e|
    collector << e.inner_html()
  end
  (doc/'html/body/div#content/div#beer-list/div#keg-beers/div/ul/li').each do |e|
    collector << e.inner_html()
  end

  collector.sort {|a, b| a.downcase <=> b.downcase}.each {|e| beer_list << {key=>e.strip()} }
  
  [status, headers, "#{params['callback']}(#{body.to_json()});"]

end
