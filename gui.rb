require 'net/telnet'

# when thread with #waitfor errors out,
# chat data no longer appears, but
# sending data still works in terminal
# handle when the thread stops to restart
# it is timing out...

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Design
# 1. chat box should always contain chat data 
# 2. hitting enter should submit chat data;
#    currently edit box won't act on 'enter', but
#    in main window enter will submit data.
# 3. side window should update with users in chatroom
# 4. present chatroom options as clickable interface,
#    and be able to switch rooms through that same interface
#    e.g. "back to room selection" and then click on new room
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

Shoes.app(:width => 480, :height => 360, :title => "Chatroom") do
  background "#ffffff"
  # name = ask("Please, enter your name:")
  # @localhost = Net::Telnet::new("Host" => "127.0.0.1",
  #                            "Port" => 8081,
  #                            "Prompt" => /[$%#>] \z/,
  #                            "Timeout" => 60 * 5,
  #                            "Telnetmode" => false)
  # @localhost.cmd(name)
  # chat = ask("Type general:")
  # @localhost.cmd(chat)
  # @localhost.cmd("hello everyone")

  # stack(:width => 480, :height => 245) do
    stack(:width => "80%", :margin => "2.5%") do
      border "#e2e2e2", :strokewidth => 1
      @chat_window = stack(:width => "100%", :height => 240, :scroll => true, :wrap => "word")
    end
    # thread stops when user joins after this
    # and attempts to dm gui user
    # check for new users? or re-build thread?
    # # # # think this is fixed # # # #
    # Thread.new do
    #   @localhost.waitfor(/logoff/) do |data|
    #     @chat_window.append do
    #       para data
    #     end
    #     @chat_window.scroll_top = @chat_window.scroll_max
    #   end
    # end
    stack(:width => "18%", :margin => [0, "2.5%", 0, "2.5%"]) do
      border "#e2e2e2", :strokewidth => 1
      stack(:width => "100%", :height => 240) do
        para "User 1\n",
        "User 2\n",
        "User 3\n",
        "User 4\n",
        "User 5\n"
      end
    end
  # end
  stack(:width => "80%", :margin => ["2.5%", 0, "2.5%", 0]) do
    border "#e2e2e2", :strokewidth => 1
    @chat_line = stack(:width => "100%", :wrap => "word") { para "" }
    @chat_line_data = ""
    keypress {|k|
      if k == "\n"
        @chat_window.append { para @chat_line_data }
        @chat_line_data.clear
      elsif k == :backspace
        @chat_line_data.chop!
      else
        @chat_line_data << k
      end
      @chat_line.clear
      @chat_line.append { para @chat_line_data, :weight => 600 }
    }
  end
end


# require 'net/telnet'
# localhost = Net::Telnet::new("Host" => "127.0.0.1",
#                              "Port" => 8081,
#                              "Timeout" => 10,
#                              "Prompt" => /[$%#>] \z/,
#                              "Telnetmode" => false)
# localhost.write "hi" # => nil
# sends 'hi' to server, doesn't get the output
# localhost.cmd("command") { |c| print c } # =>
# The available chatrooms are:
# 1. General
# 2. Games
# 3. Other
# Which chatroom would you like to join?
# >  => "The available chatrooms are:\n1. General\n2. Games\n3. Other\nWhich chatroom would you like to join?\n> "
# localhost.cmd("general") { |c| print c } # => 
# Entering General
# [info] Welcome, hi
# gets back output

# localhost.cmd "" # => waits for next message from server
# localhost.waitfor(/logoff/) {|data| puts data.inspect }