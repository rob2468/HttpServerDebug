import { initTHREE } from './view_debug_canvas';
import { initSideBarAdjust } from './view_debug_sidebar';
import './view_debug.css'

/* global variables */
var allViewsData;
var selectedID; // view-hierarchy-list active list item id

// default settings
var isClippedContentShown = true;

// constant variables
const MESHBORDERDEFAULTCOLOR = 0xA9A9A9;      // mesh border default color
const MESHBORDERSELECTEDCOLOR = 0x457CD3;     // mesh border selected color
const kSiderbarWidth = 300;
const kNavigationSidebarShownKey = 'kNavigationSidebarShownKey';
const kPropertySidebarShownKey = 'kPropertySidebarShownKey';
const kViewDataKeyDescription = 'description';
const kViewDataKeyParent = 'parent';

/* THREE */
var camera;
var CameraDefaultPosition = {x: 0, y: 0, z: 1000000};
var scene;
var renderer;
var controls;
var depthUnit = 20;     // distance between neighboring views
var raycaster = new THREE.Raycaster();

window.onload = function () {
  // request data
  requestViewHierarchyData();

  // sidebar
  initSideBarAdjust();

  // add click event listener
  document.addEventListener('click', onDocumentMouseClick, false);

  // navigation sidebar
  var isNavigationSidebarShown = this.localStorage.getItem(kNavigationSidebarShownKey);
  if (!isNavigationSidebarShown) {
    // default shown
    isNavigationSidebarShown = '1';
    this.localStorage.setItem(kNavigationSidebarShownKey, isNavigationSidebarShown);
  }
  if (isNavigationSidebarShown === '0') {
    showNavigationSidebar(false);
  } else {
    showNavigationSidebar(true);
  }

  // property sidebar
  var isPropertySidebarShown = this.localStorage.getItem(kPropertySidebarShownKey);
  if (!isPropertySidebarShown) {
    // default hidden
    isPropertySidebarShown = '0';
    this.localStorage.setItem(kPropertySidebarShownKey, isPropertySidebarShown);
  }
  if (isPropertySidebarShown === '0') {
    showPropertySidebar(false);
  } else {
    showPropertySidebar(true);
  }
};

function requestViewHierarchyData() {
  var viewXHR = new XMLHttpRequest();
  var requestURL = document.location.protocol + '//' + document.location.host
  + '/api/view_debug?action=all_views';
  viewXHR.open('GET', requestURL);
  viewXHR.onload = function () {
    if (viewXHR.status === 200) {
      var responseText = viewXHR.responseText;
      allViewsData = JSON.parse(responseText);

      // construct h5 views with app views data
      generateViewHierarchyListHTML();
      initTHREE(0);
      animateTHREE();
    }
  };
  viewXHR.send(null);
}

function onViewHierarchyNavigationItemClick(id) {
  if (selectedID === id) {
    return;
  }

  var event = window.event;
  event.stopPropagation();

  // update selected state
  if (selectedID) {
    // update navigation
    var oldEle = document.getElementById(selectedID);
    oldEle.classList.remove('active');
    // update canvas
    var oldIdx = parseInt(selectedID, 10);
    var oldViewData = allViewsData[oldIdx];
    if (oldViewData.hasOwnProperty('three')) {
      oldViewData.three.wireframe.material.color.setHex(MESHBORDERDEFAULTCOLOR);
    }
  }
  var curEle = document.getElementById(id);
  curEle.classList.add('active');
  selectedID = id;

  // parse data
  var index = parseInt(id, 10);
  var viewData = allViewsData[index];

  // update canvas
  if (viewData.hasOwnProperty('three')) {
    viewData.three.wireframe.material.color.setHex(MESHBORDERSELECTEDCOLOR);
  }

  // update navigation toolbar
  generateNavigationToolbarHTML(viewData);

  // update property list
  generateViewPropertyListHTML(viewData);
}

