require 'sinatra'
require 'rubygems'
require 'active_support/all'
require 'pg'
require 'HTTParty'
require 'JSON'

get '/' do
    @genres = get_genres
    @image_urls = get_images
    sql = "select distinct genre from videos"
    get_images
    erb :home
end


get '/new' do
    @genres = get_genres
    erb :new
end

post '/create' do
    sql = "Insert into videos (title, description, url, genre) 
            values ('#{params['title']}', '#{params['description']}', '#{params['url']}', '#{params['genre'].downcase}')"
    run_sql(sql)
    redirect to('/videos')
end  

get '/videos' do 
    @genres = get_genres
    sql = "select * from videos"
    @rows = run_sql(sql)
    erb :videos
end

get '/videos/:id/edit' do
    @genres = get_genres
    sql = "select * from videos where id = #{params['id']}"
    @row = run_sql(sql).first
    erb :edit
end

get '/videos/genres/:genre' do
    @genres = get_genres
    sql = "select * from videos where genre = '#{params['genre']}'"
    @rows = run_sql(sql)
    erb :genre
end

post '/videos/:id/edit' do
    @genres = get_genres
    sql = "update videos set 
            title='#{params['title']}', description='#{params['description']}', url='#{params['url']}', genre='#{params['genre'].downcase}'
             where id = #{params['id']}"
    run_sql sql
    redirect to('/videos')
end

post '/videos/:id/delete' do
    sql = "delete from videos where id = #{params['id']}"
    run_sql(sql)
    redirect to('/videos')
end


def run_sql(sql)
    conn = PG.connect(:dbname => 'movie_db',:host => 'localhost')
    result = conn.exec(sql)
    conn.close
    result
end

def get_genres
    sql = "select distinct genre from videos"
    genres = run_sql(sql)
end

def get_images
    image_urls = []
    pre_url = "http://www.omdbapi.com/?t="
    sql = "select title from videos"
    titles = run_sql(sql)
    titles.each do |title| 
        url = title['title'].gsub(" ", "%20").prepend(pre_url)
        json = HTTParty.get(url)
        movie_data_hash = JSON(json)
        movie_poster = movie_data_hash['Poster']
        image_urls << movie_poster
    end
    image_urls
end

