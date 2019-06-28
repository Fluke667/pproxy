#!/bin/sh

exec pproxy -l socks4+socks5://:8090#$USER:$PASS
