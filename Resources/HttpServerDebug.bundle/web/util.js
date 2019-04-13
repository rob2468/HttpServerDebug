/**
 * parse language type
 */
function getLanguageType() {
  let languageType = getCookie('languageType');
  languageType = languageType || 'zhcn';
  return languageType;
}

/**
 * set cookie
 * @param {string} cname key
 * @param {string} cvalue value
 * @param {number} exdays expire days
 */
function setCookie(cname, cvalue, exdays = 365) {
  var d = new Date();
  d.setTime(d.getTime() + (exdays * 24 * 60 * 60 * 1000));
  var expires = 'expires='+d.toUTCString();
  document.cookie = cname + '=' + cvalue + ';' + expires + ';path=/';
}

/**
 * get cookie
 * @param {string} cname key
 */
function getCookie(cname) {
  var name = cname + '=';
  var ca = document.cookie.split(';');
  for(var i = 0; i < ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == ' ') {
      c = c.substring(1);
    }
    if (c.indexOf(name) == 0) {
      return c.substring(name.length, c.length);
    }
  }
  return '';
}
