function initContextMenu() {
    /* custom context menu */

    /**
     * Function to check if we clicked inside an element with a particular class
     * name.
     *
     * @param {Object} e The event
     * @param {String} className The class name to check against
     * @return {Boolean}
     */
    function clickInsideElement(e, className) {
        var ele = e.srcElement || e.target;

        if (ele.classList.contains(className)) {
            return ele;
        } else {
            while (ele = ele.parentNode) {
                if (ele.classList && ele.classList.contains(className)) {
                    return ele;
                }
            }
        }
        return false;
    }

    /**
     * Get's exact position of event.
     *
     * @param {Object} e The event passed in
     * @return {Object} Returns the x and y position
     */
    function getPosition(e) {
        var posx = 0;
        var posy = 0;

        if (!e) {
            var e = window.event;
        }

        if (e.pageX || e.pageY) {
            posx = e.pageX;
            posy = e.pageY;
        } else if (e.clientX || e.clientY) {
            posx = e.clientX + document.body.scrollLeft + document.documentElement.scrollLeft;
            posy = e.clientY + document.body.scrollTop + document.documentElement.scrollTop;
        }

        return {
            x: posx,
            y: posy
        };
    }

    /**
     * Variables.
     */
    var contextMenuClassName = 'context-menu';
    var contextMenuItemClassName = 'context-menu-item';
    var contextMenuLinkClassName = 'context-menu-link';
    var contextMenuActive = 'context-menu-active';

    var fileItemClassName = 'file-item';
    var fileItemInContext;

    var clickCoords;
    var clickCoordsX;
    var clickCoordsY;

    var menu = document.querySelector('#context-menu');
    var menuItems = menu.querySelectorAll('.context-menu-item');
    var menuState = 0;
    var menuWidth;
    var menuHeight;
    var menuPosition;
    var menuPositionX;
    var menuPositionY;

    var windowWidth;
    var windowHeight;

    /**
     * Initialise our application's code.
     */
    function init() {
        contextListener();
        clickListener();
        keyupListener();
        resizeListener();
    }

    /**
     * Listens for contextmenu events.
     */
    function contextListener() {
        document.addEventListener('contextmenu', function(e) {
            fileItemInContext = clickInsideElement(e, fileItemClassName);
            if (fileItemInContext) {
                e.preventDefault();
                toggleMenuOn();
                positionMenu(e);
            } else {
                fileItemInContext = null;
                toggleMenuOff();
            }
        });
    }

    /**
     * Listens for click events.
     */
    function clickListener() {
        document.addEventListener('click', function(e) {
            var clickeElIsLink = clickInsideElement(e, contextMenuLinkClassName);

            if (clickeElIsLink) {
                e.preventDefault();
                menuItemListener(clickeElIsLink);
            } else {
                var button = e.which || e.button;
                if (button === 1) {
                    toggleMenuOff();
                }
            }
        });
    }

    /**
     * Listens for keyup events.
     */
    function keyupListener() {
        window.onkeyup = function(e) {
            if (e.keyCode === 27) {
                // esc
                toggleMenuOff();
            }
        }
    }

    /**
     * Window resize event listener
     */
    function resizeListener() {
        window.onresize = function(e) {
            toggleMenuOff();
        };
    }

    /**
     * Turns the custom context menu on.
     */
    function toggleMenuOn() {
        if (menuState !== 1) {
            menuState = 1;
            menu.classList.add(contextMenuActive);
        }
    }

    /**
     * Turns the custom context menu off.
     */
    function toggleMenuOff() {
        if (menuState !== 0) {
            menuState = 0;
            menu.classList.remove(contextMenuActive);
        }
    }

    /**
     * Positions the menu properly.
     *
     * @param {Object} e The event
     */
    function positionMenu(e) {
        clickCoords = getPosition(e);
        clickCoordsX = clickCoords.x;
        clickCoordsY = clickCoords.y;

        menuWidth = menu.offsetWidth + 4;
        menuHeight = menu.offsetHeight + 4;

        windowWidth = window.innerWidth;
        windowHeight = window.innerHeight;

        if ((windowWidth - clickCoordsX) < menuWidth) {
            menu.style.left = windowWidth - menuWidth + 'px';
        } else {
            menu.style.left = clickCoordsX + 'px';
        }

        if ((windowHeight - clickCoordsY) < menuHeight) {
            menu.style.top = windowHeight - menuHeight + 'px';
        } else {
            menu.style.top = clickCoordsY + 'px';
        }
    }

    /**
     *  Action function when a menu item link is clicked
     *
     * @param {HTMLElement} link The link that was clicked
     */
    function menuItemListener(link) {
        // parse data
        var action = link.getAttribute('data-action');
        var viewItem = parseDataOfElement(fileItemInContext);
        var dataItem = viewItem.item;
        var section = viewItem.section;

        var isDir = dataItem.is_directory;
        var fileName = dataItem.file_name;
        var filePath = dataItem.file_path;

        if (action === 'open') {
            // open file or directory
            onItemDoubleClicked(fileItemInContext);
        } else if (action === 'download') {
            // download file or directory
            // download url
            var url = window.location.origin + '/api/file_preview?file_path=' + filePath;

            // create event
            var event = new MouseEvent('click');

            // create a element
            var aEle = document.createElement('a');
            aEle.download = fileName;
            aEle.href = url;

            // dispatch event
            aEle.dispatchEvent(event);
        } else if (action === 'delete') {
            // delete file or directory
            var deleteXHR = new XMLHttpRequest();
            var requestURL = document.location.protocol + '//' + document.location.host
            + '/api/file_explorer?file_path=' + encodeURIComponent(filePath) + '&action=delete';
            deleteXHR.open('GET', requestURL);
            deleteXHR.onload = function () {
                if (deleteXHR.status === 200) {
                    var responseText = deleteXHR.responseText;
                    var responseJSON = JSON.parse(responseText);

                    var errno = responseJSON.errno;
                    if (errno !== 0) {
                        // delete failed
                        alert('删除失败');
                    }

                    // refresh
                    if (section === 0) {
                        openRootDirectory();
                    } else {
                        // previous directory
                        var refreshSection = section - 1;
                        var directoryContainer = allData[refreshSection];

                        var refreshRow = directoryContainer.selectedIdx;
                        var refreshItem = directoryContainer.getSelectedItem();

                        var viewItem = new ItemViewModel(refreshItem, refreshSection, refreshRow);
                        openFileOrDirectory(viewItem);
                    }
                }
            };
            deleteXHR.send(null);
        }
        toggleMenuOff();
    }

    /**
     * Run the app.
     */
    init();
}
