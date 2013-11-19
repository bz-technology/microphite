# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

require 'socket'
require 'thread'

module Microphite
  module Client
    class Socket < Base
      def initialize(options)
        defaults = {
            port: 2003,           # Server port
            transport: :udp,      # Transport: tcp or udp
            min_delay: 2,         # Initial delay for write failures (seconds)
            max_delay: 60,        # Maximum delay for write failures (seconds)
        }
        params         = defaults.merge(options)

        # Read-only state
        @host          = params[:host]
        @port          = params[:port]
        @transport     = params[:transport]
        @min_delay     = params[:min_delay]
        @max_delay     = params[:max_delay]

        # Worker State
        @socket        = nil

        super(options)
      end

      protected

      def shutdown
        @socket.close unless @socket.nil?
      end

      private

      def write_metric(metric)
        sent = false
        failure_delay = @min_delay
        until sent
          begin
            new_socket if @socket.nil?
            @socket.send(format_line(metric), 0)
            sent = true

          rescue Exception => e
            error(e)

            # TODO: More robust handling?
            sleep failure_delay
            new_socket
            if failure_delay < @max_delay
              failure_delay += 1
            end
          end
        end
      end

      def new_socket
        case @transport
          when :tcp
            @socket = TCPSocket.new(@host, @port)
          when :udp
            @socket = UDPSocket.new
            @socket.connect(@host, @port)
          else
            error(AssertionError.new("Invalid transport: #{@transport}"))
        end
      end

      def format_line(metric)
        "#{@prefix}#{metric.key} #{format('%f', metric.value)} #{metric.time.to_i}\n"
      end
    end
  end
end
