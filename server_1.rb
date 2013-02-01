require 'eventmachine'
require 'paint'

# finish private message
# add multiple rooms

module Chatroom
  attr_reader :username
  DM_REGEXP = /^@([a-zA-Z0-9]+)\s*:?\s*(.+)/
  @@connections = []

  def post_init
    @username = nil
    ask_username
  end

  def unbind
    puts paint_red("#@username has disconnected")
  end

  def receive_data(data)
    if entered_username?
      handle_chat_message(data.strip)
    else
      handle_username(data.strip)
    end
  end

  def entered_username?
    @username && !@username.empty?
  end

  def handle_username(input)
    if input.empty?
      send_line("Blank usernames are not allowed. Try again.")
      ask_username
    else
      @username = input
      @@connections << self
      self.other_peers.each { |c| c.send_data("#{@username} has joined the room\n") }
      puts "#{@username} has joined"

      self.send_line("[info] Ohai, #{@username}")
    end
  end

  def ask_username
    self.send_line("[info] Enter your username:")
  end

  def handle_chat_message(msg)
    if command?(msg)
      self.handle_command(msg)
    else
      if direct_message?(msg)
        send_direct_message(msg)
      else
        self.announce(msg, "#{@username}:")
      end
    end
  end

  def direct_message?(msg)
    !!parse_pm(msg)
  end

  def send_direct_message(msg)
    pm = parse_pm(msg)
    name, message = pm[1], pm[2]

    user = @@connections.select {|c| c.username == name }.first
    user.send_line(paint_green("Message from #{self.username}: #{message}"))
    self.send_line(paint_green("Sent to #{user.username}: #{message}"))
  end

  def parse_pm(msg)
    msg.match(DM_REGEXP)
  end

  def other_peers
    @@connections.reject {|c| self == c }
  end

  def send_line(line)
    self.send_data("#{line}\n")
  end

  def command?(input)
    input =~ /(exit|users)$/i
  end

  def handle_command(cmd)
    case cmd
    when /exit$/i
      puts paint_red("#@username has left the chat")
      self.close_connection
    when /users$/i
      self.list_chatroom_users
    end
  end

  def list_chatroom_users
    names = other_peers.map(&:username)
    self.send_line(paint_blue("#{names.count} other users in chatroom:"))
    names.each {|n| self.send_line(paint_blue("@#{n}"))}
  end

  def announce(msg = nil, prefix = "[chat server]")
    @@connections.each { |c| c.send_line("#{prefix} #{msg}") } unless msg.empty?
  end

  # paint_blue, paint_green, paint_red, e.g.
  def method_missing(method_name, *args)
    if method_name =~ /paint(_(.+))/
      Paint["#{args.first.to_s}", $2.intern]
    else
      super
    end
  end
end

EventMachine::run {
  EventMachine::start_server "127.0.0.1", 8081, Chatroom
  puts 'running echo server on 8081'
}