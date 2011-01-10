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

  def extract_beer_list(site_html)
    beer_collector  =   []
    doc             =   Hpricot(site_html)

    extract_beers(doc, 'html/body/div#content/div#beer-list/div#keg-beers/ul/li',     beer_collector)
    extract_beers(doc, 'html/body/div#content/div#beer-list/div#keg-beers/div/ul/li', beer_collector)

    process_beer_list(beer_collector)
  end

  def extract_beers(dom, selector, collector)
    (dom/selector).each do |e|
      collector << e.inner_html()
    end
  end
  
  def process_beer_list(enumerable)
    key             =   'name'
    enumerable.
        uniq.
        sort {|a, b| a.downcase <=> b.downcase}.collect {|e| {key=>e.strip()} }
  end
  
  def build_response(beer_list)
    status        =   200
    headers       =   {'Content-Type'=>'application/json'}
    response_body =   build_response_body( {'beers'=>beer_list} )

    [status, headers, response_body]
  end
  
  def build_response_body(beer_list_hash)
    content   =   beer_list_hash.to_json().to_s()    
    content   =   build_json_p_response_body(content) if json_p_request?
    content
  end
  
  def json_p_request?
    callback_param() != nil
  end

  def build_json_p_response_body(content_string)
    "#{callback_param()}(#{content_string});"
  end

  def callback_param()
    params['callback']
  end

end


get '/beers.json' do 
  response    =   scrape_frisco_site()
  beer_list   =   extract_beer_list(response)
  build_response(beer_list)
end
