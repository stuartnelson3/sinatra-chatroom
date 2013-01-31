$(function(){
  ws = new WebSocket("ws://" + window.location.hostname + ":8080");
  
  ws.onmessage = function(evt) {
    $('#chat-area').append('<p>' + evt.data + '</p>')
  };
  
  ws.onclose = function() { 
    ws.send("Leaves the chat");
  };
  
  ws.onopen = function() {
    ws.send("Join the chat");
  };

  $(document).on('keydown', function(e) {
    if ($("#msg").is(":focus") && e.keyCode === 13) {
      if ($("#msg").val().length > 0){
        ws.send($("#msg").val());
        $("#msg").val("");
      }
    }
  });
  
  $(document).on('click', 'clear', function() {
    $("#chat-area").empty();
  });
  
});