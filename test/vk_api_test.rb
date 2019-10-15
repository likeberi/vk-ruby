# frozen_string_literal: true

require 'net/http'
require_relative 'spec_helper'
require_relative '../lib/vk_api.rb'
require_relative '../lib/vk_api/session.rb'

describe VkApi do
  describe VkApi::Session do
    it 'should be initialized with app_id, api_secret, prefix' do
      session = VkApi::Session.new 'app_id', 'api_secret', 'prefix'
      expect(session.instance_variable_get(:@app_id)).to eq 'app_id'
      expect(session.instance_variable_get(:@api_secret)).to eq 'api_secret'
      expect(session.instance_variable_get(:@prefix)).to eq 'prefix'
    end

    describe '#call' do
      it 'do request' do
        stub_request(:post, 'https://api.vk.com/method/prefix.getCollection')
          .with(body: { 'api_id' => 'app_id', 'format' => 'json',
                        'sig' => 'a9f4b7af4d7ba625f3b57610ab89ecdb', 'some_param' => 'some_value' })
          .to_return(status: 200, body: '{ "response": ["item"] }')

        session = VkApi::Session.new 'app_id', 'api_secret', 'prefix'
        expect(session.call('getCollection', some_param: 'some_value')).to eq(['item'])
      end

      it 'api error' do
        stub_request(:post, 'https://api.vk.com/method/prefix.getCollection')
          .with(body: { 'api_id' => 'app_id', 'format' => 'json',
                        'sig' => 'a9f4b7af4d7ba625f3b57610ab89ecdb', 'some_param' => 'some_value' })
          .to_return(status: 200, body: '{ "error": "Error" }')

        session = VkApi::Session.new 'app_id', 'api_secret', 'prefix'
        expect { session.call('getCollection', some_param: 'some_value') }
          .to raise_error(VkApi::ServerError)
      end

      it 'json error' do
        stub_request(:post, 'https://api.vk.com/method/prefix.getCollection')
          .with(body: { 'api_id' => 'app_id', 'format' => 'json',
                        'sig' => 'a9f4b7af4d7ba625f3b57610ab89ecdb', 'some_param' => 'some_value' })
          .to_return(status: 200, body: 'Not json body')

        session = VkApi::Session.new 'app_id', 'api_secret', 'prefix'
        expect { session.call('getCollection', some_param: 'some_value') }
          .to raise_error(VkApi::Error)
      end
    end
  end

  describe VkApi::FrequencyControl do
    describe 'request_can_be_executed_now?' do
      it 'should return true if counter is empty' do
        session = VkApi::FrequencyControl
        VkApi::FrequencyControl.instance_variable_set(:@counter, {})
        expect(session.request_can_be_executed_now?('time', 'token')).to eq true
      end

      it 'should return true if no requests for current second' do
        session = VkApi::FrequencyControl
        VkApi::FrequencyControl.instance_variable_set(:@counter, 'token' => [Time.now.to_f - 2])
        expect(session.request_can_be_executed_now?('time', Time.now.to_f)).to eq true
      end

      it 'should return true if less than 3 requests for current second executed' do
        session = VkApi::FrequencyControl
        time = Time.now.to_f
        VkApi::FrequencyControl.instance_variable_set(:@counter, 'token' => [time, time])
        expect(session.request_can_be_executed_now?(time, 'token')).to eq true
      end

      it 'should return false if 3 requests for current second executed' do
        session = VkApi::FrequencyControl
        time = Time.now.to_f
        VkApi::FrequencyControl.instance_variable_set(:@counter, 'token' => [time, time, time])
        expect(session.request_can_be_executed_now?(time, 'token')).to eq false
      end
    end

    describe 'update_counter' do
      it 'should set current time if counter is empty' do
        session = VkApi::FrequencyControl
        time = Time.now.to_f
        VkApi::FrequencyControl.instance_variable_set(:@counter, {})
        session.update_counter(time, 'token')
        expect(VkApi::FrequencyControl.instance_variable_get(:@counter)).to eq 'token' => [time]

        VkApi::FrequencyControl.instance_variable_set(:@counter, nil)
        session.update_counter(time, 'token')
        expect(VkApi::FrequencyControl.instance_variable_get(:@counter)).to eq 'token' => [time]
      end

      it 'should set first time to token if no token in current time' do
        time = Time.now.to_i
        VkApi::FrequencyControl.instance_variable_set(:@counter, 'token0' => [time])
        session = VkApi::FrequencyControl
        session.update_counter(time, 'token1')

        expect(VkApi::FrequencyControl.instance_variable_get(:@counter))
          .to eq 'token0' => [time], 'token1' => [time]
      end

      it 'should add time to token if token exists' do
        time = Time.now.to_f
        VkApi::FrequencyControl.instance_variable_set(:@counter, 'token' => [time - 1, time])
        session = VkApi::FrequencyControl
        session.update_counter(time, 'token')

        expect(VkApi::FrequencyControl.instance_variable_get(:@counter))
          .to eq 'token' => [time - 1, time, time]
      end
    end
  end
end
