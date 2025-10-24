{
  // 押下時の確認。
  // onClickとして、"return check('msg','targetId')"みたいに追加する。
  function check (msg = "",targetId = "") {
    checkMsg = "実行しますか？"
    if (msg != ""){
      checkMsg = msg;
    }
    if(window.confirm(checkMsg)){
      if (targetId != ""){
        document.getElementById(targetId).classList.add("pointer-events-none");
      }
      return true;
    } else{
      window.alert('中断しました。');
      return false;
    }
  }
}