function generateViewHierarchyListHTML() {
  var ulEle = document.createElement('ul');
  var liEle;
  var spanEle;
  var tmpSpanEle;
  var j;
  for (var i = 0; i < allViewsData.length; i++) {
    // parse data
    var viewData = allViewsData[i];
    var title = viewData[kViewDataKeyDescription];
    var depth = viewData['hierarchyDepth'];

    // create li element
    liEle = document.createElement('li');
    liEle.setAttribute('id', i + 'th-view');
    liEle.onclick = function () {
      onViewHierarchyNavigationItemClick(this.id);
    }

    // create span element recursively
    spanEle = document.createElement('span');
    liEle.appendChild(spanEle);
    j = depth;
    while (j > 0) {
      tmpSpanEle = document.createElement('span');
      spanEle.appendChild(tmpSpanEle);
      spanEle = tmpSpanEle;
      j--;
    }
    spanEle.innerHTML = title;

    ulEle.appendChild(liEle);
  }

  // update list
  var listEle = document.querySelector('#view-hierarchy-list');
  while (listEle.firstChild) {
    listEle.removeChild(listEle.firstChild);
  }
  listEle.appendChild(ulEle);
}

function generateNavigationToolbarHTML(viewData) {
  const navToolbarEle = document.querySelector('.navigation-toolbar');
  // remove all HTMLElement
  while (navToolbarEle.firstChild) {
    navToolbarEle.removeChild(navToolbarEle.firstChild);
  }

  let guardViewData = viewData;
  while (guardViewData) {
    // create HTMLElement item
    const itemEle = document.createElement('div');
    itemEle.setAttribute('class', 'item');
    const title = guardViewData[kViewDataKeyDescription];
    itemEle.innerHTML = title;

    // add HTMLElement item
    if (navToolbarEle.firstChild) {
      navToolbarEle.insertBefore(itemEle, navToolbarEle.firstChild);
    } else {
      navToolbarEle.appendChild(itemEle);
    }

    // prev item
    const parentIdx = guardViewData[kViewDataKeyParent];
    if (parentIdx >= 0) {
      guardViewData = allViewsData[parentIdx];
    } else {
      guardViewData = null;
    }
  }
}

