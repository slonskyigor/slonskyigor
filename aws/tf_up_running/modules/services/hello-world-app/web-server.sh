#!/bin/bashcat > index.html <<EOF
<h1>${server_text}</h1>
<p>DB address: ${db_address}</p>
<p>DB port: ${db_port}</p>
EOFnohup busybox httpd -f -p ${server_port} &
