#require 'rubygems'
require 'sinatra'
require 'yelp'
#require 'newrelic_rpm'
#RACK_ENV["production"]

Yelp.client.configure do |config|
   config.consumer_key = "vfwATxKSqtqo3mKw4NB9iQ"
   config.consumer_secret = "5v-ft5mXblCwZo0VDuUxkku2nNU"
   config.token = "sHh6HO17PyaFk_SzMRlBxGb5LcKDtMYs"
   config.token_secret = "lwdX0nGWYjra8v4S6HEALASwVao"
end

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
  #status 2000
  headers \
   "Delp" => "delp",
   "Refresh" => "Refresh: 20"
  erb :search_form
end

post '/' do
	@keyword = params[:keyword].gsub(' ', '+')
	@city = params[:city].gsub(' ', '+')
	@reviews = params[:reviews]
	@stars = params[:stars]



	params = { term: "#{@keyword}",
						 #limit: 20,
						 #category_filter: 'discgolf'
					 }

	locale = { lang: 'en' }

	response = Yelp.client.search("#{@city}", params, locale)

	@table ||= []

	response.businesses.each do |ret|
		ret.rating_img_url_small.match(/\S+stars_small_(\d+[_half]*)\.png/)
		if $1.include?("_half")
			stars = $1.split('_')[0].to_f + 0.5
		else
			stars = $1.to_i
		end

		if ret.review_count > @reviews.to_i and stars >= @stars.to_f
			tmp_table = []
			tmp_table << ret.name
			tmp_table << ret.url
			tmp_table << ret.review_count
			tmp_table << stars
			tmp_table << ret.location.address[0]
			tmp_table << ret.location.city
			tmp_table << ret.location.state_code
			tmp_table << ret.location.postal_code
			@table << tmp_table
		end
	end
	#puts "#{@keyword}:#{@city}"
	#p @table if @table.length > 0

	erb :result

end
