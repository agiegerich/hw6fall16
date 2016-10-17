require 'pp'

class Movie < ActiveRecord::Base
  
  @@key = 'f4702b08c0ac6ea5b51425788bb26562'
  
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
  
 class Movie::InvalidKeyError < StandardError ; end
  
  def self.find_in_tmdb(string)
    begin
      Tmdb::Api.key(@@key)
      movies = Tmdb::Movie.find(string)
      movies.map do |m|
        releases = Tmdb::Movie.releases(m.id)["countries"]
        pp releases
        us_releases = releases.select do |country|
          country["iso_3166_1"] == 'US'
        end
        
        if us_releases.length != 0 
          release = us_releases[0]
        elsif releases.length != 0
          release = releases[0]
        else
          release = {"certification" => "n/a", "release_date" => "n/a"}
        end
        
        {
          :title => m.title,
          :rating => release["certification"],
          :release_date => release["release_date"],
          :details => m.overview
        }
      end
    rescue Tmdb::InvalidApiKeyError
        raise Movie::InvalidKeyError, 'Invalid API key'
    end
  end
end
