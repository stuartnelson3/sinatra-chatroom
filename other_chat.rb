require 'sinatra'
set :server, 'thin'
connections = []

get '/' do
  halt erb(:login) unless params[:user]
  erb :chat, :locals => { :user => params[:user].gsub(/\W/, '') }
end

get '/stream', :provides => 'text/event-stream' do
  stream :keep_open do |out|
    connections << out
    out.callback { connections.delete(out) }
  end
end

post '/' do
  connections.each { |out| out << "data: #{params[:msg]}\n\n" }
  204 # response without entity body
end

__END__

@@ layout
<html>
  <head>
    <title>Super Simple Chat with Sinatra</title>
    <meta charset="utf-8" />
    <script src="//ajax.googleapis.com/ajax/libs/jquery/1.9.1/jquery.min.js"></script>
  </head>
  <body><%= yield %></body>
</html>

@@ login
<form action='/'>
  <label for='user'>User Name:</label>
  <input name='user' value='' />
  <input type='submit' value="GO!" />
</form>

@@ chat
<pre id='chat'></pre>

<script>
  // reading
  var source = new EventSource('/stream');
  source.addEventListener('message', function(e){
    console.log('Received a message:' + e.data);
  });
  source.onmessage = function(evt) {
    $('#chat').append('<p>' + evt.data + '</p>')
  };

  // writing
  $("#button").on("click", function(e) {
    opts = {
      url: "/",
      type: "POST",
      dataType: "text",
      data: $('#msg').val()
    }
    $.ajax(opts)
    $('#msg').val('');
    $('#msg').focus();
    // e.preventDefault();
  });
</script>

<form>
  <input id='msg' placeholder='type message here...' />
  <button id="button" type="button">enter</button>
</form>