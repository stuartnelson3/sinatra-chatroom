require 'net/telnet'

# when thread with #waitfor errors out,
# chat data no longer appears, but
# sending data still works in terminal
# handle when the thread stops to restart
# it is timing out...

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Design
# 3. side window should update with users in chatroom
# 4. present chatroom options as clickable interface,
#    and be able to switch rooms through that same interface
#    e.g. "back to room selection" and then click on new room
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

Shoes.app(:width => 480, :height => 310, :title => "Chatroom") do
  background "#ffffff"
  name = ask("Please, enter your name:")
  @localhost = Net::Telnet::new("Host" => "127.0.0.1",
                             "Port" => 8081,
                             "Prompt" => /[$%#>] \z/,
                             "Timeout" => 60 * 5,
                             "Telnetmode" => false)
  @localhost.puts(name)
  chat = ask("Type general:")
  @localhost.puts(chat)
  @localhost.puts("hello everyone")

  stack(:width => "80%", :margin => ["2.5%", "3.5%", "2.5%", "2.5%"]) do
    border "#e2e2e2", :strokewidth => 1
    @chat_window = stack(:width => "100%", :height => 240, :scroll => true, :wrap => "word")
  end

  Thread.new do
    @localhost.waitfor(/logoff/) do |data|
      @chat_window.append do
        if data.include? "ZXCV_GREEN "
          clean_data = data.slice(11..-1)
          para clean_data, :stroke => "#2da725", :height => 16
        else
          para data, :height => 16
        end
      end
      
      # # # # # # # # # # # # # # # # # #
      # data isn't being sent to gui window
      # when it is first opened
      # data is sent to most recent joiner
      # to the room. if most recent joiner
      # is in the gui, it locks up
      # # # # # # # # # # # # # # # # # #
      
      if data.include? "ZXCV_USER_LIST"
        @users_window.clear
        @users_window.append do
          clean_data = data.slice(15..-1)
          para clean_data, :leading => 0, :color => "#252525", :displace_left => 5
        end
      end
      @chat_window.scroll_top = @chat_window.scroll_max
    end
  end
  @users_window = stack(:width => "18%", :margin => [0, "3.5%", 0, "2.5%"]) do
    border "#e2e2e2", :strokewidth => 1
    stack(:width => "100%", :height => 240) do
      @users = para "User 1\n",
      "User 2\n",
      "User 3\n",
      "User 4\n",
      "User 5\n"
      @users.style(:leading => 0, :color => "#252525", :displace_left => 5)
    end
  end

  stack(:width => "80%", :margin => "2.5%") do
    border "#e2e2e2", :strokewidth => 1
    @chat_line = stack(:width => "100%") { para "" }
    @chat_line_data = ""
    # # # # # # # # 
    # fix text wrap
    # currently set to static chat bar size
    # 
    # 
    # # # # # # # #
    keypress {|k|
      if k == "\n" && !@chat_line_data.empty?
        @localhost.puts(@chat_line_data)
        @chat_line_data.clear
      elsif k == :backspace
        @chat_line_data.chop!
      else
        @chat_line_data << k
      end
      @chat_line.clear
      @chat_line.append { 
        @text = para @chat_line_data
        @text.style(:stroke => "#4d4d4d", :displace_left => 5, :displace_top => 2, :width => 360, :weight => 600, :wrap => "word")
      }
    }
  end
end