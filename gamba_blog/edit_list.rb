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
  if accountId.empty?
       print cgi.header({
                   "status" => "REDIRECT", "Location" => "login.rb"
                        })
  else
    db = SQLite3::Database.new("blog.db")
    print cgi.header("text/html;charset=utf-8")
    # ヘッダー
    print <<-EOS
<html><head>
<link rel="shortcut icon" href="Gamba_favicon.png">
<title>記事一覧</title>
<script type="text/javascript">
function disp(){
 if(window.confirm('ログアウトしますか？')){
　location.href = "logout.rb"; // logout.rb へジャンプ
 }
 else{
  window.alert('キャンセルされました'); // 警告ダイアログを表示
 }
}
function disp_del(arId){
 if(window.confirm('本当に削除しますか？')){
　location.href = "delete_article.rb?articleId="+arId; // delete.rb へジャンプ
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
<h2>記事一覧</h2>
<table>
EOS
    db.transaction(){
      db.execute("SELECT * FROM article WHERE accountId like ? ORDER BY create_time desc;",accountId){|row|
        arId = row[0]
        title =row[1]
        time = row[4]
        print <<-EOS
<tr><th>#{time}</th><th><a href="article.rb?id=#{accountId}&articleId=#{arId}">#{title}</a></th><th><a href="edit_article.rb?articleId=#{arId}">編集</a></th><th><button type="button" onclick="disp_del(#{arId})">削除</button></th></tr>
EOS
      }
    }
    db.close
  print "</table>"
  # フッター
  print <<-EOS
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
