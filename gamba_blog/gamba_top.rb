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
  db = SQLite3::Database.new("blog.db")
  print cgi.header("text/html;charset=utf-8")
  # ヘッダー
  print <<-EOS
<html><head>
<link rel="shortcut icon" href="Gamba_favicon.png">
<title>Gamba - ブログ投稿サイト</title>
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
<a href="gamba_top.rb"><img src="Gamba.png" height="50"></a>
EOS
  if accountId.empty?
    print "<a href='login.rb'>ログイン</a> <a href='register_entry.rb'>新規登録</a><br>"
  else
    print "<a href='mypage.rb'>#{accountId}のマイページ</a> <button type='button' onclick='disp()'>ログアウト</button><br>"
  end
  print <<-EOS
<hr color="#e34d82">
<h2>新着10件!</h2>
<table>
EOS
  count = 0
  db.transaction(){
    db.execute("SELECT * FROM article INNER JOIN user ON article.accountId = user.accountId ORDER BY create_time desc;"){|row|
      if count < 10
        name = row[6]
        time = row[4]
        acId = row[2]
        arId = row[0]
        title = row[1]
        count += 1
        print <<-EOS
<tr><th><a href="blog.rb?id=#{acId}">#{name}</a></th><th>#{time}</th><th><a href="article.rb?id=#{acId}&articleId=#{arId}">#{title}</a></th></tr>
EOS
      end
    }
  }
  db.close
  print "</table>"
  # フッター
  print <<-EOS
<hr color="#e34d82">
</body></html>
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
