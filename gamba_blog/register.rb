#!/usr/bin/env ruby
# encoding: utf-8
require 'cgi'
require 'cgi/session'
require 'sqlite3'
begin
  cgi = CGI.new
  session = CGI::Session.new(cgi)
  # ログインしているかどうか確認
  accountId = session['accountId'] ? session['accountId'] : ""
  naccountId = cgi['accountId'] ? cgi['accountId'] : ""
  name = cgi['name'] ? cgi['name'] : ""
  password = cgi['password'] ? cgi['password'] : ""
  al = Array.new
  if naccountId.empty?
    al.push("ガンーバIDが入力されていません。")
  end
  if name.empty?
    al.push("名前が入力されていません。")
  end
  if password.empty?
    al.push("パスワードが入力されていません。")
  end
  db = SQLite3::Database.new("blog.db")
  count = 0
  db.transaction(){
    db.execute("SELECT * FROM user WHERE accountId = ?", naccountId){|row|
      count += 1
    }
  }
  if count > 0
    al.push("このガンーバIDは既に使用されています。")
  end
  if ! al.empty?
    al = al.join("\n")
    print cgi.header("text/html;charset=utf-8")
    print <<-EOS
<html><head><title>登録失敗</title>
<link rel="shortcut icon" href="Gamba_favicon.png">
<script type="text/javascript">
alert("#{al}");
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
登録に失敗しました。<br>
<a href="register_entry.rb">Gamba新規会員登録</a>
<hr color="#e34d82">
</body></html>
EOS
  db.close
  else
    db.transaction(){
      db.execute("INSERT INTO user VALUES(?, ?, ?);", naccountId, name, password)
    }
    db.close
    print cgi.header("text/html;charset=utf-8")
    print <<-EOS
<html><head><title>登録成功</title>
<link rel="shortcut icon" href="Gamba_favicon.png">
</head>
<body>
<img src="Gamba.png" height="30">
EOS
  if accountId.empty?
    print "<a href='login.rb'>ログイン</a>"
  else
    print "<a href='mypage.rb'>#{accountId}のマイページ</a>"
  end
  print <<-EOS
<hr color="#e34d82">
登録に成功しました。
<a href="login.rb">ログイン</a>
<hr color="#e34d82">
</body></html>
EOS
  end
rescue => ex
  print cgi.header("text/html;charset=utf-8")
  print <<-EOS
<html><body>
<pre>#{CGI.escapeHTML(ex.message)}</pre>
<pre>#{CGI.escapeHTML(ex.backtrace.join("¥n"))}</pre>
</body></html>
EOS
end
