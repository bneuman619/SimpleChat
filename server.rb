require 'socket'

class Chatroom
  attr_reader :name
  def initialize(name)
    @name = name
    @users = []
  end

  def add_user(user)
    @users << user
  end

  def delete_user(user)
    @users.delete(user)
  end

  def view_users
    @users
  end

  def send_message(message)
    @users.each do |user|
      chat_message = "#{@name.upcase}    #{message}"
      user.send_msg(chat_message)
    end
  end
end

class User
  attr_reader :username, :socket
  def initialize(username, socket)
    @username = username
    @socket = socket
  end

  def send_msg(message)
    @socket.puts(message)
  end

  def send_welcome_msg
    send_msg("Welcome, #{@username}")
  end

  def get_input
    @socket.gets.chomp
  end
end


class Server
  def initialize
    @server = start_server
    @chats = [Chatroom.new("main")]
    puts @chats
    @clients = {}
    @users = []
    @chat_history = []
  end

  def start_server
    TCPServer.new('127.0.0.1', '20000')
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
    @users.each do |user|
      user.send_msg(messages)
    end
  end

  def find_user_by_socket(client)
    @users.find { |user| user.socket == client}
  end

  def send_message(client, message)
    puts "IN send_message"
    puts message
    #puts message
     #message
      #message = parse_message(message)
    user = find_user_by_socket(client)
    puts user
    user.send_msg(message)
   
    puts " STILL IN send_message"
  end


  def signon(message, client)
    username = message.split(' ')[1]
    #@clients[username] = client
    user = User.new(username, client)
    @users << user
    @chats[0].add_user(user)
    #puts @chats[0]

    #puts "@clients is #{@clients}"
    "Welcome, #{user.username}"
  end

  def send_history(client)
    history = "HISTORY\n" + @chat_history.join("\n")
    send_message(client, history)
  end

  def start_connection(client)
    puts "In start connection"
    client.puts("SIGNON")
    signon = client.gets.chomp
    username = signon.split(' ')[1..-1].join(' ')
    user = User.new(username, client)
    @users << user
    @chats[0].add_user(user)
    user.send_welcome_msg
    user
  end

  def parse_message(message, user)
    split_message = message.split(' ')
    dest = split_message.shift(2)[1].chomp
    message = split_message[1..-1].join(' ')

    if message =~ /^PVT/
      puts "private!"
      private_message(message, user)
      return
    end

    chatroom = @chats.find { |chat| chat.name == dest }

    if chatroom.nil?
      user.send_msg("No chatroom #{dest}")
      return
    end

    
    puts message
    message = "#{user.username}: #{message}"
    chatroom.send_message(message)
  end

  def private_message(message, user)
    split_message = message.split(' ')
    dest = split_message.shift(2)[1].chomp
    user_dest = @users.find { |user| user.username == dest }

    if user.nil?
      user.send_msg("No user #{user}")
      return
    end

    message = split_message.join(' ')
    puts message
    message = "#{user.username}: #{message}"
    user_dest.send_msg(message)
  end

  def main
    loop do
      puts "pre thread"
      thr = Thread.start(@server.accept) do |client|
        user = start_connection(client)
        puts "in thread"
        loop do
          input = user.get_input
          parse_message(input, user)
        end

      thr.join

        puts "looped ended unexpectedly"

      end
      puts "thread didn't persist :("
    end
    puts "outer looped died"
  end

end

server = Server.new
server.main


