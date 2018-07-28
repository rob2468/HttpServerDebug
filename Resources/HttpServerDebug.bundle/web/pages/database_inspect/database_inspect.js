function onNavBarItemClick(id) {
    var id0 = 'browse-data';
    var id1 = 'execute-sql';
    var id2 = 'db-structure';
    var selectedItem = document.getElementById(id);
    if (!selectedItem.classList.contains('active')) {
        activeNavAndTabElement(selectedItem);
        if (selectedItem.id === id0) {
            inactiveNavAndTabElement(document.getElementById(id1));
            inactiveNavAndTabElement(document.getElementById(id2));
        } else if (selectedItem.id === id1) {
            inactiveNavAndTabElement(document.getElementById(id0));
            inactiveNavAndTabElement(document.getElementById(id2));
        } else {
            inactiveNavAndTabElement(document.getElementById(id0));
            inactiveNavAndTabElement(document.getElementById(id1));
        }
    }
}
function activeNavAndTabElement(navEle) {
    navEle.classList.add('active');
    var tabEle = document.getElementById(navEle.id + '-tab');
    tabEle.classList.add('active');
}
function inactiveNavAndTabElement(navEle) {
    navEle.classList.remove('active');
    var tabEle = document.getElementById(navEle.id + '-tab');
    tabEle.classList.remove('active');
}

function createTableHTMLElement(tableData) {
    var tableHTMLEle = document.createElement('table');
    if (tableData.length > 0) {
        var i;
        var j;
        var thHTMLEle;
        var tbodyHTMLEle;
        var tdHTMLEle;
        // thead
        var theadData = tableData[0];
        var theadHTMLEle = document.createElement('thead');
        tableHTMLEle.appendChild(theadHTMLEle);

        var trHTMLEle = document.createElement('tr');
        theadHTMLEle.appendChild(trHTMLEle);

        for (var i = 0; i < theadData.length; i++) {
            thHTMLEle = document.createElement('th');
            thHTMLEle.innerHTML = theadData[i];
            trHTMLEle.appendChild(thHTMLEle);
        }

        // tbody
        tbodyHTMLEle = document.createElement('tbody');
        tableHTMLEle.appendChild(tbodyHTMLEle);

        for (i = 1; i < tableData.length; i++) {
            var trData = tableData[i];
            trHTMLEle = document.createElement('tr');
            tbodyHTMLEle.appendChild(trHTMLEle);

            for (j = 0; j < trData.length; j++) {
                tdHTMLEle = document.createElement('td');
                tdHTMLEle.innerHTML = trData[j];
                trHTMLEle.appendChild(tdHTMLEle);
            }
        }
    }
    return tableHTMLEle;
}

/* browse data */
function onDatabaseTableReload() {
    // update reload button to loading state
    var reloadBtnEle = document.getElementById('browse-data-reload-button');
    reloadBtnEle.classList.remove('reload-normal');
    reloadBtnEle.classList.add('reload-loading');

    // request parameters
    var dbPathEle = document.getElementById('db-path');
    var dbPath = dbPathEle.innerText;
    var tableNamesEle = document.getElementById('table-name-select');
    var tableName = tableNamesEle.options[tableNamesEle.selectedIndex].value;

    // request
    var resultSetXHR = new XMLHttpRequest();
    var requestURL = document.location.protocol + '//' + document.location.host
    + '/api/database_inspect?db_path=' + dbPath + '&table_name=' + tableName;
    resultSetXHR.open('GET', requestURL);
    resultSetXHR.onload = function () {
        if (resultSetXHR.status === 200) {
            var responseText = resultSetXHR.responseText;
            var responseJSON = JSON.parse(responseText);

            // generate table html element with table information
            var tableHTMLEle = createTableHTMLElement(responseJSON);

            var tableEle = document.getElementById('browse-data-table');
            // clear children
            while (tableEle.firstChild) {
                tableEle.removeChild(tableEle.firstChild);
            }

            // append table html element
            tableEle.appendChild(tableHTMLEle);
        }

        // update reload button to normal state
        reloadBtnEle.classList.remove('reload-loading');
        reloadBtnEle.classList.add('reload-normal');
    };
    resultSetXHR.send(null);
}
// refresh database data
onDatabaseTableReload();

