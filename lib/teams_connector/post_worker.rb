# frozen_string_literal: true

require 'net/http'
require 'sidekiq/worker'

module TeamsConnector
  class PostWorker
    # === Includes ===
    include Sidekiq::Worker

    def perform(url, content)
      response = Net::HTTP.post(URI(url), content, { 'Content-Type' => 'application/json' })
      response.value
    end
  end
end
