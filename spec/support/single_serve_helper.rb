# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)
require 'socket'

module Helpers
  class SingleServe
    # A super-simple RPC for stateless protocols (udp)
    CLOSE_MAGIC = 'SingleServe.close()'

    attr_reader :port

    def initialize(transport)
      @transport = transport.to_sym
      @bytes = ''

      case @transport
        when :tcp
          @socket = TCPServer.new('127.0.0.1', 0)
          @port = @socket.addr[1]
          @thread = Thread.new { tcp_loop }
        when :udp
          @socket = UDPSocket.new
          @socket.bind('127.0.0.1', 0)
          @port = @socket.addr[1]
          @thread = Thread.new { udp_loop }
        else
          raise(ArgumentError, 'Only :tcp and :udp socket types supported')
      end
    end

    # End the server, returning the data sent by the client
    def bytes
      if @thread.alive?
        # UDP is stateless, so we have to indicate closure to the server
        if @transport == :udp
          closer = UDPSocket.new
          closer.connect('127.0.0.1', @port)
          closer.send CLOSE_MAGIC, 0
        end
        @thread.join
      end
      @bytes
    end

    private

    def tcp_loop
      client_socket = @socket.accept
      loop do
        readable = select([client_socket])[0]
        if readable.empty?
          break
        else
          begin
            buffer = ''
            client_socket.readpartial(4096, buffer)
            @bytes << buffer
          rescue EOFError
            @bytes << buffer
            return
          end
        end
      end
      @bytes
    end

    def udp_loop
      client_socket = @socket
      loop do
        readable = select([client_socket])[0]
        if readable.empty?
          break
        else
          @bytes << client_socket.recvfrom_nonblock(4096)[0]
          if @bytes.end_with? CLOSE_MAGIC
            @bytes.chomp! CLOSE_MAGIC
            break
          end
        end
      end
      @bytes
    end

  end
end
