function submitForm() {
    var infoStr = document.getElementById('info_textarea').value.trim();

    var infoXHR = new XMLHttpRequest();
    var requestURL = `${document.location.protocol}//${document.location.host}/api/send_info`;
    infoXHR.open('POST', requestURL);
    infoXHR.onload = function () {
        if (infoXHR.status === 200) {
            var responseText = infoXHR.responseText;
            var responseEle = document.getElementById('response_data');
            responseEle.innerText = responseText;
        }
    };
    infoXHR.send(infoStr);
}
