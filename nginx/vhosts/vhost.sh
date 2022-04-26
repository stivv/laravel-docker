#!/usr/bin/env bash

if [ $NGINX_SSL = true ]; then
cat > /etc/nginx/conf.d/default.conf <<- EOF
server {
		listen 80;
		server_name $DEV_DOMAIN;
		return 301 https://$DEV_DOMAIN\$request_uri;
}

server {
		listen 443 ssl;
		index index.php index.html;
		server_name $DEV_DOMAIN, *.$DEV_DOMAIN;
		error_log /var/log/nginx/error.log;
		access_log /var/log/nginx/access.log;
		root /var/www/html/public;

		ssl_certificate	/etc/nginx/ssl-cert.crt;
		ssl_certificate_key /etc/nginx/ssl-cert.key;
		ssl_protocols	TLSV1 TLSV1.1 TLSV1.2;
		ssl_ciphers		HIGH:!aNULL:!md5;
	
		location / {
				try_files \$uri \$uri/ /index.php?\$query_string;
				gzip_static on;
		}

		location ~ \.php$ {
				try_files \$uri =404;
				fastcgi_split_path_info ^(.+\.php)(/.+)$;
				fastcgi_pass php:9000;
				fastcgi_index index.php;
				include fastcgi_params;
				fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
				fastcgi_param PATH_INFO \$fastcgi_path_info;
				fastcgi_read_timeout 300;
		}
}
EOF
else
cat > /etc/nginx/conf.d/default.conf <<- EOF
server {
		index index.php index.html;
		error_log  /var/log/nginx/error.log;
		access_log /var/log/nginx/access.log;

		root /var/www/html/public;

		server_name $DEV_DOMAIN, *.$DEV_DOMAIN;

		location / {
				try_files \$uri \$uri/ /index.php?\$query_string;
				gzip_static on;
		}

		location ~ \.php$ {
				try_files \$uri =404;
				fastcgi_split_path_info ^(.+\.php)(/.+)$;
				fastcgi_pass php:9000;
				fastcgi_index index.php;
				include fastcgi_params;
				fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
				fastcgi_param PATH_INFO \$fastcgi_path_info;
				fastcgi_read_timeout 300;
		}
}
EOF
fi