/* execute SQL */
function onDatabaseExecuteSQL() {
    var msgEle = document.getElementById('execute-sql-result-msg');
    // clear children
    while (msgEle.firstChild) {
        msgEle.removeChild(msgEle.firstChild);
    }

    var resultEle = document.createElement('p');
    resultEle.style.fontStyle = 'italic';
    msgEle.appendChild(resultEle);

    // request parameters
    var dbPathEle = document.getElementById('db-path');
    var dbPath = dbPathEle.innerText;
    var textareaEle = document.getElementById('sql-textarea');
    var sql = textareaEle.value.trim();

    if (sql.length === 0) {
        resultEle.innerHTML = 'SQL语句为空';
        return;
    }

    // update reload button to loading state
    var reloadBtnEle = document.getElementById('execute-sql-reload-button');
    reloadBtnEle.classList.remove('reload-normal');
    reloadBtnEle.classList.add('reload-loading');

    // request
    var resultSetXHR = new XMLHttpRequest();
    var requestURL = document.location.protocol + '//' + document.location.host
    + '/api/database_inspect/execute_sql?db_path=' + dbPath + '&sql=' + encodeURIComponent(sql);
    resultSetXHR.open('GET', requestURL);
    resultSetXHR.onload = function () {
        if (resultSetXHR.status === 200) {
            var responseText = resultSetXHR.responseText;
            var responseJSON = JSON.parse(responseText);
            // parse data
            var resMsg;
            var tableHTMLEle;
            var tableEle = document.getElementById('execute-sql-table');
            var status = responseJSON.status;
            var errMsg = responseJSON.errMsg;
            var tableData = responseJSON.resultSet;

            // status message
           if (status) {
                resMsg = 'success';
            } else {
                resMsg = 'failure';
            }
            if (errMsg.length > 0) {
                resMsg += ', ' + errMsg;
            }
            resultEle.innerHTML = resMsg;

            // result set
            tableHTMLEle = createTableHTMLElement(tableData);

            // clear children
            while (tableEle.firstChild) {
                tableEle.removeChild(tableEle.firstChild);
            }

            // append
            tableEle.appendChild(tableHTMLEle);
        }

        // update reload button to normal state
        reloadBtnEle.classList.remove('reload-loading');
        reloadBtnEle.classList.add('reload-normal');
    };
    resultSetXHR.send(null);
}

// database schema
function requestDatabaseSchema() {
    // request parameters
    var dbPathEle = document.getElementById('db-path');
    var dbPath = dbPathEle.innerText;

    // request
    var resultSetXHR = new XMLHttpRequest();
    var requestURL = document.location.protocol + '//' + document.location.host
    + '/api/database_inspect?db_path=' + dbPath + '&type=schema';
    resultSetXHR.open('GET', requestURL);
    resultSetXHR.onload = function () {
        if (resultSetXHR.status === 200) {
            var responseText = resultSetXHR.responseText;
            var responseJSON = JSON.parse(responseText);
            generateDatabaseSchemaHTML(responseJSON);
        }
    };
    resultSetXHR.send(null);
}
function generateDatabaseSchemaHTML(schemaData) {
    var tableArr = schemaData['table'];
    var indexArr = schemaData['index'];
    var viewArr = schemaData['view'];
    var triggerArr = schemaData['trigger'];

    var databaseSchemaEle = document.getElementById('database-schema');
    // Tables
    var pEle = document.createElement('p');
    pEle.innerHTML = 'Tables(' + tableArr.length + ')';
    databaseSchemaEle.appendChild(pEle);
    for (var i = tableArr.length - 1; i >= 0; i--) {
        var tableItem = tableArr[i];
        pEle = document.createElement('p');
        pEle.innerHTML = tableItem['name'] + ': ' + tableItem['sql'];
        databaseSchemaEle.appendChild(pEle);
    }

    databaseSchemaEle.appendChild(document.createElement('br'));

    // Indices
    pEle = document.createElement('p');
    pEle.innerHTML = 'Indices(' + indexArr.length + ')';
    databaseSchemaEle.appendChild(pEle);
    for (var i = indexArr.length - 1; i >= 0; i--) {
        var indexItem = indexArr[i];
        pEle = document.createElement('p');
        pEle.innerHTML = indexItem['name'] + ': ' + indexItem['sql'];
        databaseSchemaEle.appendChild(pEle);
    }

    databaseSchemaEle.appendChild(document.createElement('br'));

    // Views
    pEle = document.createElement('p');
    pEle.innerHTML = 'Views(' + viewArr.length + ')';
    databaseSchemaEle.appendChild(pEle);
    for (var i = viewArr.length - 1; i >= 0; i--) {
        var viewItem = viewArr[i];
        pEle = document.createElement('p');
        pEle.innerHTML = viewItem['name'] + ': ' + viewItem['sql'];
        databaseSchemaEle.appendChild(pEle);
    }

    databaseSchemaEle.appendChild(document.createElement('br'));

    // Triggers
    pEle = document.createElement('p');
    pEle.innerHTML = 'Triggers(' + triggerArr.length + ')';
    databaseSchemaEle.appendChild(pEle);
    for (var i = triggerArr.length - 1; i >= 0; i--) {
        var triggerItem = triggerArr[i];
        pEle = document.createElement('p');
        pEle.innerHTML = triggerItem['name'] + ': ' + triggerItem['sql'];
        databaseSchemaEle.appendChild(pEle);
    }
}
requestDatabaseSchema();