/* Data Model constructor */
/**
 *  create one directory container instance
 */
function DirectoryContainerItem(dirData) {
    this.items = dirData;   // sub-directories and files
    this.selectedIdx = -1;  // user selected item index, 0-index (-1: default value, no item selected)
};

/**
 *  Array, all directory containers
 *      DirectoryContainerItem instance
 */
var allData;

window.onload = function () {
    // init
    var rootDirData;
    var fileExpEle;
    // request root directory
    var rootDirXHR = new XMLHttpRequest();
    var requestURL = document.location.protocol + '//' + document.location.host
    + '/api/file_explorer';
    rootDirXHR.open('GET', requestURL);
    rootDirXHR.onload = function () {
        if (rootDirXHR.status === 200) {
            var responseText = rootDirXHR.responseText;
            rootDirData = JSON.parse(responseText);
            if (rootDirData.length > 0) {
                // save data
                allData = [new DirectoryContainerItem(rootDirData)];

                // initialize show
                fileExpEle = document.querySelector('#file-explorer');
                while (fileExpEle.firstChild) {
                    fileExpEle.removeChild(fileExpEle.firstChild);
                }
                fileExpEle.appendChild(constructDirectoryHTML(rootDirData, 0));
            }
        }
    };
    rootDirXHR.send(null);

    // init context menu
    initContextMenu();
};

function parseDataOfElement(element) {
        // parse data
        var eleID = element.id;
        var separatedArr = eleID.split('-');
        var row = separatedArr.pop();
        row = parseInt(row, 10);
        var section = separatedArr.pop();
        section = parseInt(section, 10);
        var itemList = allData[section].items;
        var item = itemList[row];
        return {
            'data': item,
            'section': section,
            'row': row
        };
}

var clickTimerOut;
function onItemClicked(element) {
    if (clickTimerOut) {
        clearTimeout(clickTimerOut);
    }
    clickTimerOut = setTimeout(function () {
        // parse data
        var parsedData = parseDataOfElement(element)
        var item = parsedData.data;
        var section = parsedData.section;
        var row = parsedData.row;
        var isDir = item.is_directory;
        var fileName = item.file_name;
        var filePath = item.file_path;

        // update selected states
        updateSelectedState(section, row);

        // hide property side bar
        hidePropertySidebar();

        // remove no longer needed data and view
        removeNoNeededDataAndViews(section, row);

        if (!isDir) {
            // request file attributes
            var attrXHR = new XMLHttpRequest();
            var requestURL = document.location.protocol + '//' + document.location.host
            + '/api/file_explorer?file_path=' + encodeURIComponent(filePath);
            attrXHR.open('GET', requestURL);
            attrXHR.onload = function () {
                if (attrXHR.status === 200) {
                    var responseText = attrXHR.responseText;
                    var attrs = JSON.parse(responseText);

                    showPropertySidebar(item, attrs);
                }
            };
            attrXHR.send(null);
        }
    }, 250);
}

function onItemDoubleClicked(element) {
    if (clickTimerOut) {
        // stop single click logic
        clearTimeout(clickTimerOut);
    }
    // parse data
    var parsedData = parseDataOfElement(element);
    var item = parsedData.data;
    var section = parsedData.section;
    var row = parsedData.row;
    var isDir = item.is_directory;
    var fileName = item.file_name;
    var filePath = item.file_path;

    // update selected states
    updateSelectedState(section, row);

    // hide property side bar
    hidePropertySidebar();

    // remove no longer needed data and view
    removeNoNeededDataAndViews(section, row);

    if (!isDir) {
        // normal file
        var fileExtension = fileName.split('.').pop();
        var url;
        if (fileExtension === 'db'
            || fileExtension === 'rdb'
            || fileExtension === 'sqlite'
            || fileExtension === 'sqlite3') {
            // database inspect
            url = window.location.origin + '/pages/database_inspect/database_inspect.html?db_path=' + encodeURIComponent(filePath);
        } else {
            // file preview
            url = window.location.origin + '/api/file_preview/' + fileName + '?file_path=' + encodeURIComponent(filePath);
        }
        window.open(url);
    } else {
        // directory
        var dirXHR = new XMLHttpRequest();
        var requestURL = document.location.protocol + '//' + document.location.host
        + '/api/file_explorer?file_path=' + encodeURIComponent(filePath);
        dirXHR.open('GET', requestURL);
        dirXHR.onload = function () {
            if (dirXHR.status === 200) {
                var responseText = dirXHR.responseText;
                var tmpDirData = JSON.parse(responseText);
                if (tmpDirData.length === 0) {
                    tmpDirData = [];
                }
                // save data
                allData.push(new DirectoryContainerItem(tmpDirData));

                // append view
                var fileExpEle = document.querySelector('#file-explorer');
                fileExpEle.appendChild(constructDirectoryHTML(tmpDirData, section + 1));
            }
        };
        dirXHR.send(null);
    }
}

/**
 *  @param dirData  Array, items in the directory
 *  @param dirIdx  directory index, 0-index
 *  @return DOM element
 */
