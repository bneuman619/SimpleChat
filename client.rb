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
      loop do
        input = gets.chomp
        send_message(input)
        break if input == "exit"
        # next unless input == "exit"
        # sleep 7; break
      end
    end

    thr2 = Thread.start do
      loop do
        output = @socket.gets.chomp
        puts output
        break if output == "exit"
        #next unless output == "exit"
      end
    end

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
