require 'socket'
require 'ssdp'

module SSDP
  class Consumer
    def initialize(options={})
      @options = SSDP::DEFAULTS.merge options
      @search_socket = SSDP.create_broadcaster
      @watch = {
        :socket   => nil,
        :thread   => nil,
        :services => {}
      }
    end

    def search(options={}, &block)
      options = @options.merge options
      options[:callback] ||= block unless block.nil?
      fail 'SSDP consumer async search missing callback.' if (options[:synchronous] == false) && options[:callback].nil?
      fail 'SSDP consumer search accepting multiple responses must specify a timeout value.' if (options[:first_only] == false) && (options[:timeout].to_i < 1)
      warn 'Warning: Calling SSDP search without a service specified.' if options[:service].nil? && (options[:no_warnings] != true)
      warn 'Warning: Calling SSDP search without a timeout value.' if (options[:timeout].to_i < 1) && (options[:no_warnings] != true)

      @search_socket.send compose_search(options), 0, options[:broadcast], options[:port]

      if options[:synchronous]
        search_sync options
      else
        search_async options
      end
    end

    def start_watching_type(type, &block)
      @watch[:services][type] = block
      start_watch if @watch[:thread].nil?
    end

    def stop_watching_type(type)
      @watch[:services].delete type
      stop_watch if (@watch[:services].count == 0) && @watch[:thread]
    end

    def stop_watching_all
      @watch[:services] = {}
      stop_watch if @watch[:thread]
    end

    private

    def compose_search(options)
      query = "M-SEARCH * HTTP/1.1\n"                            \
              "Host: #{options[:broadcast]}:#{options[:port]}\n" \
              "Man: \"ssdp:discover\"\n"
      query += "ST: #{options[:service]}\n" if options[:service]
      options[:params].each { |key, val| query += "#{key}: #{val}\n" } if options[:params]
      query + "\n"
    end

    def search_sync(options)
      if options[:first_only]
        search_single options
      else
        search_multi options
      end
    end

    def search_async(options)
      if options[:first_only]
        Thread.new { search_single options }
      else
        Thread.new { search_multi options }
      end
    end

    def search_single(options)
      result = nil
      found = false

      if options[:timeout]
        began = Time.now
        remaining = options[:timeout]
        while !found && remaining > 0
          ready = IO.select [@search_socket], nil, nil, remaining
          if ready
            message, producer = @search_socket.recvfrom options[:maxpack]
            result = process_ssdp_packet message, producer
            found = options[:filter].nil? ? true : options[:filter].call(result)
          end
          remaining = options[:timeout] - (Time.now - began).to_i
        end
      else
        until found
          message, producer = @search_socket.recvfrom options[:maxpack]
          result = process_ssdp_packet message, producer
          found = options[:filter].nil? ? true : options[:filter].call(result)
        end
      end

      if options[:synchronous]
        result
      else
        options[:callback].call result
      end
    end

    def search_multi(options)
      remaining = options[:timeout]
      responses = []

      while remaining > 0
        start_time = Time.now
        ready = IO.select [@search_socket], nil, nil, remaining
        if ready
          message, producer = @search_socket.recvfrom options[:maxpack]
          if options[:filter].nil?
            responses << process_ssdp_packet(message, producer)
          else
            result = process_ssdp_packet message, producer
            responses << result if options[:filter].call(result)
          end
        end
        remaining -= (Time.now - start_time).to_i
      end

      if options[:synchronous]
        responses
      else
        options[:callback].call responses
      end
    end

    def process_ssdp_packet(message, producer)
      ssdp = SSDP.parse_ssdp message
      { :address => producer[3], :port => producer[1] }.merge ssdp
    end

    def start_watch
      @watch[:socket] = SSDP.create_listener @options
      @watch[:thread] = Thread.new do
        begin
          loop do
            message, producer = @watch[:socket].recvfrom @options[:maxpack]
            notification = process_ssdp_packet message, producer
            notification_type = notification[:params]['NT']
            @watch[:services][notification_type].call notification if @watch[:services].include? notification_type
          end
        ensure
          @watch[:socket].close
        end
      end
    end

    def stop_watch
      @watch[:thread].exit
      @watch[:thread] = nil
    end
  end
end
