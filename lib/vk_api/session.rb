# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'digest/md5'
require 'json'
require 'active_support/inflector'

require_relative './errors.rb'
require_relative './session/frequency_control.rb'

module VkApi
  # Makes requests to vk
  class Session

    VK_API_URL = 'https://api.vk.com'

    # @option [#call(String) => void] delay request if needed
    def initialize(app_id, api_secret, method_prefix = nil, frequency_control: FrequencyControl)
      @app_id = app_id
      @api_secret = api_secret
      @prefix = method_prefix
      @frequency_control = frequency_control
    end

    def call(method, params = {})
      params = format_params(params)
      path = construct_path(method)

      # build Post request to VK (using https)
      response = frequency_control.call(params[:access_token] || '') do
        body = perform_request(path, params)
        JSON.parse(body)
      rescue JSON::ParserError
        raise VkApi::Error, "Response isn't json: #{body}"
      end

      raise ServerError.new self, method, params, response['error'] if response['error']

      response['response']
    end

    private

    attr_accessor :app_id, :api_secret, :prefix, :frequency_control

    def perform_request(path, params)
      uri = URI.parse(path)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.set_form_data(params)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.request(request).body
    end

    def construct_path(method)
      # http://vk.com/developers.php?oid=-1&p=%D0%92%D1%8B%D0%BF%D0%BE%D0%BB%D0%BD%D0%B5%D0%BD%D0%B8%D0%B5_%D0%B7%D0%B0%D0%BF%D1%80%D0%BE%D1%81%D0%BE%D0%B2_%D0%BA_API
      # now VK requires the following url: https://api.vk.com/method/METHOD_NAME
      method = method.to_s.camelize(:lower)
      method = prefix ? "#{prefix}.#{method}" : method
      VK_API_URL + "/method/#{method}"
    end

    def format_params(params)
      params = params.clone
      params[:api_id] = app_id
      params[:format] = 'json'
      params[:sig] = sig(params.tap do |s|
        # stringify keys
        s.keys.each { |k| s[k.to_s] = s.delete k }
      end)
      params
    end

    # Generates request signature
    def sig(params)
      Digest::MD5.hexdigest(
        params.keys.sort.map { |key| "#{key}=#{params[key]}" }.join +
          api_secret
      )
    end

  end
end
