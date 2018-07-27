(function sideBarAdjust() {
    // sidebar
    var navSideBarEle = document.querySelector('.navigation-sidebar');
    var navSplitHandlerEle = navSideBarEle.getElementsByClassName('split-handler')[0];
    var propertySideBarEle = document.getElementsByClassName('property-sidebar')[0];
    var propertySplitHandlerEle = propertySideBarEle.getElementsByClassName('split-handler')[0];
    // toolbar
    var toolbarEle = document.querySelector('#canvas-toolbar');

    // addEventListener
    navSplitHandlerEle.addEventListener('mousedown', initDrag, false);
    propertySplitHandlerEle.addEventListener('mousedown', initDrag, false);

    var startX;
    var startWidth;
    var sideBarEle;
    var splitHandlerEle;
    function initDrag(e) {
        // initialize data
        splitHandlerEle = e.currentTarget;
        if (splitHandlerEle === navSplitHandlerEle) {
            sideBarEle = navSideBarEle;
        } else {
            sideBarEle = propertySideBarEle;
        }
        startX = e.clientX;
        startWidth = parseInt(document.defaultView.getComputedStyle(sideBarEle).width, 10);

        // addEventListener
        document.documentElement.addEventListener('mousemove', doDrag, false);
        document.documentElement.addEventListener('mouseup', stopDrag, false);
    }

    function doDrag(e) {
        var offset = e.clientX - startX;
        var length;
        if (sideBarEle === navSideBarEle) {
            // navigation siderbar
            length = startWidth + offset
            sideBarEle.style.width = length + 'px';
            toolbarEle.style.left = length + 'px';
        } else {
            // property siderbar
            length = startWidth - offset;
            sideBarEle.style.width = length + 'px';
            toolbarEle.style.right = length + 'px';
        }

        if (e.preventDefault) {
            e.preventDefault();
        }
    }

    function stopDrag(e) {
        document.documentElement.removeEventListener('mousemove', doDrag, false);
        document.documentElement.removeEventListener('mouseup', stopDrag, false);
    }
})();