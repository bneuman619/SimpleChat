This is a very simple SimpleChat.

I started to implement some IRC-like features: a bare protocol that would make it possible to have more than one channel, private msgs, etc.

Right now the chat breaks when users disconnect, because the server is still trying to forward messages onto those users.

When I left this project alone I was halfway through implementing a keepAlive check, to take disconncted users off the list of users to forward messages to.

To run: run 'ruby server.rb' on the server.

Right now, client.rb is hard-coded to connect to localhost: I have done most of the testing on just one computer.

If you want to make client.rb actually connect to another IP, modify line 12 of client.rb. To modify the port or the IP of the server, modify line 81 of server.rb.
