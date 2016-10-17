

describe Movie do

  describe 'searching Tmdb by keyword' do
    context 'with valid key' do
      it 'should call Tmdb with title keywords' do
        fake_results = [
          instance_double('movie1', :title => 'a', :rating => 'r', :overview => 's'), 
          instance_double('movie2', :title => 'b', :rating => 'r', :overview => '')
        ]
        expect(Tmdb::Movie).to receive(:find).with('Inception').and_return(fake_results)
        Movie.find_in_tmdb('Inception')
      end
    end
    context 'with invalid key' do
      it 'should raise InvalidKeyError if key is missing or invalid' do
        allow(Tmdb::Movie).to receive(:find).and_raise(Tmdb::InvalidApiKeyError)
        expect {Movie.find_in_tmdb('Inception') }.to raise_error(Movie::InvalidKeyError)
      end
    end
    it 'should convert the movies returned to hashes' do
        fake_results = [
          instance_double('movie1', :title => 'a', :rating => 'r', :overview => 's'), 
          instance_double('movie2', :title => 'b', :rating => 'r', :overview => '')
        ]
        expect(Tmdb::Movie).to receive(:find).and_return(fake_results)
        expect(Movie.find_in_tmdb('SPAGETT')).to eq(
          [
            {:title => 'a', :rating => 'r', :release => 'temp', :details => 's'}, 
            {:title => 'b', :rating => 'r', :release => 'temp', :details => ''}
          ]
        )
      
    end
    
    it 'should return an empty array if we dont get any movies from the movie database' do
      fake_results = []
      expect(Tmdb::Movie).to receive(:find).and_return(fake_results)
      expect(Movie.find_in_tmdb('SPAGETT')).to eq([])
    end
  end
end
