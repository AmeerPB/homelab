# Prowler installation via Docker

## Terraform code will help to spin up a server and a SG

## Ansible playbook will help to instll docker and setup prowler with docker-compose

# Terraform-with-userData will handle everything
- provisioning the server
- creating the SG
- adding the Pub key
- installing docker and Prowler via a user data inject into the runtime. 