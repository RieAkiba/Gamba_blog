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
  authorId = cgi['id']
  authorName = ""
  db = SQLite3::Database.new("blog.db")
  db.transaction(){
    db.execute("SELECT * FROM user WHERE accountId like ?", authorId){|row|
      authorName = row[1]
    }
  }
  print cgi.header("text/html;charset=utf-8")
  # ヘッダー
  print <<-EOS
<html><head>
<link rel="shortcut icon" href="Gamba_favicon.png">
<title>#{authorName}のブログ</title>
<script type="text/javascript">
function disp(){
 if(window.confirm('ログアウトしますか？')){
　location.href = "logout.rb"; // logout.rb へジャンプ
 }
 else{
  window.alert('キャンセルされました'); // 警告ダイアログを表示
 }
}
function load() {
  var text = document.getElementsByName('body');
  for(i=0;i<text.length;i++){
  text[i].innerHTML = text[i].innerHTML.replace(/__(.+?)__/g, "<u>$1</u>");
  text[i].innerHTML = text[i].innerHTML.replace(/##(.+?)##/g, '<b>$1</b>');
  text[i].innerHTML = text[i].innerHTML.replace(/%%(.+?)%%/g, "<i>$1</i>");
  }
}
window.onload = load;
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
<a href="blog.rb?id=#{authorId}"><h1>#{authorName}のブログ</h1></a>
EOS
  # 中身
  db.transaction(){
    db.execute("SELECT * FROM article WHERE accountId like ? ORDER BY create_time desc;", authorId){|row|
      articleId = row[0]
      com_num = 0
      db.execute("SELECT * FROM comment WHERE articleId = ?;", articleId){|row|
        com_num += 1
      }
      title = row[1]
      text = row[3]
      create_time = row[4]
      print <<-EOS
<h2>#{title}</h2>
#{create_time}<br>
<pre name="body">
#{text}
</pre>
<a href="article.rb?id=#{authorId}&articleId=#{articleId}">コメント(#{com_num})</a>
<hr>
EOS
    }
  }
  db.close
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
