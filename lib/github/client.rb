require 'faraday'

module Github
  class Client
  	def initialize(client)
  		@client = client
  	end

  	def self.fetch_contributors(user, repo)
  		response = Faraday.get "https://api.github.com/repos/#{user}/#{repo}/contributors"
  		response.body
  	end
  end
end