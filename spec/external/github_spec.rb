require 'spec_helper'
require 'faraday'
require './lib/github/client.rb'


# External call without stubbing
describe 'Request to Github' do
  it 'Query urbanladder contributors on GitHub' do
    conn = Faraday.new(url: 'https://api.github.com')
    response = conn.get '/repos/urbanladder/ozonetel/contributors'
    expect(response.body).to be_an_instance_of(String)
  end
end