var scheme   = "ws://";
var uri      = scheme + window.document.location.host + "/";
var ws       = new WebSocket(uri);
var currentUsers = [];
var usernameColors = {};
$(document).ready(function() {
    $("#input-form").on("submit", function(event) {
        event.preventDefault();
        var text   = $("#input-text")[0].value;
        if(text.trim() == '') {
            return;
        }
        ws.send(JSON.stringify({
            "action": "message",
            "message": text
        }));
        $("#input-text")[0].value = "";
    });
    ws.onopen = function(event) {
        ws.send(JSON.stringify({
            "action": "login",
            "username": currentUsername,
            "chat_mode": chatMode
        }));
    };
    ws.onmessage = function(message) {
        var data = JSON.parse(message.data);
        if(data.action == "message") {
            $("#chat-text").append("<div class='panel panel-default clearfix'><div class='panel-heading' style='color: " + usernameColors[data.sender] + "'>" + data.sender + "</div><img src='assets/arrow.jpg'/><div class='panel-body'>" + data.msg + "<br /><p class='msg-date'>" + data.date + "</p></div></div>");
            var d = $('#chat-text');
            d.scrollTop(d.prop("scrollHeight"));
        } else if(data.action == "join") {
            currentUsers.push(data);
            usernameColors[data.username] = getRandomColor();
            redisplayUsers();
            $("#chat-text").append("<div class='panel panel-default clearfix'><div id ='join-header' class='panel-heading'>" + data.username + " just joined the conversation</div></div>");
        } else if(data.action == "leave") {
            for(var i = 0; i < currentUsers.length; i++) {
                if(currentUsers[i].username == data.username) {
                    currentUsers.splice(i, 1);
                    redisplayUsers();
                }
            }
        } else if(data.action == "logout") {
            window.location = "/login";
        }
    };
});

function redisplayUsers() {
    $('#users-list').html('');
    for(var i = 0; i < currentUsers.length; i++) {
        var username = currentUsers[i].username;
        $('#users-list').append("<div class='clearfix'><img src='assets/" + currentUsers[i].chat_mode +".png' /><div class='username' style='color: " + usernameColors[username] + "'>" + username + "</div></div>");
    }
};

function getRandomColor() {
    var letters = '0123456789ABCDEF';
    var color = '#';
    for (var i = 0; i < 6; i++ ) {
        color += letters[Math.floor(Math.random() * 16)];
    }
    return color;
}
