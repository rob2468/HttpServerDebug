function initContextMenu() {
  /**
   * Function to check if we clicked inside an element with a particular class name.
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

  // Constants
  const contextMenuItemClassName = 'context-menu-item';
  const contextMenuActive = 'context-menu-active';
  const fileItemClassName = 'file-item';
  const directoryContainerClassName = 'directory-container';

  // Variables
  let fileItemInContext;
  let directoryContainerInContext;

  var clickCoords;
  var clickCoordsX;
  var clickCoordsY;

  var menu = document.querySelector('#context-menu');
  var menuState = 0;  // 0: menu hidden; 1: menu shown
  var menuWidth;
  var menuHeight;

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
        fileItemInContext = null;
        directoryContainerInContext = null;

        // check file item clicked, firstly
        var clickedItem = clickInsideElement(e, fileItemClassName);
        if (clickedItem) {
            fileItemInContext = clickedItem;
        } else {
            // check directory container item clicked, secondly
            clickedItem = clickInsideElement(e, directoryContainerClassName);
            if (clickedItem && parseDataOfContainerElement(clickedItem)) {
                directoryContainerInContext = clickedItem;
            }
        }

        if (fileItemInContext || directoryContainerInContext) {
            // show menu
            e.preventDefault();
            toggleMenuOn();
            positionMenu(e);
        } else {
            fileItemInContext = null;
            directoryContainerInContext = null;
            toggleMenuOff();
        }
    });
  }

  /**
   * Listens for click events.
   */
  function clickListener() {
    document.addEventListener('click', function(e) {
        var clickedMenuItem = clickInsideElement(e, contextMenuItemClassName);

        if (clickedMenuItem) {
            // click menu item
            e.preventDefault();
            menuItemListener(clickedMenuItem);
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
    const activeClassName = 'context-menu-item-active';
    const openEle = document.querySelector('.context-menu-item[data-action="open"]');
    const downloadEle = document.querySelector('.context-menu-item[data-action="download"]');
    const deleteEle = document.querySelector('.context-menu-item[data-action="delete"]');
    const renameEle = document.querySelector('.context-menu-item[data-action="rename"]');
    const createDirEle = document.querySelector('.context-menu-item[data-action="create-directory"]');
    const uploadEle = document.querySelector('.context-menu-item[data-action="upload"]');

    // config menu items
    if (fileItemInContext) {
        openEle.classList.add(activeClassName);
        downloadEle.classList.add(activeClassName);
        deleteEle.classList.add(activeClassName);
        // renameEle.classList.add(activeClassName);
        renameEle.classList.remove(activeClassName);
        createDirEle.classList.remove(activeClassName);
        uploadEle.classList.remove(activeClassName);
    } else {
        openEle.classList.remove(activeClassName);
        downloadEle.classList.remove(activeClassName);
        deleteEle.classList.remove(activeClassName);
        renameEle.classList.remove(activeClassName);
        // createDirEle.classList.add(activeClassName);
        createDirEle.classList.remove(activeClassName);
        uploadEle.classList.add(activeClassName);
    }

    // show
    menuState = 1;
    menu.classList.add(contextMenuActive);
  }

  /**
   * Turns the custom context menu off.
   */
  function toggleMenuOff() {
    // hide
    menuState = 0;
    menu.classList.remove(contextMenuActive);
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
   *  Action function when a menu item is clicked
   *
   * @param {HTMLElement} menuItem The menu item that was clicked
   */
  function menuItemListener(menuItem) {
    // parse data
    const action = menuItem.getAttribute('data-action');
    let viewItem;
    if (fileItemInContext) {
        viewItem = parseDataOfItemElement(fileItemInContext);
    } else {
        viewItem = parseDataOfContainerElement(directoryContainerInContext);
    }
    const section = viewItem.section;
    const isDir = viewItem.isDirectory;
    const fileName = viewItem.fileName;
    const filePath = viewItem.filePath;

    if (action === 'open') {
        // open file or directory
        onItemDoubleClicked(fileItemInContext);
    } else if (action === 'download') {
        // download file or directory
        // download url
        var url = document.location.origin + '/api/file_preview?file_path=' + filePath;

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
        // confirm
        var confirmMsg = '确定删除';
        if (isDir) {
            confirmMsg += '文件夹';
        } else {
            confirmMsg += '文件';
        }
        confirmMsg += '“' + fileName + '”？';
        var confirmResult = confirm(confirmMsg);

        if (confirmResult) {
            // do delete action
            var deleteXHR = new XMLHttpRequest();
            var requestURL = document.location.origin + '/api/file_explorer?file_path=' + encodeURIComponent(filePath) + '&action=delete';
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
                        const refreshSection = section - 1;
                        const directoryContainer = globalAllData[refreshSection];
                        const refreshItem = directoryContainer.getSelectedItem();
                        openFileOrDirectory(refreshItem);
                    }
                }
            };
            deleteXHR.send(null);
        }
    } else if (action === 'rename') {


        console.log('rename');
    } else if (action === 'upload') {
        // create element
        const fileEle = document.createElement('input');
        fileEle.type = 'file';
        fileEle.onchange = function () {
            // append data
            const formData = new FormData();
            formData.append('selectedfile', fileEle.files[0]);  // file
            formData.append('path', filePath);// argument

            // upload file
            const xhr = new XMLHttpRequest();
            const requestURL = document.location.origin + '/api/file_explorer?action=upload';
            xhr.open('POST', requestURL);
            xhr.onload = function () {
                if (xhr.status === 200) {
                    const responseText = xhr.responseText;
                    const responseJSON = JSON.parse(responseText);
                    const errno = responseJSON.errno;
                    const tmpDirData = responseJSON.data;

                    if (errno === 0) {
                        // refresh directory contents (if the uploaded directory is still opened)
                        if (globalAllData.length === section + 2 && globalAllData[section].getSelectedItem() === viewItem) {
                            // hide property side bar
                            hidePropertySidebar();

                            // remove no longer needed data and view
                            removeNoNeededDataAndViews(section);

                            // serailization
                            const dirData = new Array();
                            if (tmpDirData.length > 0) {
                                for (let i = 0; i < tmpDirData.length; i++) {
                                    const viewItem = new ItemViewModel(tmpDirData[i], section + 1, i);
                                    dirData.push(viewItem);
                                }
                            }
                            const dirContainer = new DirectoryContainerModel(dirData);

                            // add data and update views
                            addDataAndViews(dirContainer, section + 1);
                        }

                        // show notification
                        showNotification('上传成功');
                    } else {
                        showNotification('上传失败');
                    }
                } // status === 200
            };
            xhr.send(formData);
        }

        // dispatch click event
        const event = new MouseEvent('click');
        fileEle.dispatchEvent(event);
    }
    toggleMenuOff();
  }

  /**
   *
   *
   * @param {ItemViewModel} viewItem
   */
  function rename(viewItem) {

  }

  /**
   * Run the app.
   */
  init();
}
