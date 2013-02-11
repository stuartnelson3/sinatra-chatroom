require 'net/telnet'

Shoes.app :width => 480, :height => 240 do
  name = ask("Please, enter your name:")
  @localhost = Net::Telnet::new("Host" => "127.0.0.1",
                             "Port" => 8081,
                             "Prompt" => /[$%#>] \z/,
                             "Telnetmode" => false)
  @localhost.cmd(name)
  chat = ask("Type general:")
  @localhost.cmd(chat)
  @localhost.cmd("hello everyone")

  flow :width => 480, :height => 240, :margin => 10 do
    @chat_window = stack :width => "85%", :height => "70%", :scroll => true do
      border black, :strokewidth => 1
    end
    # thread stops when user joins after this
    # and attempts to dm gui user
    # check for new users? or re-build thread?
    Thread.new do
      @localhost.waitfor(/logoff/) do |data|
        @chat_window.append do
          para "#{data.inspect}"
        end
        @chat_window.scroll_top = @chat_window.scroll_max
      end
    end
    stack :width => "15%", :height => "70%", :scroll => true do
      border black, :strokewidth => 1
      para "User 1 \n",
        "User 2 \n",
        "User 3 \n",
        "User 4 \n",
        "User 5 \n",
    end
    stack :width => "100%" do
      @chat_line = stack :width => "70%" do
        @e = edit_line :width => "100%"
      end
      button("Enter") do
        @chat_window.append do
          para "#{@e.text}"
        end
        @localhost.print("#{@e.text}")
        @chat_line.clear do
          @e = edit_line :width => "100%"
        end

      end
    end
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