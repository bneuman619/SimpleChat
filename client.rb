require 'socket'

class Client

  def initialize(username)
    @username = username
    @socket = make_socket
    send_welcome_message
  end

  def make_socket
    TCPSocket.new('127.0.0.1', '20000')
  end

  def main
    thr1 = Thread.start do
      puts "in thread 1"
      loop do
        puts "thread 1 loop"
        input = gets.chomp
        send_message(input)
        break if input == "exit"
        # next unless input == "exit"
        # sleep 7; break
      end
      puts "out of thread 1 loop"
    end

    puts "thread 1 died :("

    thr2 = Thread.start do
      puts "in thread 2"
      loop do
        puts "thraed 2 loop"
        output = @socket.gets.chomp
        puts output
        break if output == "exit"
        #next unless output == "exit"
      end
      puts "out of thread 2 loop"
    end

    puts "thread 2 died:("

    thr1.join
    thr2.join
  end

  def send_message(message)
    @socket.puts({dest: [], msg: message})
  end

  def send_welcome_message
    @socket.puts({dest: ['server'], msg: "SIGNON #{@username}"})
  end

  def socket_has_input?(socket)
    IO.select([socket], [], [], (1/100))
  end
end



client = Client.new("Ben")
client.main