function constructDirectoryHTML(dirData, dirIdx) {
    var itemNum = dirData.length;
    var item;       // an item in the directory
    var dirContainerEle = document.createElement('div');
    dirContainerEle.setAttribute('class', 'directory-container');

    // file list view
    var fileListEle = document.createElement('ul');
    for (var i = 0; i < itemNum; i++) {
        item = dirData[i];
        if (item) {
            fileListEle.appendChild(constructDirectoryItemHTML(item, dirIdx, i));
        }
    }
    dirContainerEle.appendChild(fileListEle);

    // split handler view
    var splitHandlerEle = document.createElement('div');
    splitHandlerEle.setAttribute('class', 'split-handler');
    splitHandlerEle.addEventListener('mousedown', function (event) {
        initResizeDrag(event);
    });
    dirContainerEle.appendChild(splitHandlerEle);

    return dirContainerEle;
}

/**
 *  @param item  Dictionary, an item in the directory
 *  @param dirIdx  directory index, 0-index
 *  @param fileIdx  file index, 0-index
 *  @return DOM element
 */
function constructDirectoryItemHTML(item, dirIdx, fileIdx) {
    // origin data
    var isDir = item.is_directory;
    var fileName = item.file_name;

    // li element
    var liEle = document.createElement('li');
    liEle.setAttribute('class', 'file-item');
    liEle.setAttribute('id', 'directory-container-' + dirIdx + '-' + fileIdx);
    liEle.title = fileName;
    liEle.onclick = function () {
        onItemClicked(this);
    };
    liEle.ondblclick = function () {
        onItemDoubleClicked(this);
    };

    // img element
    var imgEle = document.createElement('img');
    var imgClass;
    // is directory
    if (isDir) {
        imgClass = 'icon directory-icon';
    } else {
        imgClass = 'icon file-icon';
    }
    imgEle.setAttribute('class', imgClass);
    liEle.appendChild(imgEle);

    // file name element
    var fileNameEle = document.createElement('span');
    fileNameEle.innerHTML = fileName;
    liEle.appendChild(fileNameEle);

    return liEle;
}

/**
 *  @param item  file data
 *  @param attrs  file attributes
 */
function showPropertySidebar(item, attrs) {
    // parse data
    var isDir = item.is_directory;
    var fileName = item.file_name;
    var filePath = item.file_path;
    var fileSize = attrs.file_size;
    var creationTime = attrs.creation_time;
    var modificationTime = attrs.modification_time;
    var widthStr = '200px';

    var fileExpEle = document.querySelector('#file-explorer');
    var propertySidebarEle = document.querySelector('#property-sidebar');
    var contentContainerEle = propertySidebarEle.querySelector('.content-container');

    // expand property side bar area
    fileExpEle.style.right = widthStr;
    propertySidebarEle.classList.add('active');

    // clear old elements
    while (contentContainerEle.firstChild) {
        contentContainerEle.removeChild(contentContainerEle.firstChild);
    }

    // add elements
    var ele = document.createElement('img');
    ele.setAttribute('class', 'icon');
    contentContainerEle.appendChild(ele);

    ele = document.createElement('p');
    ele.setAttribute('class', 'file-name');
    ele.innerHTML = fileName;
    contentContainerEle.appendChild(ele);

    ele = document.createElement('p');
    ele.innerHTML = fileSize;
    contentContainerEle.appendChild(ele);

    ele = document.createElement('p');
    ele.innerHTML = '创建时间：' + creationTime;
    contentContainerEle.appendChild(ele);

    ele = document.createElement('p');
    ele.innerHTML = '修改时间：' + modificationTime;
    contentContainerEle.appendChild(ele);

    ele = document.createElement('p');
    ele.innerHTML = '文件路径：' + filePath;
    contentContainerEle.appendChild(ele);
}

/**
 *  hide property side bar
 */
function hidePropertySidebar() {
    var fileExpEle = document.getElementById('file-explorer');
    var propertySidebarEle = document.getElementById('property-sidebar');

    fileExpEle.style.right = '0';
    propertySidebarEle.classList.remove('active');
    propertySidebarEle.getElementsByClassName('content-container')[0].innerHTML = '';
}

/**
 *  remove no longer needed data and view
 */
function removeNoNeededDataAndViews(section, row) {
    // remove no longer needed data
    allData.splice(section + 1, allData.length - (section + 1));
    // remove no longer needed views
    var fileExpEle = document.getElementById('file-explorer');
    var dirContainers = fileExpEle.children;
    for (var i = dirContainers.length - 1; i >= section + 1; i--) {
        dirContainers[i].remove();
    }
}

/**
 *  update item selected states
 *  @param section  selected section
 *  @param row  selected row
 */
function updateSelectedState(section, row) {
    var directoryContainerItem = allData[section];
    var oldSelectedIdx = directoryContainerItem.selectedIdx;
    var selectedEle;

    // update data
    directoryContainerItem.selectedIdx = row;
    // update views
    if (oldSelectedIdx !== -1) {
        selectedEle = document.getElementById('directory-container-' + section + '-' + oldSelectedIdx);
        selectedEle.classList.remove('selected');
    }
    selectedEle = document.getElementById('directory-container-' + section + '-' + row);
    selectedEle.classList.add('selected');
}
