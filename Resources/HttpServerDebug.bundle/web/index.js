const Languages = {
  zhcn: {
    languageName: '简体中文',
    fileName: 'zh-cn.js',
  },
  enus: {
    languageName: 'English',
    fileName: 'en-us.js',
  },
}

window.onload = function () {
  // let languageType = getCookie('languageType');
  // languageType = languageType || 'zhcn';
  // const languageName = Languages[languageType].languageName;

};

/**
 * show languages list
 */
function showLanguageList() {
  const ulEle = document.querySelector('header .languages ul');
  ulEle.setAttribute('class', 'active');
}

/**
 * hide languages list
 */
function hideLanguageList() {
  const ulEle = document.querySelector('header .languages ul');
  ulEle.setAttribute('class', '');
}

/**
 * switch language
 * @param {HTMLElement} element html element
 */
function selectLanguage(element) {
  const languageType = element.getAttribute('data-language-type');
  setCookie('languageType', languageType);

  // refresh page
  location.reload(true);
}
