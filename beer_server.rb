require 'rubygems'
require 'sinatra'
require 'open-uri'
require 'hpricot'
require 'json'

URL_BASE  = 'http://www.friscogrille.com/NewBeerList/'
PATHS     = ['tvlist_left_ie.php', 'tvlist_right_ie.php']

helpers do

  def read_data()
    result_collector  =  []
    PATHS.each do |path|
      doc   =   read_url(URL_BASE+path)
      extract_beers(doc, result_collector)
    end
    result_collector
  end

  def read_url(url)
    open(url) { |f| Hpricot(f) }
  end
  
  def extract_beers(dom, collector=[])
    (dom/'html/body/table').search('//table').each { |e| 
        (e/'td/p').each { |p| collector<<p.inner_html() } }
    collector
  end
  
  def process_data(beer_and_abv_list=[])
    tmp_collector  = []
    
    (beer_and_abv_list.size/2).times {tmp_collector << beer_and_abv_list.shift(2)}
    tmp_collector.collect {|a| {'name'=>a.first, 'abv'=>a.last}}
  end
  
  def build_response(list, root_name='beers')
    status        =   200
    headers       =   {'Content-Type'=>'application/json'}
    response_body =   build_response_body( {root_name=>list}.to_json() )

    [status, headers, response_body]
  end
  
  def build_response_body(json)
    response_body   =   json.to_s()    
    response_body   =   build_json_p_response_body(response_body) if json_p_request?
    response_body
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
puts '---- beers.json'
  data  = read_data()
  beers = process_data(data)
  build_response(beers)
end
