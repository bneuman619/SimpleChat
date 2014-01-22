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

    #user.send_message(get_history)
  
  end

  def delete_user(user)
    @users.delete(user)
  end

  def view_users
    @users
  end

  def get_history
    if @chat_history.size > 10
      @chat_history[-11..-1].join(' ')

    else
      @chat_history.join(' ')
    end
  end

  def send_message(message)
    message = "FROM #{@name} MSG #{message}"
    @chat_history << message
    @users.each do |user|
      user.send_message(message)
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
    send_message("FROM #main MSG Welcome, #{@username}")
  end

  def get_input
    @socket.gets.chomp
  end

  def mark_alive
    puts "#{@username} ALIVE"
  end

end

class Server
  def initialize
    @server = start_server
    @chats = [Chatroom.new("#main")]
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
    msg = message.split(' ')[3..-1].join(' ')
    "#{user.username}: #{msg}"
  end

  def find_destination(message)
    dest = message.split(' ')[1]
    @users.each { |user| puts user.username; return user if user.username.downcase == dest }
    @chats.each { |chat| return chat if chat.name.downcase == dest }
    return nil
  end

  def main
    loop do
     
      thr = Thread.start(@server.accept) do |client|
       
        user = start_connection(client)
       
        loop do
          puts "Top of loop"          
          input = user.get_input
          puts input

          if input == "ALIVE"
            user.mark_alive
          
          else

            message = parse_message(input, user)
            dest = find_destination(input)
            if dest.nil?
              user.send_message("No channel #{dest}")
            else
              dest.send_message(message)
            end
          end
          
        end

      thr.join
      end
    end   
  end  
end

server = Server.new
server.main


 # def send_message(client, message)
 #    puts message
 #    user = find_user_by_socket(client)
 #    puts user
 #    user.send_msg(message)
 #  end

