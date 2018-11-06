let isConnected = false;

window.onload = function () {

};

function requestConnectionState() {
    const xhr = new XMLHttpRequest();
    var requestURL = document.location.protocol + '//' + document.location.host
    + '/api/console_log?action=getstate';
    xhr.open('GET', requestURL);
    xhr.onload = function () {
        if (xhr.status === 200) {
            const responseText = xhr.responseText;
            const responseJSON = JSON.parse(responseText);
        }
    };
    xhr.send(null);
}

function toggleConnection() {
    const xhr = new XMLHttpRequest();
    let connect;
    if (isConnected) {
        // current connected, disconnect
        connect = '0';
    } else {
        // connect
        connect = '1';
    }
    var requestURL = document.location.protocol + '//' + document.location.host
    + '/api/console_log?connect=' + connect;
    xhr.open('GET', requestURL);
    xhr.onload = function () {
        if (xhr.status === 200) {
            const responseText = xhr.responseText;
            const responseJSON = JSON.parse(responseText);
            console.log(responseJSON);
            isConnected = !isConnected;
        }
    };
    xhr.send(null);
}
/*
if ('WebSocket' in window) {
    var ws = new WebSocket('%%WEBSOCKET_URL%%');
    ws.onopen = function () {
        var stateEle = document.getElementById('connection_state');
        stateEle.innerHTML = 'CONNECTED';
    };
    ws.onmessage = function (evt) {
        var needScrollToBottom = false;
        var logsEle = document.getElementById('logs-content');
        if (logsEle.scrollTop + logsEle.clientHeight === logsEle.scrollHeight) {
            needScrollToBottom = true;
        }
        // show log string
        var htmlStr = '<p>' + evt.data + '</p>';
        logsEle.insertAdjacentHTML('beforeend', htmlStr);
        // auto scroll to bottom
        if (needScrollToBottom) {
            logsEle.scrollTop = logsEle.scrollHeight - logsEle.clientHeight;
        }
    };
    ws.onclose = function () {
        var stateEle = document.getElementById('connection_state');
        stateEle.innerHTML = 'DISCONNECTED';
    };
    ws.onerror = function () {
    };
} else {
    alert('Browser doesn\'t support WebSocket!');
}
*/
