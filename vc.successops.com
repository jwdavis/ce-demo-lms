##
# You should look at the following URL's in order to grasp a solid understanding
# of Nginx configuration files in order to fully unleash the power of Nginx.
# http://wiki.nginx.org/Pitfalls
# http://wiki.nginx.org/QuickStart
# http://wiki.nginx.org/Configuration

server {

	# set resolver
	resolver 8.8.8.8 valid=300s;
	resolver_timeout 10s;

	#error_log /var/log/nginx/vc.error.log debug;
	
	# listen on 443
	listen 443 ssl;

	server_name vc.successops.com;
	ssl_certificate /home/jeff/fullchain1.pem;
	ssl_certificate_key /home/jeff/privkey1.pem;

	# set root for static files
	root /var/www/vc.successops.com/html;
	index index.html index.htm index.nginx-debian.html;

	# create location for static files
	location / {
		try_files $uri $uri/ =404;
	}

	# create location for gcs hosted media files
	location ~* /gcs/([^/]*)$ {
		proxy_pass https://storage.googleapis.com/raw_video_assets/$1;
	}
}
