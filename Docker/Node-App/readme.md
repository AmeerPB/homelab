### Node app with a cronjb inside runs via supervisord


### Installation steps

``` bash
docker build -t hello-world-nodeapp:v7 .
docker run -d -p 8087:8080 --name hello-world-nodeapp-v7 hello-world-nodeapp:v7

# To run the container like the Host OS TZ
docker run -d -p 8089:8080 \
-v /etc/localtime:/etc/localtime:ro \
-v /etc/timezone:/etc/timezone:ro \
--name hello-world-nodeapp-v9 hello-world-nodeapp:v9

watch 'docker exec -it hello-world-nodeapp-v7 cat /usr/src/app/cron_output.txt'
```    