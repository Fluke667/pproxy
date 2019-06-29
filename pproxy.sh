#!/bin/bash

pproxy -l socks4+socks5://:8090#$USER:$PASS &
sleep 2 &
pproxy -l http://:8080#$USER:$PASS &
sleep 2 &
pproxy -l ssr://:8070 -r ssr://chacha20:GazSsv5x61Q7dGph@127.0.0.1:1080 -vv  &
sleep 2 &
exec pproxy -l ssr://:8060 -r ssr://chacha20:GazSsv5x61Q7dGph@127.0.0.1:1080 -vv
