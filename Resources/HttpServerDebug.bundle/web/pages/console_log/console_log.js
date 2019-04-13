let isConnected = false;
/**
 * localization data
 * @type {object}
 */
let localStrings;

window.onload = function () {
  // localization
  requestLocalizationInfo(param => {
    localStrings = param;

    // request state
    requestConnectionState(function () {
      // request log message
      if (isConnected) {
        requestLogMessage();
      }
    });
  });
};

/**
 *  request connection state from server, and update UI
 */
function requestConnectionState(requestLogFunc) {
  const xhr = new XMLHttpRequest();
  const requestURL = `${document.location.protocol}//${document.location.host}/api/console_log?action=getstate`;
  xhr.open('GET', requestURL);
  xhr.onload = function () {
    if (xhr.status === 200) {
      // parse data
      const responseText = xhr.responseText;
      const responseJSON = JSON.parse(responseText);
      if (responseJSON && responseJSON.errno === 0) {
        isConnected = responseJSON.data;
      }

      // update UI
      updateConnectionState();

      // requst log message
      if (requestLogFunc) {
        requestLogFunc();
      }
    }
  };
  xhr.send(null);
}

/**
 *  connect or disconnect from server
 */
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
  const requestURL = `${document.location.protocol}//${document.location.host}/api/console_log?connect=${connect}`;
  xhr.open('GET', requestURL);
  xhr.onload = function () {
    if (xhr.status === 200) {
      // parse data
      const responseText = xhr.responseText;
      const responseJSON = JSON.parse(responseText);
      if (responseJSON && responseJSON.errno === 0) {
        isConnected = responseJSON.data;
      }

      // update UI
      updateConnectionState();

      // request log message
      if (isConnected) {
        requestLogMessage();
      }
    }
  };
  xhr.send(null);
}

/**
 *  request log message
 */
function requestLogMessage() {
  const xhr = new XMLHttpRequest();
  const requestURL = `${document.location.protocol}//${document.location.host}/api/console_log?action=getlog`;
  xhr.open('GET', requestURL);
  xhr.onload = function () {
    if (xhr.status === 200) {
      // parse data
      const responseText = xhr.responseText;
      const responseJSON = JSON.parse(responseText);
      if (responseJSON && responseJSON.errno === 0) {
        const logMessage = responseJSON.data;
        appendLogMessageDisplay(logMessage);
      }

      // request
      if (isConnected) {
        requestLogMessage();
      }
    }
  };
  xhr.send(null);
}

/**
 *  update connection state UI
 */
function updateConnectionState() {
  const toggleEle = document.querySelector('#toggle-connect');
  const stateEle = document.querySelector('#connection-state');
  if (isConnected) {
    toggleEle.innerHTML = localStrings && localStrings.LocalizedConsoleLogButtonTitleDisconnect;
    stateEle.innerHTML = localStrings && localStrings.LocalizedConsoleLogStateConnected;
  } else {
    toggleEle.innerHTML = localStrings && localStrings.LocalizedConsoleLogButtonTitleConnect;
    stateEle.innerHTML = localStrings && localStrings.LocalizedConsoleLogStateDisconnected;
  }
}

/**
 *  show log messages
 */
function appendLogMessageDisplay(logMessage) {
  if (logMessage && logMessage.length > 0) {
    const length = logMessage.length;
    const logEle = document.querySelector('#log-messages');

    // scroll position
    let needScrollToBottom = false;
    if (logEle.scrollHeight - logEle.scrollTop === logEle.clientHeight) {
      needScrollToBottom = true;
    }

    // enumerate log messages
    for (let i = 0; i < length; i++) {
      // create element
      const msg = logMessage[i];
      const pEle = document.createElement('p');
      pEle.innerHTML = msg;

      logEle.appendChild(pEle);
    }

    // scroll to bottom
    if (needScrollToBottom) {
      logEle.scrollTop = logEle.scrollHeight - logEle.clientHeight;
    }
  }
}
