#!/bin/sh

myTopic="test"

test $# -gt 2 && { myTopic="$1"; shift; }

myTitle="New message"
test $# -gt 1 && { myTitle="$1"; shift; }

echo "myTopic=$myTopic myTitle=$myTitle myMessage=$*"
test $# -lt 1 && { echo "Syntax: $0 [<topic>] <title> <message>"; exit; }
myMessage="$*"

curlCommand="curl -H \"Title: $myTitle\""
#curlCommand="$curlCommand -H \"Priority: urgent\""
#curlCommand="$curlCommand -H \"Tags: warning,skull\""
#curlCommand="$curlCommand -H \"Click: https://home.nest.com\""
#curlCommand="$curlCommand -H \"Attach: https://nest.com/view/yAxkasd.jpg\""
#curlCommand="$curlCommand -H \"Actions: http, Open door, https://api.nest.com/open/yAxkasd, clear=true\""
#curlCommand="$curlCommand -H \"Email: phil@example.com\""
curlCommand="$curlCommand -d \"$myMessage\" ntfy.sh/$myTopic"
# multiline messages are allowed
#curl -H "Title: $myTitle" -d "$myMessage" ntfy.sh/$myTopic
eval "$curlCommand"
