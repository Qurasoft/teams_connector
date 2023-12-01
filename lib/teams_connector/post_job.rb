# frozen_string_literal: true

require 'net/http'
require 'sidekiq/job'

module TeamsConnector
  class PostJob
    # === Includes ===
    include Sidekiq::Job

    def perform(url, content)
      response = Net::HTTP.post(URI(url), content, { 'Content-Type' => 'application/json' })
      response.value
    end
  end
end
