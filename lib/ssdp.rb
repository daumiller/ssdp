require 'socket'
require 'ipaddr'
require_relative 'ssdp/producer'
require_relative 'ssdp/consumer'

module SSDP
  DEFAULTS = {
    # Shared
    :broadcast      => '239.255.255.250',
    :bind           => '0.0.0.0',
    :port           => 1900,
    :maxpack        => 65_507,
    # Producer-Only
    :interval       => 30,
    :notifier       => true,
    :respond_to_all => true,
    # Consumer-Only
    :timeout        => 30,
    :first_only     => false,
    :synchronous    => true,
    :no_warnings    => false
  }

  HEADER_MATCH = /^([^:]+):\s*(.+)$/

  def parse_ssdp(message)
    message.gsub! "\r\n", "\n"
    header, body = message.split "\n\n"

    header = header.split "\n"
    status = header.shift
    params = {}
    header.each do |line|
      match = HEADER_MATCH.match line
      next if match.nil?
      value = match[2]
      value = (value[1, value.length - 2] || '') if value.start_with?('"') && value.end_with?('"')
      params[match[1]] = value
    end

    { :status => status, :params => params, :body => body }
  end
  module_function :parse_ssdp

  def create_listener(options)
    listener = UDPSocket.new
    listener.do_not_reverse_lookup = true
    membership = IPAddr.new(options[:broadcast]).hton + IPAddr.new(options[:bind]).hton
    listener.setsockopt Socket::IPPROTO_IP, Socket::IP_ADD_MEMBERSHIP, membership
    listener.setsockopt Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true
    listener.setsockopt Socket::SOL_SOCKET, Socket::SO_REUSEPORT, true
    listener.bind options[:bind], options[:port]
    listener
  end
  module_function :create_listener

  def create_broadcaster
    broadcaster = UDPSocket.new
    broadcaster.setsockopt Socket::SOL_SOCKET, Socket::SO_BROADCAST, true
    broadcaster.setsockopt :IPPROTO_IP, :IP_MULTICAST_TTL, 1
    broadcaster
  end
  module_function :create_broadcaster
end
