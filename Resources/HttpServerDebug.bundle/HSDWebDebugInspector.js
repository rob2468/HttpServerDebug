
function getWebViewInfo() {
  const title = document.title || document.location.href;
  const url = document.location.href;
  return { title, url };
}

document.body.style.backgroundColor = '#f00';

window.webkit.messageHandlers.hsdTest.postMessage('abcdefg');
