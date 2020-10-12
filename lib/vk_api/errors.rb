# frozen_string_literal: true

module VkApi

  # Base class
  class Error < ::StandardError; end

  # Server side error
  class ServerError < Error

    attr_accessor :session, :method, :params, :response

    def initialize(session, method, params, response)
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
    end

    def error
      response['error']
    end

  end

end
