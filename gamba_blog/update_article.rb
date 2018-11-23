#!/usr/bin/env ruby
# encoding: utf-8
require 'cgi'
require 'cgi/session'
require 'sqlite3'
begin
  cgi = CGI.new
  session = CGI::Session.new(cgi)
  title = cgi['title']
  text = cgi['text']
  arId = cgi['articleId']
  # ログインしているかどうか確認
  accountId = session['accountId'] ? session['accountId'] : ""
  if accountId.empty?
       print cgi.header({
                   "status" => "REDIRECT", "Location" => "login.rb"
                        })
  else
    al = Array.new
    tiflag = title.empty? ? 1 : 0
    teflag = text.empty? ? 1 : 0
    if tiflag == 1
      al.push("タイトルを入力してください。")
    end
    if teflag == 1
      al.push("本文を入力してください。")
    end
    if ! al.empty?
      al = al.join("\\n")
        print cgi.header("text/html;charset=utf-8")
    print <<-EOS
<html><head>
<link rel="shortcut icon" href="Gamba_favicon.png">
<title>編集失敗</title>
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
編集に失敗しました。<br>
<button type="button" onclick="history.back()">戻る</button> <a href="blog.rb&id=#{accountId}"><button>自分のブログを見る</button></a><br>
<hr color="#e34d82">
</body></html>
EOS
    else
      db = SQLite3::Database.new("blog.db")
      db.transaction(){
        db.execute("UPDATE article SET title = ? , text = ? WHERE articleId=?;",title, text, arId)
      }
      print cgi.header("text/html;charset=utf-8")
      print <<-EOS
<html>
<head>
<title>編集成功</title>
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
編集に成功しました。<br>
<a href="blog.rb?id=#{accountId}"><button>自分のブログを見る</button></a><br>
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
