const Language = {
  enus: {
    key: 'enus',
    fileName: 'en-us.js',
  },
  zhcn: {
    key: 'zhcn',
    fileName: 'zh-cn.js',
  }
}

window.onload = function () {
  const lang = localStorage.key('lang');

};

/**
 * show languages list
 */
function showLanguageList() {
  const ulEle = document.querySelector('header .languages ul');
  ulEle.setAttribute('class', 'active');
}

function hideLanguageList() {
  const ulEle = document.querySelector('header .languages ul');
  ulEle.setAttribute('class', '');

}
