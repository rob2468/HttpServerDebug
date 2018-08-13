// Debug View Hierarchy
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
    camera.position.set(CameraDefaultPosition.x, CameraDefaultPosition.y, CameraDefaultPosition.z);
    camera.up.set(0, 1, 0);
    camera.lookAt(new THREE.Vector3(0, 0, 0));

    // OrbitControls
    controls = new THREE.OrbitControls(camera, renderer.domElement);
    controls.autoRotate = false;
    controls.enableZoom = false;

    // axes helper
    // var axesHelper = new THREE.AxesHelper(height / 2);
    // scene.add(axesHelper);

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

    // update input html
    var depthUnitEle = document.querySelector('input[type="range"].depth-unit');
    depthUnitEle.value = depthUnit;
}

/**
 *  select mesh
 */
function onCanvasClick(mouseVec) {
    raycaster.setFromCamera(mouseVec, camera);
    var intersects = raycaster.intersectObjects(scene.children);
    if (intersects.length > 0) {
        intersects[0].object.callback();
    }
}

function animateTHREE() {
    TWEEN.update();
    controls.update();
    renderer.render(scene, camera);
    requestAnimationFrame(animateTHREE);
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
}

/* orient to 2D or 3D */
function onOrientTo2DClick() {
    controls.reset();

    var x = CameraDefaultPosition.x;
    var y = CameraDefaultPosition.y;
    var z = CameraDefaultPosition.z;
    camera.position.set(x, y, z);

    // update control tool
    var orient2DEle = document.querySelector('.control-tool.orient-to-2d');
    var orient3DEle = document.querySelector('.control-tool.orient-to-3d');
    orient2DEle.classList.remove('available');
    orient3DEle.classList.add('available');
}

function onOrientTo3DClick() {
    controls.reset();

    var z = CameraDefaultPosition.z;
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

/* Zoom */
function onZoomOutClick() {
    var targetZoom = camera.zoom * 0.9;     // end value
    zoomCameraAnimated(targetZoom);
}

function onActualSizeClick() {
    var targetZoom = 1;                     // end value
    zoomCameraAnimated(targetZoom);
}

function onZoomInClick() {
    var targetZoom = camera.zoom * 1.1;     // end value
    zoomCameraAnimated(targetZoom);
}

function zoomCameraAnimated(targetZoom) {
    var currentZoom = camera.zoom;          // start value
    var tween = new TWEEN.Tween({ zoom: currentZoom })
        .to({ zoom: targetZoom }, 300)     // animate, value and duration
        .easing(TWEEN.Easing.Quadratic.Out)
        .onUpdate(function() {
            // modify camera zoom value
            var zoom = this.zoom;
            camera.zoom = zoom;
            camera.updateProjectionMatrix();
        })
        .start();
}