function generateViewPropertyListHTML(viewData) {
  // parse data
  var memoryAddress = viewData['memoryAddress'];
  var className = viewData['className'];
  var frame = viewData['frame'];
  var bounds = viewData['bounds'];
  var position = viewData['position'];
  var zPosition = viewData['zPosition'];
  var contentMode = viewData['contentMode'];
  var tag = viewData['tag'];
  var isUserInteractionEnabled = viewData['isUserInteractionEnabled'];
  var isMultipleTouchEnabled = viewData['isMultipleTouchEnabled'];
  var isHidden = viewData['isHidden'];
  var isOpaque = viewData['isOpaque'];
  var clipsToBounds = viewData['clipsToBounds'];
  var autoresizesSubviews = viewData['autoresizesSubviews'];
  var layerMemoryAddress = viewData['layerMemoryAddress'];
  var layerClassName = viewData['layerClassName'];
  var alpha = viewData['alpha'];
  var backgroundColor = viewData['backgroundColor'];

  var ulEle = document.createElement('ul');
  var liEle;
  var divEle;
  // Class Name
  liEle = document.createElement('li');
  liEle.innerHTML = 'Class Name: ' + className;
  ulEle.appendChild(liEle);

  // Address
  liEle = document.createElement('li');
  liEle.innerHTML = 'Address: ' + memoryAddress;
  ulEle.appendChild(liEle);

  ulEle.appendChild(document.createElement('hr'));

  // layerMemoryAddress
  liEle = document.createElement('li');
  liEle.innerHTML = 'Layer: ' + layerMemoryAddress;
  ulEle.appendChild(liEle);

  // layerClassName
  liEle = document.createElement('li');
  liEle.innerHTML = 'Layer Class: ' + layerClassName;
  ulEle.appendChild(liEle);

  ulEle.appendChild(document.createElement('hr'));

  // Content Mode
  liEle = document.createElement('li');
  liEle.innerHTML = 'Content Mode: ' + contentMode;
  ulEle.appendChild(liEle);

  // Tag
  liEle = document.createElement('li');
  liEle.innerHTML = 'Tag: ' + tag;
  ulEle.appendChild(liEle);

  // isUserInteractionEnabled
  liEle = document.createElement('li');
  liEle.innerHTML = 'isUserInteractionEnabled: ' + (isUserInteractionEnabled ? 'YES' : 'NO');
  ulEle.appendChild(liEle);

  // isMultipleTouchEnabled
  liEle = document.createElement('li');
  liEle.innerHTML = 'isMultipleTouchEnabled: ' + (isMultipleTouchEnabled ? 'YES' : 'NO');
  ulEle.appendChild(liEle);

  // alpha
  liEle = document.createElement('li');
  liEle.innerHTML = 'Alpha: ' + alpha;
  ulEle.appendChild(liEle);

  // backgroundColor
  var red = backgroundColor['r'];
  if (typeof red === 'string') {
    // background color description
    liEle = document.createElement('li');
    liEle.innerHTML = 'Background: ' + red;
    ulEle.appendChild(liEle);
  } else {
    // rgba data
    var green = backgroundColor['g'];
    var blue = backgroundColor['b'];
    var alpha = backgroundColor['a'];
    var rgba = 'rgba(' + red + ', ' + green + ', ' + blue + ', ' + alpha + ')';

    liEle = document.createElement('li');
    liEle.innerHTML = 'Background: ' + rgba;
    ulEle.appendChild(liEle);

    divEle = document.createElement('div');
    divEle.setAttribute('style', 'display:inline-block;width:80px;height:17px;'
    + 'background-color:' + rgba + ';');

    liEle = document.createElement('li');
    liEle.appendChild(divEle);
    ulEle.appendChild(liEle);
  }

  ulEle.appendChild(document.createElement('hr'));

  // isHidden
  liEle = document.createElement('li');
  liEle.innerHTML = 'isHidden: ' + (isHidden ? 'YES' : 'NO');
  ulEle.appendChild(liEle);

  // isOpaque
  liEle = document.createElement('li');
  liEle.innerHTML = 'isOpaque: ' + (isOpaque ? 'YES' : 'NO');
  ulEle.appendChild(liEle);

  // clipsToBounds
  liEle = document.createElement('li');
  liEle.innerHTML = 'clipsToBounds: ' + (clipsToBounds ? 'YES' : 'NO');
  ulEle.appendChild(liEle);

  // autoresizesSubviews
  liEle = document.createElement('li');
  liEle.innerHTML = 'autoresizesSubviews: ' + (autoresizesSubviews ? 'YES' : 'NO');
  ulEle.appendChild(liEle);

  ulEle.appendChild(document.createElement('hr'));

  // Frame
  liEle = document.createElement('li');
  liEle.innerHTML = 'Frame: {{' + frame.x + ', ' + frame.y
  + '}, {' + frame.width + ', ' + frame.height + '}}';
  ulEle.appendChild(liEle);

  // Bounds
  liEle = document.createElement('li');
  liEle.innerHTML = 'Bounds: {{' + bounds.x + ', ' + bounds.y
  + '}, {' + bounds.width + ', ' + bounds.height + '}}';
  ulEle.appendChild(liEle);

  // Position
  liEle = document.createElement('li');
  liEle.innerHTML = 'Position: {' + position.x + ', ' + position.y + '}';
  ulEle.appendChild(liEle);

  // Z Position
  liEle = document.createElement('li');
  liEle.innerHTML = 'Z Position: ' + zPosition;
  ulEle.appendChild(liEle);

  ulEle.appendChild(document.createElement('hr'));

  // Snapshot
  var imgURL = document.location.protocol + '//' + document.location.host
  + '/api/view_debug?action=select_view&subaction=snapshot&memory_address=' + memoryAddress
  + '&class_name=' + className + '&nosubviews=0';

  liEle = document.createElement('li');

  divEle = document.createElement('div');
  divEle.innerHTML = 'Snapshot: ';
  liEle.appendChild(divEle);

  divEle = document.createElement('div');
  var snapshotImgEle = document.createElement('img');
  snapshotImgEle.setAttribute('id', 'view-property-snapshot');
  snapshotImgEle.setAttribute('alt', '');
  snapshotImgEle.setAttribute('src', imgURL);
  divEle.appendChild(snapshotImgEle);
  liEle.appendChild(divEle);

  ulEle.appendChild(liEle);

  // remove not applicable element
  const notApplicableEle = document.querySelector('.property-sidebar .container .not-applicable');
  if (notApplicableEle) {
    const containerEle = document.querySelector('.property-sidebar .container');
    containerEle.removeChild(notApplicableEle);
  }

  // update list
  var listEle = document.querySelector('.view-property-list');
  while (listEle.firstChild) {
    listEle.removeChild(listEle.firstChild);
  }
  listEle.appendChild(ulEle);
}

