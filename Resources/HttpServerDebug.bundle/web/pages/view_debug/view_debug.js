// global variables
var allViewsData;
var selectedID; // view-hierarchy-list active list item id
// default settings
var isClippedContentShown = true;
var isNavigationSidebarShown = true;
var isPropertySidebarShown = false;

// constant variables
var ROOTPATH = 'view_debug';
var ALLVIEWSPATH = 'all_views';
var SELECTVIEWPATH = 'select_view';
var SNAPSHOTPATH = 'snapshot';
var MESHBORDERDEFAULTCOLOR = 0xA9A9A9;      // mesh border default color
var MESHBORDERSELECTEDCOLOR = 0x457CD3;     // mesh border selected color
var kSiderbarWidth = 300;

function requestViewHierarchyData() {
    var viewXHR = new XMLHttpRequest();
    var requestURL = document.location.protocol + '//' + document.location.host
    + '/api/' + ROOTPATH + '/' + ALLVIEWSPATH + '?';
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
        var title = viewData['description'];
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
    + '/api/' + ROOTPATH + '/' + SELECTVIEWPATH + '/' + SNAPSHOTPATH
    + '?memory_address=' + memoryAddress + '&class_name=' + className;

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

    // update list
    var listEle = document.querySelector('#view-property-list');
    while (listEle.firstChild) {
        listEle.removeChild(listEle.firstChild);
    }
    listEle.appendChild(ulEle);
}

requestViewHierarchyData();

// Debug View Hierarchy
/* globals THREE */
var camera;
var cameraDefaultPosition = {x: 0, y: 0, z: 1000000};
var scene;
var renderer;
var controls;
var depthUnit = 50;     // distance between neighboring views

/**
*  construct 3d view hierarchy display canvas
*  @param startIdx
*  use allViewsData array, rendering items in allViewsData, from the startIdx item to the first item with hierarchyDepth == 0 or the last item
*/
function initTHREE(startIdx) {
    var viewItem = allViewsData[startIdx];
    if (viewItem.hierarchyDepth !== 0) {
        console.log('should render from root view');
        return;
    }
    var appWidth = viewItem.clippedFrameRoot.width;
    var appHeight = viewItem.clippedFrameRoot.height;

    var width = document.getElementById('canvas-frame').clientWidth;
    var height = document.getElementById('canvas-frame').clientHeight;
    var scale = 0.8 * height / appHeight;
    scale = scale > 1 ? 1 : scale;

    // renderer
    renderer = new THREE.WebGLRenderer({antialias: true});
    renderer.setSize(width, height);
    renderer.setClearColor(0xFFFFFF, 1.0);
    document.getElementById('canvas-frame').appendChild(renderer.domElement);

    // scene
    scene = new THREE.Scene();

    // camera
    camera = new THREE.OrthographicCamera(- width / 2, width / 2, height / 2, - height / 2, 0, 2000000);
    camera.position.set(cameraDefaultPosition.x, cameraDefaultPosition.y, cameraDefaultPosition.z);
    camera.up.set(0, 1, 0);
    camera.lookAt(new THREE.Vector3(0, 0, 0));

    var allViewsDataLength = allViewsData.length;
    var currentDepth = - allViewsDataLength / 2; // current mesh z axis unit value
    for (var i = startIdx; i < allViewsDataLength; i++) {
        viewItem = allViewsData[i];
        var depth = viewItem.hierarchyDepth;
        var width = viewItem.clippedFrameRoot.width;
        var height = viewItem.clippedFrameRoot.height;

        if (width === 0 && height === 0) {
            // only display visible views
            continue;
        }
        if (depth === 0 && i !== startIdx) {
            // only display first UIWindow
            break;
        }

        // texture
        (function (idx, currentDepth) {
            var viewItem = allViewsData[idx];
            // load a resource
            var imageSRC = 'data:image/png;base64,' + viewItem.snapshotNosub;
            new THREE.TextureLoader().load(
                // resource URL
                imageSRC,
                // onLoad callback
                function (texture) {
                    var x = viewItem.clippedFrameRoot.x;
                    var y = viewItem.clippedFrameRoot.y;
                    var width = viewItem.clippedFrameRoot.width;
                    var height = viewItem.clippedFrameRoot.height;

                    // material
                    var material = new THREE.MeshBasicMaterial({
                        map: texture,
                        transparent: true,
                        side: THREE.DoubleSide,
                        wireframe: false});

                    // geometry
                    var geometry = new THREE.PlaneGeometry(width * scale, height * scale);

                    // mesh
                    var mesh = new THREE.Mesh(geometry, material);
                        mesh.position.set((x + width / 2 - appWidth / 2) * scale,
                        (appHeight / 2 - (y + height / 2)) * scale,
                        currentDepth * depthUnit);

                    // wireframe
                    var geo = new THREE.EdgesGeometry(geometry);
                    var mat = new THREE.LineBasicMaterial({color: MESHBORDERDEFAULTCOLOR, linewidth: 1});
                    var wireframe = new THREE.LineSegments(geo, mat);
                    mesh.add(wireframe);

                    // callback
                    mesh.callback = function () {
                        onViewHierarchyNavigationItemClick(idx + 'th-view');
                    };

                    scene.add(mesh);

                    // add THREE objects to allVIewsData
                    var three = {'mesh': mesh, 'wireframe': wireframe};
                    viewItem.three = three;
                },
                // onProgress callback currently not supported
                undefined,
                // onError callback
                function (err) {
                    console.error('An error happened.');
                }
            );
        })(i, currentDepth);

        // depth +1
        currentDepth++;
    } // for loop, allViewsData

    // OrbitControls
    controls = new THREE.OrbitControls(camera, renderer.domElement);
    controls.autoRotate = false;

    // update input html
    var depthUnitEle = document.querySelector('input[type="range"].depth-unit');
    depthUnitEle.value = depthUnit;
}

