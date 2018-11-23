#!/usr/bin/env ruby
# encoding: utf-8
require 'cgi'
require 'cgi/session'
require 'sqlite3'
begin
  cgi = CGI.new
  session = CGI::Session.new(cgi)
  accountId = session['accountId'] ? session['accountId'] : ""
  print cgi.header("text/html;charset=utf-8")
  print <<-EOS
<html>
<head>
<title>新規会員登録</title>
<link rel="shortcut icon" href="Gamba_favicon.png">
<Script type="text/javascript">
 function pre_check(){
  var accountId = document.forms['register_form'].accountId.value;
  var name = document.forms['register_form'].name.value;
  var password = document.forms['register_form'].password.value;
  // accountId check
  if(accountId.length > 0){
  Idflag = 0;  // true
  if(matchEng(accountId) > 0){
   Idenflag = 0;
   }else{
   Idenflag = 1;
  }
  }else{
   Idflag = 1;  // false
  }
  // name check
  if(name.length > 0){
   naflag = 0;
  }else{
   naflag = 1;
  }
  // password check
  if(password.length >= 6 && password.length <= 10){
   passflag = 0;  // true
   if(matchEng(accountId) > 0){
   psenflag = 0;
   }else{
   psenflag = 1;
  }
  }else{
   passflag = 1;  // false
  }
  // 警告判定
  var al = new Array;
  if(Idflag == 1){
   al.push("ガンーバIDを入力してください。");
  }
  if(naflag == 1){
   al.push("名前を入力してください。");
  }
  if(passflag == 1){
   al.push("パスワードは6~10文字です。");
  }
  if(Idflag == 0 && passflag == 0){
   if(Idenflag == 1 || psenflag == 1){
    al.push("英数字のみ利用できます。");
   }
  }
  // console.log(al);
  if(al.length == 0){
   return true;
  }else{
   al = al.join("\\n");
   alert(al);
   return false;
  }
}
function matchEng(str){
 cText = /\w*/;
 result = str.match(cText);
 return result.length;
}
function disp(){
 if(window.confirm('ログアウトしますか？')){
　location.href = "logout.rb"; // logout.rb へジャンプ
 }
 else{
  window.alert('キャンセルされました'); // 警告ダイアログを表示
 }
}
</script>
</head>
<body>
<a href="gamba_top.rb"><img src="Gamba.png" height="30"></a>
EOS
  if accountId.empty?
    print "<a href='login.rb'>ログイン</a> <a href='register_entry.rb'>新規登録</a><br>"
  else
    print "<a href='mypage.rb'>#{accountId}のマイページ</a> <button type='button' onclick='disp()'>ログアウト</button><br>"
  end
  print <<-EOS
<hr color="#e34d82">
<h1>新規会員登録</h1>
<form method="post" action="register.rb" onsubmit="return pre_check()" name="register_form">
<input type="text" name="accountId" placeholder="ガンーバID"><br>
<input type="text" name="name" placeholder="名前"><br>
<input type="password" name="password" placeholder="パスワード(6~10文字)"><br>
<button type="submit">会員登録</button><br>
</form>
<hr color="#e34d82">
</body>
</html>
EOS
rescue => ex
  print cgi.header("text/html;charset=utf-8")
  print <<-EOS
<html><body>
<pre>#{CGI.escapeHTML(ex.message)}</pre>
<pre>#{CGI.escapeHTML(ex.backtrace.join("¥n"))}</pre>
</body></html>
EOS
end
