require 'socket'

class Server
  def initialize
    @server = start_server
    @clients = {}
    @chat_history = []
  end

  def start_server
    TCPServer.new('127.0.0.1', '20000')
  end

  def start_connection(client)
    username = @server.gets.chomp
    @clients[username] = client
    username
  end

  def find_username(user)
    @clients.each { |username, client| return username if user == client }

    nil
  end

  # def send_welcome(username)
  #   client = @clients[username]
  #   client.puts("Welcome, #{username}")
  # end

  def send_to_all(message)
    @clients.each do |username, client|
      puts username
      puts client
      send_message(client, message)
    end
  end

  def send_message(client, message)
    puts "IN send_message"
    puts message
    puts message
     #message
      #message = parse_message(message)
    client.puts(message )
    #end
    #puts message
    puts " STILL IN send_message"
  end

  def parse_message(message, client)
    return signon(message, client) if message.include? "SIGNON"

    split_message = message.split(' ')
    dest = split_message.shift(2)[1]
    # if split_message.include? "SIGNON"
    #   signon(message)
    # else
    message = split_message[1..-1].join(' ')
    username = find_username(client)
    #{}"#{message}"
    # puts "username is #{username}"
    "#{username}: #{message}"
    #end
  end

  # def parse_welcome(input, client)
  #   username = input[:msg].split(' ')[1]
  #   @clients[username] = client
  #   username
  # end

  def signon(message, client)
    username = message.split(' ')[1]
    @clients[username] = client
    puts "@clients is #{@clients}"
    "Welcome, #{username}"
  end

  def send_history(client)
    history = "HISTORY\n" + @chat_history.join("\n")
    send_message(client, history)
  end
  
  def main
    loop do
      puts "pre thread"
      Thread.start(@server.accept) do |client|
        # username = start_connection(client)
        # puts username
        # send_welcome(username)
        puts "in thread"
        loop do
          puts "hope this thread persists"
          input = client.gets.chomp
          puts "Got input!"
          parsed = parse_message(input, client)
          puts "Got parsed!"
          puts parsed
          @chat_history << parsed
          puts @chat_history
          #puts input
          if parsed.include? "Welcome"
            send_message(client, parsed)
            send_history(client)
          else
            send_to_all(parsed)
          end
            #send_message(client, parsed)
          # else
          #send_to_all(message)
          #end
          #message = parse_message(input, client)
          #client.puts(input)
          #send_message(client, message)
          #break if input == "exit"
        end
        puts "looped ended unexpectedly"

      end
      puts "thread didn't persist :("
    end
    puts "outer looped died"
  end

end

server = Server.new
server.main


