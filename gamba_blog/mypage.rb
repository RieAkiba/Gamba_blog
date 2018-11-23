#!/usr/bin/env ruby
# encoding: utf-8
require 'cgi'
require 'cgi/session'
require 'sqlite3'
begin
  cgi = CGI.new
  session = CGI::Session.new(cgi)
  accountId = session['accountId'] ? session['accountId'] : ""
  name = ""
  if accountId.empty?
    print cgi.header({
                   "status" => "REDIRECT", "Location" => "login.rb"
                     })
  else
    print cgi.header("text/html;charset=utf-8")
    db = SQLite3::Database.new("blog.db")
    db.transaction(){
      db.execute("SELECT * FROM user WHERE accountId like ?;", accountId){|row|
        name = row[1]
      }
    }
    db.close
  end
  print <<-EOS
<html>
<head>
<link rel="shortcut icon" href="Gamba_favicon.png">
<title>#{name}のマイページ</title>
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
<h1>#{name}のマイページ</h1><br>
<a href="blog_entry.rb"><button>ブログを書く</button></a><br>
<a href="blog.rb?id=#{accountId}"><button>自分のブログを見る</button></a><br>
<a href="edit_list.rb"><button>記事一覧</button></a><br>
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
