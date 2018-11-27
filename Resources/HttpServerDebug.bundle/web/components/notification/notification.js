/**
 *
 * @class Notification
 * @property {HTMLElement} view
 */
class Notification {
    constructor() {
        this.view = null;
    }
}

/**
 * show notification
 * @param {string} msg displaying message
 * @param {number} duration Millisecond unit. Dismiss after the duration time. set 0, never dismiss
 * @returns {Notification}
 */
function showNotification(msg, duration) {
    // notification div
    const notificationEle = document.createElement('div');
    notificationEle.setAttribute('class', 'notification');

    // content div
    const contentEle = document.createElement('div');
    contentEle.setAttribute('class', 'content');
    notificationEle.appendChild(contentEle);

    // p
    const pEle = document.createElement('p');
    pEle.innerHTML = msg;
    pEle.style.visibility = 'hidden';
    contentEle.append(pEle);

    // show
    const groupEle = document.querySelector('#notification-group');
    groupEle.appendChild(notificationEle);

    // limit the text displaying length
    while (pEle.clientHeight > 40) {
        msg = msg.slice(0, msg.length - 1);
        pEle.innerHTML = msg + '...';
    }
    pEle.style.visibility = '';

    // create one instance
    const notification = new Notification();
    notification.view = notificationEle;

    updateNotificationGroup();

    // dismiss action
    if (typeof(duration) === 'undefined') {
        // default value
        duration = 3000;
    }

    if (duration > 0) {
        // auto dismiss
        setTimeout(() => {
            dismissNotification(notification);
        }, duration);
    }
    return notification;
}

/**
 *
 * @param {Notification} notification
 */
function dismissNotification(notification) {
    if (notification && notification.view) {
        // update notification
        notification.view.remove();

        // update notification group
        updateNotificationGroup();
    }
}

/**
 *
 */
function updateNotificationGroup() {
    const groupEle = document.querySelector('#notification-group');
    const maxHeight = window.innerHeight;

    // fixed or dynamic height
    let heightVal;
    if (groupEle.scrollHeight > maxHeight) {
        heightVal = maxHeight + 'px';
    } else {
        heightVal = 'auto';
    }

    groupEle.style.height = heightVal;
}

function initNotification() {
    // add notification group div
    const groupEle = document.createElement('div');
    groupEle.setAttribute('id', 'notification-group');
    document.body.appendChild(groupEle);

    window.addEventListener('resize', function () {
        updateNotificationGroup();
    });

    // debug
    // showNotification('上传失败', 0);
    // showNotification('上传失败上传失败上传失败上传失败上传失败上传失败上传失败上传失败上传失败上传失败', 0);
    // showNotification('上传失败', 0);
    // showNotification('上传失败', 0);
    // showNotification('上传失败', 0);
    // showNotification('上传失败', 0);
    // showNotification('上传失败', 0);
    // showNotification('上传失败', 0);
    // showNotification('上传失败', 0);
    // showNotification('上传失败', 0);
    // showNotification('上传失败', 0);
    // showNotification('上传失败', 0);
    // showNotification('上传失败', 0);
    // showNotification('上传失败');
    // showNotification('上传失败');
    // showNotification('上传失败');
    // showNotification('上传失败');
    // showNotification('上传失败');
    // showNotification('上传失败');
    // showNotification('上传失败');
    // showNotification('上传失败');
    // showNotification('上传失败');
    // setTimeout(() => {
    //     showNotification('上传成功');
    // }, 1000);
}
