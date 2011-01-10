require 'rubygems'
require 'sinatra'
require 'open-uri'
require 'hpricot'
require 'json'

helpers do

  def scrape_frisco_site()
    url        = 'http://friscogrille.com/beer.php'
    response   = ''
    open(url, "User-Agent" => "Ruby/#{RUBY_VERSION}",
      "From"    => "sinclair.bain@gmail.com",
      "Referer" => "http://www.friscogrille.com/") { |f| response = f.read }
    response
  end

  def build_beer_list(site_html)
    beer_collector  =   []
    doc             =   Hpricot(site_html)
    
    (doc/'html/body/div#content/div#beer-list/div#keg-beers/ul/li').each do |e|
      beer_collector << e.inner_html()
    end
    (doc/'html/body/div#content/div#beer-list/div#keg-beers/div/ul/li').each do |e|
      beer_collector << e.inner_html()
    end

    format_beer_list(beer_collector)
  end

  def format_beer_list(enumerable)
    key             =   'name'
    enumerable.
        uniq.
        sort {|a, b| a.downcase <=> b.downcase}.collect {|e| {key=>e.strip()} }
  end
  
  def build_response(beer_list)
    status      =   200
    headers     =   {'Content-Type'=>'application/json'}
    body        =   {'beers'=>beer_list}

    [status, headers, "#{params['callback']}(#{body.to_json()});"]
  end
  
end

get '/beers.json' do 
  response    = scrape_frisco_site()
  beer_list   = build_beer_list(response)
  build_response(beer_list)
end
