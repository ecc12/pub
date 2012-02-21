#!/usr/bin/env ruby

base_href='http://www.sitename.com'

require 'maruku'
require 'cgi'
cgi = CGI.new
puts cgi.header

pg_title = 'index'
if cgi.has_key?('pg') and cgi['pg'].length and  # page was specified and
    cgi['pg'] =~ /^[a-zA-Z0-9\/\-_]+$/ then     # contains only a-z A-Z / - _
  pg_title = cgi['pg']
end
pg_file = 'pg/#{pg_title}.txt'
pg_body = 'Error (#{pg_file})'
pg_body = File.open(pg_file).read() if File.exists?(pg_file)

puts <<HTML
<html>
  <head>
    <title>#{pg_title} | Sitename</title>
  </head>
  <body>

...
... page template
...
... use #{base_href} and #{Maruku.new{pg_body}.to_html} as needed
...

  </body>
</html>
HTML

