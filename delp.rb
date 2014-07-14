require 'rubygems'
require 'sinatra'
require 'yelp'

configure do
#  enable :sessions
	set :bind, "162.243.137.224"
	set :port, "9393"
	set :root, "/home/dchoi/projects/delp/"
	set :logging, true
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

=begin
before '/secure/*' do
  if !session[:identity] then
    session[:previous_url] = request.path
    @error = 'Sorry guacamole, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end
=end

get '/' do
  erb :search_form
end

get '/result' do
	erb :result
end

post '/search' do
	@keyword = params[:keyword].gsub(' ', '+')
	@city = params[:city].gsub(' ', '+')
	@reviews = params[:reviews]
	@stars = params[:stars]


	Yelp.client.configure do |config|
	end

	params = { term: "#{@keyword}",
						 #limit: 4,
						 #category_filter: 'discgolf'
					 }

	locale = { lang: 'en' }

	response = Yelp.client.search("#{@city}", params, locale)

	response.businesses.each do |ret|
		table ||= []
		ret.rating_img_url_small.match(/\S+stars_small_(\d+).*\.png/) ; stars = $1.to_i

		if ret.review_count > @reviews.to_i and stars > @stars.to_i
			table << ret.name
			table << ret.review_count
			table << stars
			#table << ret.location.address[0]
			#table << ret.location.city
			#table << ret.location.state_code
			#table << ret.location.postal_code
		end
		p table if table.length > 0
	end


	html = "
	<div class=\"row\">
	<table class=\"table table-bordered table-hover\" style=\"font-size:12px\">
		<tr>
			<th>Name</th>
			<th>Reviews</th>
			<th>Stars</th>
		</tr>
	</table>
	</div>
	"
	erb_template = "/home/dchoi/projects/delp/views/result.erb"
	File.open(erb_template, 'w') {|f| f.write(html) }
	redirect "/result"

end
