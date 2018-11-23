#!/usr/bin/env ruby
# encoding: utf-8
require 'cgi'
require 'cgi/session'
require 'sqlite3'
begin
  cgi = CGI.new
  session = CGI::Session.new(cgi)
  arId = cgi['articleId']
  # ログインしているかどうか確認
  accountId = session['accountId'] ? session['accountId'] : ""
  if accountId.empty?
       print cgi.header({
                   "status" => "REDIRECT", "Location" => "login.rb"
                        })
  else
    db = SQLite3::Database.new("blog.db")
    db.transaction(){
      db.execute("DELETE FROM article WHERE articleId=?;", arId)
    }
    print cgi.header("text/html;charset=utf-8")
    print <<-EOS
<html>
<head>
<title>削除成功</title>
<script type="text/javascript">
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
削除に成功しました。<br>
<a href="blog.rb?id=#{accountId}"><button>自分のブログを見る</button></a><br>
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
