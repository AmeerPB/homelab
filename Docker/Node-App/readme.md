### Node app with a cronjb inside runs via supervisord


### Installation steps

``` bash
docker build -t hello-world-nodeapp:v7 .
docker run -d -p 8087:8080 --name hello-world-nodeapp-v7 hello-world-nodeapp:v7

watch 'docker exec -it hello-world-nodeapp-v7 cat /usr/src/app/cron_output.txt'
```    