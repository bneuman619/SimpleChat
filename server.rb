require 'socket'

class Chatroom
  attr_reader :name
  def initialize(name)
    @name = name
    @users = []
    @chat_history = []
  end

  def add_user(user)
    @users << user
    send_message("#{user.username} joined #{@name}")
    user.send_message(get_history)
  end

  def delete_user(user)
    @users.delete(user)
  end

  def view_users
    @users
  end

  def get_history
    if @chat_history.size > 10
      @chat_history[-11..-1]

    else
      @chat_history
    end
  end

  def send_message(message)
    chat_message = "#{@name.upcase}    #{message}"
    @chat_history << message

    @users.each do |user|
      user.send_message(chat_message)
    end
  end
end

class User
  attr_reader :username, :socket
  def initialize(username, socket)
    @username = username
    @socket = socket
  end

  def send_message(message)
    @socket.puts(message)
  end

  def send_welcome_msg
    send_message("Welcome, #{@username}")
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
  end

  def start_server
    TCPServer.new('127.0.0.1', '20000')
  end


  def find_username(user)
    @clients.each { |username, client| return username if user == client }

    nil
  end

  def send_to_all(message)
    @users.each do |user|
      user.send_message(messages)
    end
  end

  def find_user_by_socket_connection(socket_connection)
    @users.find { |user| user.socket == socket_connection }
  end

  def start_connection(client)
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
      user.send_message("No chatroom #{dest}")
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
      user.send_message("No user #{user}")
      return
    end

    message = split_message.join(' ')
    puts message
    message = "#{user.username}: #{message}"
    user_dest.send_message(message)
  end

  def main
    loop do
     
      thr = Thread.start(@server.accept) do |client|
        user = start_connection(client)
      
        loop do
          input = user.get_input
          puts input
          parse_message(input, user)
        end

      thr.join
      end
    end   
  end  
end

server = Server.new
server.main


 def send_message(client, message)
    puts message
    user = find_user_by_socket(client)
    puts user
    user.send_msg(message)
  end

