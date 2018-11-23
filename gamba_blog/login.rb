#!/usr/bin/env ruby
# encoding: utf-8
require 'cgi'
require 'cgi/session'
require 'sqlite3'
begin
  cgi = CGI.new
  session = CGI::Session.new(cgi)
  accountId = session['accountId'] ? session['accountId'] : ""
  if accountId.empty?
    # 未ログイン状態
    if cgi['accountId'].empty?
      print cgi.header("text/html;charset=utf-8")
    else
      db = SQLite3::Database.new("blog.db")
      accountId = cgi['accountId']
      password = cgi['password']
      # 一致するアカウントがあればセッションにログイン情報を記録し、マイページへ
      count = 0
      db.transaction(){
        db.execute("SELECT * FROM user WHERE accountId like ? AND password like ?;", accountId, password){|row|
          count += 1
        }
      }
      if count == 1
        session['accountId'] = accountId
        errorflag = 0
      else
        errorflag = 1
      end
      db.close
      if errorflag == 0
        print cgi.header({
                           "status" => "REDIRECT", "Location" => "mypage.rb"
                         })
      elsif errorflag == 1
        eral = "ガンーバIDかパスワードが間違っています。"
        print cgi.header("text/html;charset=utf-8")
      end
    end
  else
    # セッションにログイン情報があればマイページへ
    print cgi.header({
                       "status" => "REDIRECT", "Location" => "mypage.rb"
                     })
  end
  print <<-EOS
<html>
<head>
<title>ログイン</title>
<link rel="shortcut icon" href="Gamba_favicon.png">
<link rel="stylesheet" type="text/css" href="login.css">
<Script type="text/javascript">
EOS
  if errorflag == 1
       print "alert('#{eral}');\n"
  end
  print <<-EOS
 function pre_check(){
  var accountId = document.forms['login_form'].accountId.value;
  var password = document.forms['login_form'].password.value;
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
  var al = new Array(3);
  if(Idflag == 1){
   al.push("ガンーバIDを入力してください。");
  }
  if(passflag == 1){
   al.push("パスワードは6~10文字です。");
  }
  if(Idflag == 0 && passflag == 0){
   if(Idenflag == 1 || psenflag == 1){
    al.push("英数字のみ利用できます。");
   }
  }
  console.log();
  if(Idflag == 0 && Idenflag == 0 && passflag == 0 && psenflag == 0){
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
<h1>ログイン</h1>
<form method="post" action="login.rb" onsubmit="return pre_check()" name="login_form">
<input type="text" name="accountId" placeholder="ガンーバID"><br>
<input type="password" name="password" placeholder="パスワード(6~10文字)"><br>
<button type="submit">ログイン</button><br>
</form>
<a href="register_entry.rb">Gamba新規会員登録</a>
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
