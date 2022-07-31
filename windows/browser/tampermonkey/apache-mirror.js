/**
 * 为apache网站下载时增加清华镜像地址，加快下载速度
 */
function addStyle(){
    const css = `
            .wrap{
                padding: 5px;
            }
        `
    GM_addStyle(css)
}


function createHTML() {
    let httpEl = document.querySelector('#http').nextElementSibling.querySelector('a')
    let reg = new RegExp('http.+apache\.org');
    let newUrl = httpEl.href.replace(reg, 'https://mirrors.tuna.tsinghua.edu.cn/apache')

    let html = `
    <a href="${newUrl}"><strong style="margin-left:10px;color: #07eaf5;">清华镜像下载</strong></a>
    `
    httpEl.insertAdjacentHTML('beforeEnd', html)
}


(function () {
    addStyle()
    createHTML()
})();
