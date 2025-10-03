# Terraform AWS
This document outlines the process of installing and configuring [Terraform](https://developer.hashicorp.com/terraform) and use it on [AWS](https://aws.amazon.com/) to provision resources on the cloud for **production** and **staging** environments.  

## Install
### Terraform
This tool can be installed using distro [package manager](https://en.wikipedia.org/wiki/List_of_software_package_management_systems) or [manually](https://developer.hashicorp.com/terraform/install#linux).  

#### Manual install  
Check current available version on [Terraform binaries website](https://releases.hashicorp.com/terraform) and choose right [architecture](https://en.wikipedia.org/wiki/Computer_architecture).  
Use [wget](https://www.gnu.org/software/wget/) or [curl](https://curl.se/) to download the appropriate pre-compiled [binary](https://developer.hashicorp.com/terraform/install) zipped archive for your system and [unzip](https://linux.die.net/man/1/unzip).  
```sh
wget -c -O ~/Downloads/terraform.zip https://releases.hashicorp.com/terraform/<version>/terraform_<version>_darwin_<arch>.zip
### or
curl -C - -Lo ~/Downloads/terraform.zip https://releases.hashicorp.com/terraform/<version>/terraform_<version>_linux_<arch>.zip
```
##### wget
- **`-c`** or **`--continue`** - Continue getting a partially-downloaded file.  
- **`-O`** - (capital O) for output filename.  

##### curl
**`-C -`** or **`--continue-at -`** - Resume a previous file transfer (the `-` tells curl to automatically figure out where to resume).  
**`-L`** - Follow redirects.  
**`-o`** - Output filename.  

Extract,  
move to installation directory,  
set permissions and add to path persistently.  
```sh
unzip ~/Downloads/terraform.zip -d ~/Downloads/terraform # Extract to ~/Downloads/terraform directory
sudo mv ~/Downloads/terraform/terraform /usr/local/bin/ # Move binary to install dir
sudo chown root:root /usr/local/bin/terraform # Change ownership to root user and group
sudo chmod 0755 /usr/local/bin/terraform # Set permissions, Owner: all perms, Group & Others: read, execute

echo 'export PATH="$PATH:/usr/local/bin"' >> ~/.bashrc # Add to $PATH persistently
source ~/.bashrc
```  

Verify.  
```sh
terraform --version
```


## Configure
### State
Create `state/` directory in project root for saving current state of each environment instead of single terraform.tfstate in root directory.  

For **Development**, save state locally.  
```tf
terraform {
  backend "local" {
    path = "../../state/dev/terraform.tfstate"
  }
}
``` 

For **Production** and **Staging**, save statefile to **s3** bucket to prevent state conflicts.  
Add below to `environments/staging/backend.tf`.  
```tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "staging/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```  

Add below to `environments/prod/backend.tf`.  
```tf
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```


### Run Terraform
Initialize Terraform, first time or after module changes.  

#### Staging
Initialize.  
```sh
cd environments/staging
terraform init
```

Run.  
```sh
terraform plan -var-file="environments/staging/staging.tfvars"
terraform apply -var-file="environments/staging/staging.tfvars"
```

#### Production
Initialize.  
```sh
cd environments/staging
terraform init
```

Run.  
```sh
terraform plan -var-file="environments/prod/prod.tfvars"
terraform apply -var-file="environments/prod/prod.tfvars"
```

#### SSH key
To get private key from SSM (requires proper IAM permissions).  
```sh
aws ssm get-parameter --name "/myapp/prod/webserver/private-key" --with-decryption
```


## Reference
1. [Terraform installation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
