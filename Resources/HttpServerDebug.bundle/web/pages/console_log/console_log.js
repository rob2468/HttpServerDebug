/**
 * localization data
 * @type {object}
 */
let localStrings;

window.onload = function () {
  // localization
  requestLocalizationInfo(param => {
    localStrings = param;

    if ('WebSocket' in window) {
      var host = window.location.host;
      var ws = new WebSocket('ws://' + host);
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
  });
};
