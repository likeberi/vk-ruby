# frozen_string_literal: true

module VkApi

  # Base class
  class Error < ::StandardError; end

  # Server side error
  class ServerError < Error

    attr_accessor :session, :method, :params, :response, :url

    def initialize(session, method, params, response, request_url)
      super(<<~MSG)
        VK server side error
        method: #{method}
        error:
        #{response['error'].pretty_inspect}
        params:
        #{params.pretty_inspect}
      MSG
      @session = session
      @method = method
      @params = params
      @response = response
      @url = request_url
    end

    def error
      response['error']
    end

  end

end
