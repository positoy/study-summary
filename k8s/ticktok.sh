#!/bin/sh
while (true); do
    sleep 1
    echo "<h1>$(date)</h1>" >/usr/share/nginx/html/index.html
done