function onDocumentMouseClick(event) {
  // origin data
  var domRect = renderer.domElement.getBoundingClientRect();
  var domX = domRect.x;
  var domY = domRect.y;
  var clientX = event.clientX;
  var clientY = event.clientY;
  var domWidth = renderer.domElement.clientWidth;
  var domHeight = renderer.domElement.clientHeight;

  if (clientX < domX || clientX > domX + domWidth
  || clientY < domY || clientY > domY + domHeight) {
      // click postion out of canvas
      return;
  }

  event.preventDefault();

  // coordinate in THREE.js world
  var mouse = new THREE.Vector2();
  mouse.x = (clientX - domX - domWidth / 2) / (domWidth / 2);
  mouse.y = (domHeight / 2 - (clientY - domY)) / (domHeight / 2);
  onCanvasClick(mouse);
}

function onShowNavigationSidebarClick() {
  var isNavigationSidebarShown = localStorage.getItem(kNavigationSidebarShownKey);
  if (!isNavigationSidebarShown) {
      isNavigationSidebarShown = '0';
  }

  var show;
  if (isNavigationSidebarShown === '0') {
      show = true;
      isNavigationSidebarShown = '1';
  } else {
      show = false;
      isNavigationSidebarShown = '0';
  }

  showNavigationSidebar(show);

  // update local data
  localStorage.setItem(kNavigationSidebarShownKey, isNavigationSidebarShown);
}

function onShowPropertySidebarClick() {
  var isPropertySidebarShown = localStorage.getItem(kPropertySidebarShownKey);
  if (!isPropertySidebarShown) {
    isPropertySidebarShown = '0';
  }

  var show;
  if (isPropertySidebarShown === '0') {
    show = true;
    isPropertySidebarShown = '1';
  } else {
    show = false;
    isPropertySidebarShown = '0';
  }

  showPropertySidebar(show);

  // update local data
  localStorage.setItem(kPropertySidebarShownKey, isPropertySidebarShown);
}

function showNavigationSidebar(show) {
  const navSidebarEle = document.querySelector('.navigation-sidebar');
  const navToolbarEle = document.querySelector('.navigation-toolbar');
  const navCanvasToolbarEle = document.querySelector('#canvas-toolbar button.navigator-control');
  const canvasToolbarEle = document.querySelector('#canvas-toolbar');

  // update view
  if (show) {
    // show
    navSidebarEle.classList.add('active');
    navSidebarEle.style.width = kSiderbarWidth + 'px';
    navToolbarEle.style.left = kSiderbarWidth + 'px';
    navCanvasToolbarEle.classList.add('selected');
    canvasToolbarEle.style.left = kSiderbarWidth + 'px';
  } else {
    // hide
    navSidebarEle.classList.remove('active');
    navToolbarEle.style.left = 0;
    navCanvasToolbarEle.classList.remove('selected');
    canvasToolbarEle.style.left = 0;
  }
}

function showPropertySidebar(show) {
  const propSidebarEle = document.querySelector('.property-sidebar');
  const navToolbarEle = document.querySelector('.navigation-toolbar');
  const propCanvasToolbarEle = document.querySelector('#canvas-toolbar button.utilities-control');
  const canvasToolbarEle = document.querySelector('#canvas-toolbar');

  // update view
  if (show) {
    // show
    propSidebarEle.classList.add('active');
    propSidebarEle.style.width = kSiderbarWidth + 'px';
    navToolbarEle.style.right = kSiderbarWidth + 'px';
    propCanvasToolbarEle.classList.add('selected');
    canvasToolbarEle.style.right = kSiderbarWidth + 'px';
  } else {
    // hide
    propSidebarEle.classList.remove('active');
    navToolbarEle.style.right = 0;
    propCanvasToolbarEle.classList.remove('selected');
    canvasToolbarEle.style.right = 0;
  }
}
