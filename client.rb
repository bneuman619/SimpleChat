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

    send_welcome_message
    main
  end

  def main
    thr1 = Thread.start do
      #puts "in thread 1"
      loop do
        #puts "thread 1 loop"
        input = gets.chomp
        send_message("main", input)
        break if input == "exit"
        # next unless input == "exit"
        # sleep 7; break
      end
      #puts "out of thread 1 loop"
    end

   #puts "thread 1 died :("

    thr2 = Thread.start do
      #puts "in thread 2"
      loop do
        #puts "thraed 2 loop"
        output = @socket.gets.chomp
        puts output
        #break if output == "exit"
        #next unless output == "exit"
      end
      #puts "out of thread 2 loop"
    end

    #puts "thread 2 died:("

    thr1.join
    thr2.join
  end

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

  def send_message(dest, message)
    @socket.puts("DEST #{dest} MSG #{message}")
  end

  def send_welcome_message
    @socket.puts("SIGNON #{@username}")
  end

  def socket_has_input?(socket)
    IO.select([socket], [], [], (1/100))
  end
end

def ui
  puts "Give user name"
  username = gets.chomp
  client = Client.new(username)
end
#USERNAME = ARGV[0]
ui
# client = Client.new('Ben')
# client.main
