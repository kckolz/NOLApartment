require './spell_checker'

describe SpellChecker do
  it 'should respond to check' do
    SpellChecker.new.should respond_to :check
  end

  it 'should return nil if there is no api_key' do
    checker = SpellChecker.new
    checker.instance_variable_set :@api_key, nil

    checker.check('1 sugar bowl dr, new orleans').should eq nil
  end

  context 'parse_response' do
    it 'should respond to parse_response' do
      SpellChecker.new.should respond_to :parse_response
    end

    it 'parse_response should return the spelling suggestion if it exists' do
      response = '{ "spelling" : { "correctedQuery" : "foo" } }'

      SpellChecker.new.parse_response(response).should eq "foo"
    end

    it 'parse_response should return nill if no spelling suggestion exists' do
      response = '{}'

      SpellChecker.new.parse_response(response).should eq nil
    end
  end

  context 'build_url' do
    it 'should respond to build_url' do
      SpellChecker.new.should respond_to :build_url
    end

    it 'should return the google search url' do
      url = SpellChecker.new('key').build_url('foo')

      url.should eq "https://www.googleapis.com/customsearch/v1?key=key&cx=008774535076880730414:pil9ab_j8-e&q=foo"
    end

    it 'should url escape the query' do
      url = SpellChecker.new('key').build_url('foo bar')

      url.should eq "https://www.googleapis.com/customsearch/v1?key=key&cx=008774535076880730414:pil9ab_j8-e&q=foo%20bar"
    end
  end
end
