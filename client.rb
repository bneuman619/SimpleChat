require 'socket'

class Client

  def initialize(username)
    @username = username
    @socket = make_socket
    start_connection
  end

  def make_socket
    TCPSocket.new('127.0.0.1', '20000')
  end

  def start_connection
    puts "Entering signon loop"
    loop do
      break if @socket.gets.chomp == "SIGNON"
    end
    puts "Leaving signon loop"
    send_signon_message
    main
  end

  def main
    thr1 = Thread.start do
      loop do
        input = gets.chomp
        send_message("#main", input)
        break if input == "exit"
      end
    end

    thr2 = Thread.start do
      loop do
        incoming_message = @socket.gets.chomp
        message = parse_incoming_message(message)
        puts message
      end
    end

    thr1.join
    thr2.join
  end

  def parse_incoming_message(message)
    from = message.split(' ')[1]
    msg = message.split(' ')[3..-1]
    "#{from.upcase}: #{msg}"
  end

  def send_message(dest, message)
    @socket.puts("DEST #{dest} MSG #{message}")
  end

  def send_signon_message
    @socket.puts("SIGNON #{@username}")
  end
end

def ui
  puts "Give user name"
  username = gets.chomp
  client = Client.new(username)
end

ui



  # def parse_message(input)
  #   if input =~ /^\/MSG/
  #     split_message = input.split(' ')
  #     dest = split_message[1]
  #     message = split_message[1..-1].join(' ')
  #     send_message(dest, message)
  #   else
  #     send_message("main", message)
  #   end
  # end

