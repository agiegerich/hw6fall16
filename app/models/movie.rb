require 'pp'

class Movie < ActiveRecord::Base
  
  @@key = 'f4702b08c0ac6ea5b51425788bb26562'
  
  def self.all_ratings
    %w(G PG PG-13 NC-17 R NR)
  end
  
 class Movie::InvalidKeyError < StandardError ; end
  
  def self.tmdb_to_movie(title, id, overview, include_tmdb_id)
    releases = Tmdb::Movie.releases(id)["countries"]
    us_releases = releases.select do |country|
      country["iso_3166_1"] == 'US'
    end
    
    us_rated_releases = us_releases.select do |country|
      country["certification"] != nil and country["certification"] != ''
    end
       
    if us_rated_releases.length != 0
      release = us_rated_releases[0]
    elsif us_releases.length != 0 
      release = us_releases[0]
      release['certification'] = 'NR'
    else
      release = {"certification" => "NR", "release_date" => ""}
    end
        
    movie = {
      :title => title,
      :rating => release["certification"],
      :release_date => release["release_date"],
      :description => overview
    }
    
    if include_tmdb_id then movie[:tmdb_id] = id end
    return movie

  end
  
  def self.create_from_tmdb(tmdb_id)
    tmdb_movie = Tmdb::Movie.detail(tmdb_id)
    movie = tmdb_to_movie(tmdb_movie["title"], tmdb_id, tmdb_movie["overview"], false)
    #movie = {
     # :title => tmdb_movie["title"],
     # :rating => tmdb_movie["certification"],
      #:release_date => tmdb_movie["release_date"],
      #:description => tmdb_movie["overview"]
    #}
    
    Movie.create!(movie)
  end
  
  def self.find_in_tmdb(string)
    begin
      Tmdb::Api.key(@@key)
      movies = Tmdb::Movie.find(string)
      movies.map do |m|
        tmdb_to_movie(m.title, m.id, m.overview, true)
      end
    rescue Tmdb::InvalidApiKeyError
      raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end
end
