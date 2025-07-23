# Prowler installation via Docker

## Terraform code will help to spin up a server and a SG

## Ansible playbook will help to instll docker and setup prowler with docker-compose

# Terraform-with-userData will handle everything
- provisioning the server
- creating the SG
- adding the Pub key
- installing docker and Prowler via a user data inject into the runtime. 


## Run the prowler CLI to get the scan output on local directory

``` bash
docker run -ti --rm \
--env-file .env \
-v ./output:/home/prowler/output \
toniblyx/prowler:latest
```
