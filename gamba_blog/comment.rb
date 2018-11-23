#!/usr/bin/env ruby
# encoding: utf-8
require 'cgi'
require 'cgi/session'
require 'sqlite3'
begin
  cgi = CGI.new
  session = CGI::Session.new(cgi)
  text = cgi['comment']
  articleId = cgi['articleId']
  authorId = cgi['authorId']
  # ログインしているかどうか確認
  accountId = session['accountId'] ? session['accountId'] : ""
  if accountId.empty?
    print cgi.header({
                       "status" => "REDIRECT", "Location" => "login.rb"
                     })
  else
    al = Array.new
    teflag = text.empty? ? 1 : 0
    if teflag == 1
      al.push("コメントを入力してください。")
    end
    if ! al.empty?
      al = al.join("\n")
      print cgi.header("text/html;charset=utf-8")
      print <<-EOS
<html><head>
<link rel="shortcut icon" href="Gamba_favicon.png">
<title>コメント失敗</title>
<script type="text/javascript">
alert(#{al});
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
コメントに失敗しました。<br>
<button type="button" onclick="history.back()">戻る</button> <a href="blog.rb&id=#{authorId}"><button>ブログトップへ</button></a><br>
<hr color="#e34d82">
</body></html>
EOS
    else
      time = Time.now.to_s
      db = SQLite3::Database.new("blog.db")
      db.transaction(){
        db.execute("INSERT INTO comment(text, time, accountId, articleId) VALUES(?, ?, ?, ?)", text, time, accountId, articleId)
      }
      db.close
      print cgi.header("text/html;charset=utf-8")
      print <<-EOS
<html>
<head>
<title>コメント成功</title>
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
<img src="Gamba.png" height="30">
EOS
      if accountId.empty?
        print "<a href='login.rb'>ログイン</a><br>"
      else
        print "<a href='mypage.rb'>#{accountId}のマイページ</a> <button type='button' onclick='disp()'>ログアウト</button><br>"
      end
      print <<-EOS
<hr color="#e34d82">
コメントに成功しました。<br>
<button type="button" onclick="history.back()">戻る</button> <a href="blog.rb?id=#{authorId}"><button>ブログトップへ</button></a><br>
<hr color="#e34d82">
</body></html>
EOS
    end
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
