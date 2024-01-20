"use strict";
// ページネーション
const ajax = new XMLHttpRequest();
function get_ajax(page) {
  ajax.open('GET', '/ajax?per=5&page=' + page, true)
  ajax.onload = function () {
      if (ajax.readyState === 4 && ajax.status === 200) {
        const json = JSON.parse(ajax.responseText)
        // ボタン作成
        const buttons = document.querySelector('.buttons');
        const amount = json.total;
        if (amount !== buttons.children.length) {
          buttons.innerHTML = "";
          for (let index = 1; index <= amount; index++) {
            const button = document.createElement('button');
            button.innerHTML = index;
            button.type = 'button';
            button.addEventListener('click', () => { get_ajax(index) });
            buttons.appendChild(button);
          }
        }
        // リスト表示
        const json_keys = Object.keys(json.items);
        let html = "";
        for (let i = 0; i < json_keys.length; i++) {
          html += `<tr><th>${json.items[json_keys[i]]}</th><td><a href="${json_keys[i]}/edit">編集</a></td><td><a href="${json_keys[i]}/delete">削除</a></td></tr>`
        }
        document.getElementById("content").innerHTML = html;
      }
    }
  ajax.send();
}
get_ajax(1);