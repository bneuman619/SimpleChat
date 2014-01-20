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
    loop do
      break if @socket.gets.chomp == "SIGNON"
    end

    send_signon_message
    main
  end

  def main
    thr1 = Thread.start do
      loop do
        input = gets.chomp
        send_message("main", input)
        break if input == "exit"
      end
    end

    thr2 = Thread.start do
      loop do
        output = @socket.gets.chomp
        puts output
      end
    end

    thr1.join
    thr2.join
  end

  def send_message(dest, message)
    @socket.puts("DEST #{dest} MSG #{message}")
  end

  def send_signon_message
    puts "Sending signog message"
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

