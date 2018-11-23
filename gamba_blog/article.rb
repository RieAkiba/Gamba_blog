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
  articleId = cgi['articleId']
  db = SQLite3::Database.new("blog.db")
  # ヘッダー
  authorName = ""
  db.transaction(){
    db.execute("SELECT * FROM user WHERE accountId like ?", authorId){|row|
      authorName = row[1]
    }
  }
  print cgi.header("text/html;charset=utf-8")
  print <<-EOS
<html><head>
<link rel="shortcut icon" href="Gamba_favicon.png">
<link rel="stylesheet" type="text/css" href="entry.css">
<title>#{authorName}のブログ</title>
<script type="text/javascript">
 function pre_check(){
  var text = document.forms['comment_form'].comment.value;
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
  if(txtflag == 1){
   al.push("コメントを入力してください。");
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
function disp(){
 if(window.confirm('ログアウトしますか？')){
　location.href = "logout.rb"; // logout.rb へジャンプ
 }
 else{
  window.alert('キャンセルされました'); // 警告ダイアログを表示
 }
}
function load() {
  var text = document.getElementById('body');
  text.innerHTML = text.innerHTML.replace(/__(.+?)__/g, "<u>$1</u>");
  text.innerHTML = text.innerHTML.replace(/##(.+?)##/g, '<b>$1</b>');
  text.innerHTML = text.innerHTML.replace(/%%(.+?)%%/g, "<i>$1</i>");
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
    db.execute("SELECT * FROM article WHERE articleId like ?", articleId){|row|
      title = row[1]
      text = row[3]
      create_time = row[4]
            print <<-EOS
<h2>#{title}</h2>
#{create_time}<br>
<pre id="body">
#{text}
</pre>
<hr>
EOS
    }
  }
  print <<-EOS
<form action="comment.rb" method="post" onsubmit="return pre_check()" name="comment_form">
<textarea name="comment" rows="7" cols="50"></textarea><br>
<input type="hidden" name="articleId" value="#{articleId}">
<input type="hidden" name="authorId" value="#{authorId}">
<input type="submit" value="コメントする">
</form>
<hr>
EOS
  # コメント表示
  db.transaction(){
    db.execute("SELECT * FROM comment WHERE articleId like ? ORDER BY time asc;", articleId){|row|
      text = row[1]
      time = row[2]
      acId = row[3]
      print <<-EOS
<pre>
#{text}
</pre>
#{time} <a href="blog.rb?id=#{acId}">#{acId}</a><br>
<hr>
EOS
    }
  }
  db.close
  print "<hr color='#e34d82'></body></html>"
rescue => ex
  print cgi.header("text/html;charset=utf-8")
  print <<-EOS
<html><body>
<pre>#{CGI.escapeHTML(ex.message)}</pre>
<pre>#{CGI.escapeHTML(ex.backtrace.join("¥n"))}</pre>
</body></html>
EOS
end
