# Prowler installation via Docker

## Terraform code will help to spin up a server and a SG

## Ansible playbook will help to instll docker and setup prowler with docker-compose

# Terraform-with-userData will handle everything
- provisioning the server
- creating the SG
- adding the Pub key
- installing docker and Prowler via a user data inject into the runtime. 


## Run the prowler CLI to get the scan output on local directory
[Reference](https://docs.prowler.com/projects/prowler-open-source/en/latest/#prowler-cli)

``` bash
docker run -ti --rm \
--env-file .env \
-v ./output:/home/prowler/output \
toniblyx/prowler:latest
```

```.env``` sample
``` yaml
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
```

```docker-compose.yml```
``` yaml
services:
  prowler:
    image: toniblyx/prowler:latest
    container_name: prowler
    env_file:
      - .env
    volumes:
      - ./output:/home/prowler/output
    stdin_open: true    # Enables interactive mode (-i)
    tty: true           # Enables pseudo-TTY (-t)
    restart: "no"       # Equivalent to --rm (container auto-removal not native in Compose)
```    