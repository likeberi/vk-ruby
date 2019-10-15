# frozen_string_literal: true

module VkApi
  # Prevents too often requests
  class FrequencyControl

    REQUESTS_PER_SECOND = 3

    # Counter schema: {"token1" => [time1, time2, time3], 'token2' => [time21, time22, time23], ...}
    # "time" stores in Unix time
    # "token" comes from request

    class << self

      def call(token)
        @counter ||= {}
        control_frequency(Time.now.to_f, token) do
          yield
        end
      end

      def control_frequency(time, token)
        @counter[token] = [] unless @counter[token]
        if request_can_be_executed_now?(time, token)
          update_counter(time, token)
        else
          sleep(1)
          update_counter(time + 1, token)
        end
        yield
      end

      def request_can_be_executed_now?(time, token)
        !@counter[token] || # no requests for this token
          !@counter[token].first || # times array for token is empty
          time - @counter[token].first > 1 || # third request executed more than a second ago
          @counter[token].length < REQUESTS_PER_SECOND # three requests per second rule
      end

      def update_counter(time, token)
        if @counter.nil? || @counter.empty?
          @counter = { token => [time] }
        elsif @counter[token].nil?
          @counter[token] = [time]
        else
          @counter[token] << time
          @counter[token] = @counter[token].drop(1) if @counter[token].length > REQUESTS_PER_SECOND
        end
      end

    end

  end
end
