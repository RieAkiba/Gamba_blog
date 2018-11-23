#!/usr/bin/env ruby
# encoding: utf-8 %>
require 'cgi'
require 'cgi/session'
require 'sqlite3'
begin
  cgi = CGI.new
  session = CGI::Session.new(cgi)
  accountId = session['accountId'] ? session['accountId'] : ""
  if accountId.empty?
    print cgi.header({
                       "status" => "REDIRECT", "Location" => "login.rb"
                     })
  else
    print cgi.header("text/html;charset=utf-8")
  end
  print <<-EOS
<html>
<head>
<title>ブログを書く</title>
<link rel="shortcut icon" href="Gamba_favicon.png">
<link rel="stylesheet" type="text/css" href="entry.css">
<script type="text/javascript">
 function pre_check(){
  var title = document.forms['entry_form'].title.value;
  var text = document.forms['entry_form'].text.value;
  // title check
  if(title.length > 0){
   tiflag = 0;  // true
  }else{
   tiflag = 1;  // false
  }
  // text check
  if(text.length > 0){
   txtflag = 0;  // true
   // HTML check
   if(matchHTML(text) > 0){
    hflag = 1;
   }else{
    hflag = 0;
   }
  }else{
   txtflag = 1;  // false
  }
  // 警告判定
  var al = new Array;
  if(tiflag == 1){
   al.push("タイトルを入力してください。");
  }
  if(txtflag == 1){
   al.push("本文を入力してください。");
  }else if(hflag == 1){
   al.push("HTMLタグは使えません。");
  }
  if(al.length == 0){
   return true;
  }else{
   al = al.join("\\n");
   alert(al);
   return false;
  }
}
function matchHTML(str){
 cText = /<.*>/;
 result = str.match(cText);
 return result.length;
}
function disp_rule(){
 str ="太字： ##太字##\\nアンダーライン： __アンダーライン__\\n斜体： %%斜体%%\\n";
 alert(str);
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
<h1>ブログを書く</h1>
<a href="blog.rb?id=#{accountId}">公開ページを見る</a>
<form action="submit.rb" method="post" onsubmit="return pre_check()" name="entry_form">
<input type="text" name="title" placeholder="タイトルを入力してください"><br>
<button type="button" onclick="disp_rule()">文字装飾の付け方</button><br>
<textarea name="text" rows="25" cols="100"></textarea><br>
<input type="submit" value="投稿">
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
