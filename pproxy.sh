#!/bin/bash

pproxy -l socks4+socks5://:8090#$USER:$PASS &
sleep 2 &
pproxy -l http://:8080#$USER:$PASS
sleep 2 &
exec pproxy -l ss+ssr://:8070 -r ss+ssr://chacha20:GazSsv5x61Q7dGph@127.0.0.1:1080
#sleep 2 &
#exec pproxy -l ss://:8060 -r ss://aes-256-gcm:yDRHHo1PjnolIVQHF3H4cpuL45udo7aHOco+Og==@127.0.0.1:1080 -vv

