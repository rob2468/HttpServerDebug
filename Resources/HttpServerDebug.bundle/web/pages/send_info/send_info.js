function submitForm() {
  const infoStr = document.getElementById('info_textarea').value.trim();

  const infoXHR = new XMLHttpRequest();
  const requestURL = `${document.location.protocol}//${document.location.host}/api/send_info`;
  infoXHR.open('POST', requestURL);
  infoXHR.onload = function () {
  if (infoXHR.status === 200) {
    const responseText = infoXHR.responseText;
    const responseEle = document.getElementById('response_data');
    responseEle.innerText = responseText;
    }
  };
  infoXHR.send(infoStr);
}
