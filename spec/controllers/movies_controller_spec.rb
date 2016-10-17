require 'spec_helper'
require 'rails_helper'

describe MoviesController do
  describe 'searching TMDb' do
   it 'should call the model method that performs TMDb search' do
      fake_results = [double('movie1'), double('movie2')]
      expect(Movie).to receive(:find_in_tmdb).with('Ted').
        and_return(fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
    end
    it 'should select the Search Results template for rendering' do
      allow(Movie).to receive(:find_in_tmdb)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(response).to render_template('search_tmdb')
    end  
    it 'should make the TMDb search results available to that template' do
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => 'Ted'}
      expect(assigns(:movies)).to eq(fake_results)
    end 
    it 'should go to the movies home if blank search term is entered' do
      post :search_tmdb, {:search_terms => ''}
      expect(response).to redirect_to(movies_path)
    end
    it 'should go to the movies home if nil search term is recieved' do
      post :search_tmdb, {:search_terms => nil}
      expect(response).to redirect_to(movies_path)
    end
    it 'should assign searchterm to what was searched for' do
      movie_name = 'SPAGETT AND THE QUEST FOR THE GOLDEN TREASURE'
      fake_results = [double('Movie'), double('Movie')]
      allow(Movie).to receive(:find_in_tmdb).and_return (fake_results)
      post :search_tmdb, {:search_terms => movie_name }
      expect(assigns(:searchterm)).to eq(movie_name)
    end
  end
end
