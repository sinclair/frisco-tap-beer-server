require 'sinatra'
require 'open-uri'
require 'hpricot'
require 'json'

URL           = 'http://www.friscogrille.com/cmobile-alt.php'
SITE_ENCODING = "ISO-8859-1"

helpers do

  def read_data()
    doc = read_url(URL)
    extract_beers(doc)
  end

  def read_url(url)
    open(url) { |f| Hpricot(f) }
  end

  def extract_beers(dom)
    (dom/'html/body').search('/div/div').collect do |row|
      size = row.attributes['class']
      beer = (row/'div')
      # /sb/ Site has encoding
      name = beer.first.inner_html.force_encoding(SITE_ENCODING)
      abv  = beer.last.inner_html.force_encoding(SITE_ENCODING)

      {
        name: name,
        abv:  abv,
        size: size
      }
    end
  end

  def build_response(beers, root_name='beers')
    status        =  200
    headers       =  {'Content-Type'=>'application/json'}
    json          =  { beers: beers }.to_json
    response_body =  build_response_body json

    [status, headers, response_body]
  end

  def build_response_body(beers)
    response_body   =   beers
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


get '/' do
  beers  = read_data()
  build_response(beers)
end
