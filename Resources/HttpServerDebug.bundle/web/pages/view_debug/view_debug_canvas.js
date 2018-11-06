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

    var appWidth;
    var appHeight;
    var canvasEle = document.querySelector('#canvas-frame');

    // show clipped content or not
    if (isClippedContentShown) {
        appWidth = viewItem.clippedFrameRoot.width;
        appHeight = viewItem.clippedFrameRoot.height;
    } else {
        appWidth = viewItem.frameRoot.width;
        appHeight = viewItem.frameRoot.height;
    }

    var clientWidth = canvasEle.clientWidth;
    var clientHeight = canvasEle.clientHeight;
    var scale = 0.8 * clientHeight / appHeight;
    scale = scale > 1 ? 1 : scale;

    // renderer
    renderer = new THREE.WebGLRenderer({antialias: true});
    renderer.setSize(clientWidth, clientHeight);
    renderer.setClearColor(0xFFFFFF, 1.0);
    canvasEle.appendChild(renderer.domElement);

    // scene
    scene = new THREE.Scene();

    // camera
    camera = new THREE.OrthographicCamera(- clientWidth / 2, clientWidth / 2, clientHeight / 2, - clientHeight / 2, 0, 2000000);
    camera.position.set(CameraDefaultPosition.x, CameraDefaultPosition.y, CameraDefaultPosition.z);
    camera.up.set(0, 1, 0);
    camera.lookAt(new THREE.Vector3(0, 0, 0));

    // OrbitControls
    controls = new THREE.OrbitControls(camera, renderer.domElement);
    controls.autoRotate = false;
    controls.enableZoom = false;
    controls.addEventListener('end', function () {
        onOrbitControlsEnd();
    });

    // axes helper
    // var axesHelper = new THREE.AxesHelper(height / 2);
    // scene.add(axesHelper);

    var allViewsDataLength = allViewsData.length;
    var currentDepth = - allViewsDataLength / 2; // current mesh z axis unit value
    var depth;
    var width;
    var height;
    for (var i = startIdx; i < allViewsDataLength; i++) {
        viewItem = allViewsData[i];
        depth = viewItem.hierarchyDepth;

        // show clipped content or not
        if (isClippedContentShown) {
            width = viewItem.clippedFrameRoot.width;
            height = viewItem.clippedFrameRoot.height;
        } else {
            width = viewItem.frameRoot.width;
            height = viewItem.frameRoot.height;
        }

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
            var memoryAddress = viewItem.memoryAddress;
            var className = viewItem.className;
            var clippedOrigin = viewItem.clippedOrigin;
            var clippedFrameRoot = viewItem.clippedFrameRoot;
            var frameRoot = viewItem.frameRoot;
            var x;
            var y;
            var width;
            var height;

            // snapshot image
            var imageSRC = document.location.protocol + '//' + document.location.host
            + '/api/view_debug?action=select_view&subaction=snapshot&memory_address=' + memoryAddress
            + '&class_name=' + className + '&nosubviews=1';

            // show clipped content or not
            if (isClippedContentShown) {
                imageSRC += '&frame=' + clippedOrigin.x + ',' + clippedOrigin.y + ',' + clippedFrameRoot.width + ',' + clippedFrameRoot.height;

                x = clippedFrameRoot.x;
                y = clippedFrameRoot.y;
                width = clippedFrameRoot.width;
                height = clippedFrameRoot.height;
            } else {
                x = frameRoot.x;
                y = frameRoot.y;
                width = frameRoot.width;
                height = frameRoot.height;
            }

            // load
            new THREE.TextureLoader().load(
                // resource URL
                imageSRC,
                // onLoad callback
                function (texture) {
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
                    var wireframeGeometry = new THREE.EdgesGeometry(geometry);
                    var wireframeMaterial = new THREE.LineBasicMaterial({color: MESHBORDERDEFAULTCOLOR, linewidth: 1});
                    var wireframe = new THREE.LineSegments(wireframeGeometry, wireframeMaterial);
                    mesh.add(wireframe);

                    // callback
                    mesh.callback = function () {
                        onViewHierarchyNavigationItemClick(idx + 'th-view');
                    };

                    scene.add(mesh);

                    // add THREE objects to allVIewsData
                    var three = {'texture': texture,
                                'material': material,
                                'geometry': geometry,
                                'mesh': mesh,
                                'wireframe_geo': wireframeGeometry,
                                'wireframe_mat': wireframeMaterial,
                                'wireframe': wireframe};
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

function deallocTHREE() {
    var allViewsDataCount = allViewsData.length;
    var viewItem;
    var three;
    var texture;
    var material;
    var geometry;
    var mesh;
    var wireframeGeometry;
    var wireframeMaterial;
    var wireframe;

    for (var i = 0; i < allViewsDataCount; i++) {
        viewItem = allViewsData[i];
        three = viewItem.three;

        if (three) {
            // parse cached three data
            texture = three.texture;
            material = three.material;
            geometry = three.geometry;
            mesh = three.mesh;
            wireframeGeometry = three.wireframe_geo;
            wireframeMaterial = three.wireframe_mat;
            wireframe = three.wireframe;

            // remove from scene
            scene.remove(mesh);

            // clean up
            texture.dispose();
            material.dispose();
            geometry.dispose();
            wireframeGeometry.dispose();
            wireframeMaterial.dispose();
            // wireframe.dispose();

            viewItem.three = null;
        }
    }

    controls.dispose();
    renderer.dispose();

    controls = null;
    camera = null;
    scene = null;
    renderer = null;
}

/* click canvas */
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

/* show clipped content */
function onShowClippedContentClick() {
    var ele = document.querySelector('#canvas-toolbar button.show-clipped-content');

    // update data
    isClippedContentShown = !isClippedContentShown;

    // update controls
    if (isClippedContentShown) {
        // not clip content
        ele.classList.add('selected');
    } else {
        // clip content
        ele.classList.remove('selected');
    }

    // remove canvas element
    var canvasEle = document.querySelector('#canvas-frame');
    canvasEle.removeChild(renderer.domElement);

    // update three
    deallocTHREE();
    initTHREE(0);
}

/* orient to 2D or 3D */
function onOrientTo2DClick() {
    controls.reset();

    var x = CameraDefaultPosition.x;
    var y = CameraDefaultPosition.y;
    var z = CameraDefaultPosition.z;
    camera.position.set(x, y, z);

    // update control tool
    updateOrientButtonsTo2D(false);
}

function onOrientTo3DClick() {
    controls.reset();

    var z = CameraDefaultPosition.z;
    var x = -z * 0.1;
    var y = z * 0.02;
    camera.position.set(x, y, z);

    // update control tool
    updateOrientButtonsTo2D(true);
}

function updateOrientButtonsTo2D(orientTo2D) {
    var orient2DEle = document.querySelector('.control-tool.orient-to-2d');
    var orient3DEle = document.querySelector('.control-tool.orient-to-3d');
    if (orientTo2D) {
        // orient to 2D
        orient2DEle.classList.add('available');
        orient3DEle.classList.remove('available');
    } else {
        // orient to 3D
        orient2DEle.classList.remove('available');
        orient3DEle.classList.add('available');
    }
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
    new TWEEN.Tween({ zoom: currentZoom })
    .to({ zoom: targetZoom }, 300)     // animate, value and duration
    .easing(TWEEN.Easing.Quadratic.Out)
    .onUpdate(function () {
        // modify camera zoom value
        var zoom = this.zoom;
        camera.zoom = zoom;
        camera.updateProjectionMatrix();
    })
    .start();
}

/* OrbitControls end event */
function onOrbitControlsEnd() {
    var currentPos = camera.position;
    if (Math.abs(currentPos.x / currentPos.z) < 0.1 &&
        Math.abs(currentPos.y / currentPos.z) < 0.02) {
        // orient to 2D
        new TWEEN.Tween({ x: currentPos.x, y: currentPos.y, z: currentPos.z })
        .to(CameraDefaultPosition, 300)
        .easing(TWEEN.Easing.Quadratic.Out)
        .onUpdate(function () {
            // camera
            var x = this.x;
            var y = this.y;
            var z = this.z;
            camera.position.set(x, y, z);

            // buttons
            if (x === CameraDefaultPosition.x &&
                y === CameraDefaultPosition.y &&
                z === CameraDefaultPosition.z) {
                updateOrientButtonsTo2D(false);
            }
        })
        .start();
    } else {
        // 3D
        // buttons
        updateOrientButtonsTo2D(true);
    }
}

/* requestAnimationFrame */
function animateTHREE() {
    TWEEN.update();
    controls.update();
    renderer.render(scene, camera);
    requestAnimationFrame(animateTHREE);
}
