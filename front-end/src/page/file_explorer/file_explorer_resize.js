/* resize column functions */
var startResizeX;
var startResizeWidth;
var targetResizeEle;

export function initResizeDrag(event) {
    targetResizeEle = event.currentTarget.parentElement;

    // initial value
    startResizeX = event.clientX;
    startResizeWidth = parseInt(document.defaultView.getComputedStyle(targetResizeEle).width, 10);

    document.documentElement.addEventListener('mousemove', doResizeDrag, false);
    document.documentElement.addEventListener('mouseup', stopResizeDrag, false);
}

function doResizeDrag(event) {
    // calculate target element width and modify views
    var sidebarEle = document.getElementById('property-sidebar');
    if (targetResizeEle === sidebarEle) {
        var widthStr = (startResizeWidth - event.clientX + startResizeX) + 'px';
        var fileExpEle = document.getElementById('file-explorer');

        targetResizeEle.style.width = widthStr;
        fileExpEle.style.right = widthStr;
    } else {
        targetResizeEle.style.width = (startResizeWidth + event.clientX - startResizeX) + 'px';
    }

    if (event.preventDefault) {
        event.preventDefault();
    }
}

function stopResizeDrag(event) {
    document.documentElement.removeEventListener('mousemove', doResizeDrag, false);
    document.documentElement.removeEventListener('mouseup', stopResizeDrag, false);
}
