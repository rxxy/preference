FROM nginx:1.22
EXPOSE 80
ENV TZ=Asia/Shanghai
COPY default.conf /etc/nginx/conf.d/
CMD "nginx" "-g" "daemon off;"