function animateTHREE() {
    requestAnimationFrame(animateTHREE);
    controls.update();
    renderer.render(scene, camera);
}

// select mesh
document.addEventListener('click', onDocumentMouseClick, false);

var raycaster = new THREE.Raycaster();
var mouse = new THREE.Vector2();
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
    mouse.x = (clientX - domX - domWidth / 2) / (domWidth / 2);
    mouse.y = (domHeight / 2 - (clientY - domY)) / (domHeight / 2);

    raycaster.setFromCamera(mouse, camera);
    var intersects = raycaster.intersectObjects(scene.children);
    if (intersects.length > 0) {
        intersects[0].object.callback();
    }
}

/* canvas toolbar control */
// range input, value changed
function onDepthUnitChange() {
    var depthUnitEle = document.querySelector('input[type="range"].depth-unit');
    var newDepthUnit = depthUnitEle.value;
    newDepthUnit = parseInt(newDepthUnit, 10);
    if (isNaN(newDepthUnit)) {
        newDepthUnit = depthUnit;
    }
    updateMeshDepthUnit(newDepthUnit);
}

function updateMeshDepthUnit(newDepthUnit) {
    if (newDepthUnit !== depthUnit) {
        newDepthUnit = newDepthUnit < 5 ? 5 : newDepthUnit;
        for (var i = allViewsData.length - 1; i >= 0; i--) {
            var viewItem = allViewsData[i];
            if (viewItem.hasOwnProperty('three')) {
                var mesh = viewItem.three.mesh;
                var tmp = mesh.position.z;
                mesh.position.setZ(newDepthUnit * tmp / depthUnit);
            }
        }
    }
    depthUnit = newDepthUnit;

    // update input html
    var textEle = document.getElementById('depth-unit-text');
    textEle.value = depthUnit;
}

/* orient to 2D or 3D*/
function onOrientTo2DClick() {
    var x = cameraDefaultPosition.x;
    var y = cameraDefaultPosition.y;
    var z = cameraDefaultPosition.z;
    camera.position.set(x, y, z);
    
    // update control tool
    var orient2DEle = document.querySelector('.control-tool.orient-to-2d');
    var orient3DEle = document.querySelector('.control-tool.orient-to-3d');
    orient2DEle.classList.remove('available');
    orient3DEle.classList.add('available');
}

function onOrientTo3DClick() {
    var z = cameraDefaultPosition.z;
    var x = -z * 0.1;
    var y = z * 0.02;
    camera.position.set(x, y, z);

    // update control tool
    var orient2DEle = document.querySelector('.control-tool.orient-to-2d');
    var orient3DEle = document.querySelector('.control-tool.orient-to-3d');
    orient2DEle.classList.add('available');
    orient3DEle.classList.remove('available');
}

function onShowClippedContentClick() {
    var ele = document.querySelector('#canvas-toolbar button.show-clipped-content');

    // update view
    if (isClippedContentShown) {
        // not clip content
        ele.classList.add('selected');
    } else {
        // clip content
        ele.classList.remove('selected');
    }
    
    // update data
    isClippedContentShown = !isClippedContentShown;
}

function onShowNavigationSidebarClick() {
    var navSidebarEle = document.querySelector('.navigation-sidebar');
    var navToolbarEle = document.querySelector('#canvas-toolbar button.navigator-control');
    var toolbarEle = document.querySelector('#canvas-toolbar');

    // update view
    if (isNavigationSidebarShown) {
        // hide
        navSidebarEle.classList.remove('active');
        navToolbarEle.classList.remove('selected');
        toolbarEle.style.left = 0;
    } else {
        // show
        navSidebarEle.classList.add('active');
        navSidebarEle.style.width = kSiderbarWidth + 'px';
        navToolbarEle.classList.add('selected');
        toolbarEle.style.left = kSiderbarWidth + 'px';
    }

    // update data
    isNavigationSidebarShown = !isNavigationSidebarShown;
}

function onShowPropertySidebarClick() {
    var propSidebarEle = document.querySelector('.property-sidebar');
    var propToolbarEle = document.querySelector('#canvas-toolbar button.utilities-control');
    var toolbarEle = document.querySelector('#canvas-toolbar');

    // update view
    if (isPropertySidebarShown) {
        // hide
        propSidebarEle.classList.remove('active');
        propToolbarEle.classList.remove('selected');
        toolbarEle.style.right = 0;
    } else {
        // show
        propSidebarEle.classList.add('active');
        propSidebarEle.style.width = kSiderbarWidth + 'px';
        propToolbarEle.classList.add('selected');
        toolbarEle.style.right = kSiderbarWidth + 'px';
    }

    // update data
    isPropertySidebarShown = !isPropertySidebarShown;
}