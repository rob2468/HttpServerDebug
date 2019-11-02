import { setCookie } from '../../util/util';
import './index.css';
import '../../common/default.css';

window.onload = function () {
  addEventListener();
};

function addEventListener() {
  const languageEle = document.querySelector('header .container .languages');
  languageEle.addEventListener('mouseover', event => {
    showLanguageList();
  });
  languageEle.addEventListener('mouseout', event => {
    hideLanguageList();
  });
  document.querySelectorAll('header .container .languages ul li').forEach(ele => {
    ele.addEventListener('click', event => {
      selectLanguage(event.target);
    });
  });
}

/**
 * show languages list
 */
export function showLanguageList() {
  const ulEle = document.querySelector('header .languages ul');
  ulEle.setAttribute('class', 'active');
}

/**
 * hide languages list
 */
export function hideLanguageList() {
  const ulEle = document.querySelector('header .languages ul');
  ulEle.setAttribute('class', '');
}

/**
 * switch language
 * @param {HTMLElement} element html element
 */
export function selectLanguage(element) {
  const languageType = element.getAttribute('data-language-type');
  setCookie('languageType', languageType);

  // refresh page
  location.reload(true);
}
