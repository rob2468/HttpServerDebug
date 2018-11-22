/* Data Model constructor */
/**
 *  create one directory container instance
 *  @class DirectoryContainerModel
 *  @property {ItemViewModel[]} items sub-directories and files
 *  @property {number} selectedIdx user selected item index, 0-index (-1: default value, no item selected)
 *  @method getSelectedItem()
 */
class DirectoryContainerModel {
    /**
     * @param {ItemViewModel[]} dirData
     * @memberof DirectoryContainerModel
     */
    constructor(dirData) {
        this.items = dirData;
        this.selectedIdx = -1;
    }
    /**
     *  get selected item, according to items array and selected index
     */
    getSelectedItem() {
        let selectedItem;
        const items = this.items;
        const length = items.length;
        const selectedIdx = this.selectedIdx;
        if (selectedIdx >= 0 && selectedIdx < length) {
            selectedItem = items[selectedIdx];
        }
        return selectedItem;
    }
}

/**
 *  one file or directory view model
 *  @property {string} fileName
 *  @property {string} filePath
 *  @property {boolean} isDirectory
 *  @property {number} section
 *  @property {number} row
 */
class ItemViewModel {
    /**
     * @param {object} item
     * @param {number} section
     * @param {number} row
     * @memberof ItemViewModel
     */
    constructor(item, section, row) {
        this.fileName = item.file_name;
        this.filePath = item.file_path;
        this.isDirectory = item.is_directory;
        this.section = section;
        this.row = row;
    }
}

/**
 *  all directory containers
 * @type {DirectoryContainerModel[]}
 */
var globalAllData;

window.onload = function () {
    // request root directory
    openRootDirectory();

    // init context menu
    initContextMenu();

    // init notification component
    initNotification();
};

