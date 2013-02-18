# require 'net/telnet'

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

Shoes.app(:width => 480, :height => 310, :title => "Chatroom") do
  background "#ffffff"

  def append_text(window, text)
    window.append {
      @text = text
      para @text
      yield @text if block_given?
    }
  end

  stack(:width => "80%", :margin => ["2.5%", "3.5%", "2.5%", "2.5%"]) do
    border "#e2e2e2", :strokewidth => 1
    @chat_window = stack(:width => "100%", :height => 240, :scroll => true, :wrap => "word")
  end

  Thread.new do
    @localhost.waitfor(/logoff/) do |data|
      # @chat_window.append do
        if data.include? "ZXCV_GREEN "
          clean_data = data.slice(11..-1)
          append_text(@chat_window, clean_data) {|text|
            text.style(:stroke => "#2da725", :height => 16)
          }
        elsif data.include? "ZXCV_USER_LIST\n"
          clean_data = data.slice(15..-1)
        else
          para data, :height => 16
        end
      end
      @chat_window.scroll_top = @chat_window.scroll_max
    # end
  end

  stack(:width => "18%", :margin => [0, "3.5%", 0, "2.5%"]) do
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
        @chat_window.append { para @chat_line_data }
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