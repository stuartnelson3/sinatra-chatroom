require 'eventmachine'
require 'paint'

# add uniqueness check on user names
# make web interface/gui interface
# add virtus to manage attributes

# add data structure to hold record of users present,
# push changes to user window in gui
# remove the newline stuff
# remove terminal formatting

# refactor this into something readable

module Chatroom
  attr_reader :username, :chatroom
  DM_REGEXP = /^@([a-zA-Z0-9]+)\s*:?\s*(.+)/
  @@connections = []
  @@chatrooms = ["General", "Games", "Other"]
  @@commands = ["help", "exit", "users", "switch_chatroom"]

  def post_init
    puts "User has connected"
    @username = nil
    @chatroom = nil
    ask_username
  end

  def unbind
    puts paint_red("#@username has disconnected")
    @@connections.reject! {|conn| conn.username == @username }
  end

  def receive_data(data)
    if ready_to_chat?
      handle_chat_message(data.strip)
    elsif entered_username?
      pick_chatroom(data.strip)
    else
      handle_username(data.strip)
    end
  end

  def ready_to_chat?
    entered_username? && picked_chatroom?
  end

  def picked_chatroom?
    @chatroom && !@chatroom.empty?
  end

  def entered_username?
    @username && !@username.empty?
  end

  def username_taken?(input)
    usernames = @@connections.map(&:username)
    usernames.include? input
  end

  def handle_username(input)
    if input.empty?
      send_line(paint_red("Blank usernames are not allowed. Try again."))
      ask_username
    elsif username_taken?(input)
      send_line(paint_red("That username is already taken. Please pick another."))
      ask_username
    else
      @username = input
      @@connections << self
      ask_chatroom_preference
    end
  end

  def pick_chatroom(input)
    if input.empty?
      send_line(paint_red("You must choose a chatroom"))
      ask_chatroom_preference
    elsif @@chatrooms.map(&:downcase).include? input.downcase
      @chatroom = input.downcase.capitalize
      send_line("Entering #{@chatroom}")
      other_peers.each { |c| c.send_line("\n#{@username} has joined the chat") }
      puts "#{@username} has joined #{@chatroom}"
      send_line("[info] Welcome, #{@username}")
    end
  end

  def ask_chatroom_preference
    send_line("The available chatrooms are:")
    @@chatrooms.each_with_index {|chatroom, i| send_line("#{i + 1}. #{chatroom}")}
    send_line("Which chatroom would you like to join?")
  end

  def ask_username
    send_line("[info] Enter your username:")
  end

  def handle_chat_message(msg)
    if command?(msg)
      handle_command(msg)
    else
      if direct_message?(msg)
        send_direct_message(msg)
      else
        announce(msg, "#{@username}:")
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

    user.send_line(paint_green("\nMessage from #{self.username}: #{message}"))
    send_line(paint_green("Sent to #{user.username}: #{message}"))
  end

  def parse_pm(msg)
    msg.match(DM_REGEXP)
  end

  def other_peers
    @@connections.reject {|c| self == c }.select {|c| c.chatroom == self.chatroom }
  end

  def send_line(line)
    send_data("#{line}")
  end

  def command?(input)
    @@commands.include? input
  end

  def handle_command(cmd)
    case cmd
    when /exit$/i
      puts paint_red("#@username has left the chat")
      close_connection
    when /users$/i
      list_chatroom_users
    when /switch_chatroom$/i
      switch_chatroom
    when /help/i
      list_commands
    end
  end

  def list_commands
    send_line("Available commands are:")
    send_line(@@commands.join(", "))
  end

  def list_chatroom_users
    names = other_peers.map(&:username)
    plurality = names.count == 1 ? "user" : "users"
    send_line(paint_blue("#{names.count} other #{plurality} in #{@chatroom}:"))
    send_line(names.join(", "))
  end

  def switch_chatroom
    send_line("Leaving #{@chatroom}")
    other_peers.each {|p| p.send_line(paint_red("\n#{@username} has left the chat"))}
    puts "#{@username} has left #{@chatroom}"
    @chatroom = nil
    ask_chatroom_preference
  end

  def announce(msg = nil, prefix = "[chat server]")
    @@connections.each { |c| c.send_line("#{prefix} #{msg}") } unless msg.empty?
  end

  # paint_blue, paint_green, paint_red, e.g.
  def method_missing(method_name, *args)
    if method_name =~ /paint(_(.+))/
      Paint["#{args.join}", $2.intern]
    else
      super
    end
  end
end

EventMachine::run {
  EventMachine::start_server "127.0.0.1", 8081, Chatroom
  puts 'running echo server on 8081'
}