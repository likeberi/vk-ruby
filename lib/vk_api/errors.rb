# frozen_string_literal: true

module VkApi

  # Base class
  class Error < ::StandardError; end

  # Server side error
  class ServerError < Error

    attr_accessor :session, :method, :params, :error
    def initialize(session, method, params, error)
      super(<<~MSG)
        VK server side error
        method: #{method}
        error:
        #{error.pretty_inspect}
        params:
        #{params.pretty_inspect}
      MSG
      @session = session
      @method = method
      @params = params
      @error = error
    end

  end

end
