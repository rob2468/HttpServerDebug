/**
 *  show notification
 *  @param msg  displaying message
 *  @param duration  dismiss after the duration time, millisecond unit
 */
function showNotification(msg, duration) {
    // notification div
    const notificationEle = document.createElement('div');
    notificationEle.setAttribute('class', 'notification');

    // content div
    const contentEle = document.createElement('div');
    contentEle.setAttribute('class', 'content');
    notificationEle.appendChild(contentEle);

    // p div
    const pEle = document.createElement('p');
    pEle.innerHTML = msg;
    contentEle.append(pEle);

    // show
    const groupEle = document.querySelector('#notification-group');
    groupEle.appendChild(notificationEle);

    // dismiss action
    if (!duration) {
        duration = 3000;
    }
    setTimeout(() => {
        notificationEle.remove();
    }, duration);
}

function initNotification() {
    const groupEle = document.createElement('div');
    groupEle.setAttribute('id', 'notification-group');
    document.body.appendChild(groupEle);


    // debug
    // showNotification('上传失败');
    // setTimeout(() => {
    //     showNotification('上传成功');
    // }, 1000);
}
