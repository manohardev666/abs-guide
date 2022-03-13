FROM nginx:alpine
COPY default.conf /etc/nginx/conf.d/default.conf
COPY abs-guide/* /usr/share/nginx/html