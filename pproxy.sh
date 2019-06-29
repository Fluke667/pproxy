#!/bin/sh

exec pproxy -l socks4+socks5://:8090#$USER:$PASS
sleep 2
exec pproxy -l http://:8080#$USER:$PASS