var clickTimerOut;
function onItemClicked(element) {
    if (clickTimerOut) {
        clearTimeout(clickTimerOut);
    }
    clickTimerOut = setTimeout(function () {
        // parse data
        const viewItem = parseDataOfItemElement(element)
        const section = viewItem.section;
        const row = viewItem.row;
        const isDir = viewItem.isDirectory;
        const fileName = viewItem.fileName;
        const filePath = viewItem.filePath;

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
                    var responseJSON = JSON.parse(responseText);
                    var attrs = responseJSON.data;

                    showPropertySidebar(viewItem, attrs);
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
    var viewItem = parseDataOfItemElement(element);
    openFileOrDirectory(viewItem);
}

/**
 *  open root directory
 */
function openRootDirectory() {
    // request root directory
    var rootDirXHR = new XMLHttpRequest();
    var requestURL = document.location.protocol + '//' + document.location.host
    + '/api/file_explorer';
    rootDirXHR.open('GET', requestURL);
    rootDirXHR.onload = function () {
        if (rootDirXHR.status === 200) {
            const responseText = rootDirXHR.responseText;
            const responseJSON = JSON.parse(responseText);
            const rootDirData = responseJSON.data;

            if (rootDirData.length > 0) {
                // serialization
                const rootDirItems = new Array();
                for (let i = 0; i < rootDirData.length; i++) {
                    const item = new ItemViewModel(rootDirData[i], 0, i);
                    rootDirItems.push(item);
                }

                // save data
                globalAllData = [new DirectoryContainerModel(rootDirItems)];

                // remove all directory sections
                var fileExpEle = document.querySelector('#file-explorer');
                while (fileExpEle.firstChild) {
                    fileExpEle.removeChild(fileExpEle.firstChild);
                }

                // show root directory
                var rootDirectoryEle = constructDirectoryHTML(rootDirItems, 0);
                fileExpEle.appendChild(rootDirectoryEle);
            }
        }
    };
    rootDirXHR.send(null);
}

/**
 *  open file or directory
 *  @param {ItemViewModel} viewItem  ItemViewModel instance
 */
function openFileOrDirectory(viewItem) {
    const isDir = viewItem.isDirectory;
    const fileName = viewItem.fileName;
    const filePath = viewItem.filePath;
    const section = viewItem.section;
    const row = viewItem.row;

    // update selected states
    updateSelectedState(section, row);

    // hide property side bar
    hidePropertySidebar();

    // remove no longer needed data and view
    removeNoNeededDataAndViews(section, row);

    if (!isDir) {
        // normal file
        const fileExtension = fileName.split('.').pop();
        let url;
        if (fileExtension === 'db'
            || fileExtension === 'rdb'
            || fileExtension === 'sqlite'
            || fileExtension === 'sqlite3') {
            // database inspect
            url = document.location.origin + '/pages/database_inspect/database_inspect.html?db_path=' + encodeURIComponent(filePath);
        } else {
            // file preview (append fileName to url, for when browser decides to download this file, it will fill with the right file name)
            url = document.location.origin + '/api/file_preview/' + fileName + '?file_path=' + encodeURIComponent(filePath);
        }
        window.open(url);
    } else {
        // directory
        const dirXHR = new XMLHttpRequest();
        const requestURL = document.location.protocol + '//' + document.location.host
        + '/api/file_explorer?file_path=' + encodeURIComponent(filePath);
        dirXHR.open('GET', requestURL);
        dirXHR.onload = function () {
            if (dirXHR.status === 200) {
                const responseText = dirXHR.responseText;
                const responseJSON = JSON.parse(responseText);
                const tmpDirData = responseJSON.data;

                // serailization
                const dirData = new Array();
                if (tmpDirData.length > 0) {
                    for (let i = 0; i < tmpDirData.length; i++) {
                        const viewItem = new ItemViewModel(tmpDirData[i], section + 1, i);
                        dirData.push(viewItem);
                    }
                }

                // save data
                globalAllData.push(new DirectoryContainerModel(dirData));

                // append view
                const fileExpEle = document.querySelector('#file-explorer');
                fileExpEle.appendChild(constructDirectoryHTML(dirData, section + 1));
            }
        };
        dirXHR.send(null);
    }
}

/**
 *  parse for file item
 *  @param {HTMLElement} element
 *  @returns {ItemViewModel}
 */
function parseDataOfItemElement(element) {
    // parse data
    const eleID = element.id;
    const separatedArr = eleID.split('-');
    let row = separatedArr.pop();
    row = parseInt(row, 10);

    let section = separatedArr.pop();
    section = parseInt(section, 10);

    const itemList = globalAllData[section].items;
    const viewItem = itemList[row];
    return viewItem;
}

/**
 *  parse for directory container
 *  @param {HTMLElement} element
 */
function parseDataOfContainerElement(element) {
    // parse data
    const eleID = element.id;
    const separatedArr = eleID.split('-');
    let section = separatedArr.pop();
    section = parseInt(section, 10);

    let viewItem = null;
    if (section > 0) {
        // not the root directory
        section--;

        const containerItem = globalAllData[section];
        viewItem = containerItem.getSelectedItem();
    }
    return viewItem;
}

/**
 *  @param {ItemViewModel[]} viewItems items in the directory
 *  @param {number} dirIdx directory index, 0-index
 *  @return {HTMLElement} DOM element
 */
function constructDirectoryHTML(viewItems, dirIdx) {
    const itemNum = viewItems.length;
    const dirContainerEle = document.createElement('div');
    dirContainerEle.setAttribute('class', 'directory-container');
    dirContainerEle.setAttribute('id', 'directory-container-' + dirIdx);

    // file list view
    const fileListEle = document.createElement('ul');
    for (let i = 0; i < itemNum; i++) {
        const viewItem = viewItems[i];
        fileListEle.appendChild(constructDirectoryItemHTML(viewItem, dirIdx, i));
    }
    dirContainerEle.appendChild(fileListEle);

    // split handler view
    const splitHandlerEle = document.createElement('div');
    splitHandlerEle.setAttribute('class', 'split-handler');
    splitHandlerEle.addEventListener('mousedown', function (event) {
        initResizeDrag(event);
    });
    dirContainerEle.appendChild(splitHandlerEle);

    return dirContainerEle;
}

/**
 *  @param {ItemViewModel} viewItem  an item in the directory
 *  @param {number} dirIdx directory index, 0-index
 *  @param {number} fileIdx  file index, 0-index
 *  @return {HTMLElement} DOM element
 */
function constructDirectoryItemHTML(viewItem, dirIdx, fileIdx) {
    // origin data
    var isDir = viewItem.isDirectory;
    var fileName = viewItem.fileName;

    // li element
    const liEle = document.createElement('li');
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
    const imgEle = document.createElement('img');
    let imgClass;
    // is directory
    if (isDir) {
        imgClass = 'icon directory-icon';
    } else {
        imgClass = 'icon file-icon';
    }
    imgEle.setAttribute('class', imgClass);
    liEle.appendChild(imgEle);

    // file name element
    const fileNameEle = document.createElement('span');
    fileNameEle.innerHTML = fileName;
    liEle.appendChild(fileNameEle);

    return liEle;
}

/**
 *  @param {ItemViewModel} viewItem file data
 *  @param {object} attrs file attributes
 */
function showPropertySidebar(viewItem, attrs) {
    // parse data
    const fileName = viewItem.fileName;
    const filePath = viewItem.filePath;
    const fileSize = attrs.file_size;
    const creationTime = attrs.creation_time;
    const modificationTime = attrs.modification_time;
    const contentType = attrs.content_type;
    const widthStr = '200px';

    const fileExpEle = document.querySelector('#file-explorer');
    const propertySidebarEle = document.querySelector('#property-sidebar');
    const contentContainerEle = propertySidebarEle.querySelector('.content-container');

    // expand property side bar area
    fileExpEle.style.right = widthStr;
    propertySidebarEle.classList.add('active');

    // clear old elements
    while (contentContainerEle.firstChild) {
        contentContainerEle.removeChild(contentContainerEle.firstChild);
    }

    // add elements
    // image icon
    let ele = document.createElement('img');
    ele.setAttribute('class', 'icon');
    let iconSRC;
    if (contentType.startsWith('image/')) {
        // image file
        iconSRC = document.location.origin + '/api/file_preview?file_path=' + encodeURIComponent(filePath);
    } else {
        // regular file
        iconSRC = document.location.origin + '/resources/file-icon.png';
    }
    ele.setAttribute('src', iconSRC);
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
    const fileExpEle = document.getElementById('file-explorer');
    const propertySidebarEle = document.getElementById('property-sidebar');

    fileExpEle.style.right = '0';
    propertySidebarEle.classList.remove('active');
    propertySidebarEle.getElementsByClassName('content-container')[0].innerHTML = '';
}

/**
 *  remove no longer needed data and view
 *  @param {number} section
 */
function removeNoNeededDataAndViews(section, row) {
    // remove no longer needed data
    globalAllData.splice(section + 1, globalAllData.length - (section + 1));

    // remove no longer needed views
    var fileExpEle = document.getElementById('file-explorer');
    var dirContainers = fileExpEle.children;
    for (var i = dirContainers.length - 1; i >= section + 1; i--) {
        dirContainers[i].remove();
    }
}

/**
 *  update item selected states
 *  @param {number} section  selected section
 *  @param {number} row  selected row
 */
function updateSelectedState(section, row) {
    const directoryContainerItem = globalAllData[section];
    const oldSelectedIdx = directoryContainerItem.selectedIdx;
    let selectedEle;

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
