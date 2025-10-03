# Terraform AWS
This document outlines the process of installing and configuring [Terraform](https://developer.hashicorp.com/terraform) and use it on [Amazon Web Service](https://aws.amazon.com/) to provision resources on the cloud for **Production** and **Staging** Linux environments. Use [aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) for easy authentication and authorization on **AWS** on the terminal.    

## Install
### AWS CLI
Download and install **aws-cli**.  
```sh
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Terraform
Terraform can be installed using distro [package manager](https://en.wikipedia.org/wiki/List_of_software_package_management_systems) or [manually](https://developer.hashicorp.com/terraform/install#linux).  

#### Package manager
Use **apt** to install in **Debian-like** distros.  
Add **GPG** keys and repository
```sh
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

#### Manual  
Check current available version on [Terraform binaries website](https://releases.hashicorp.com/terraform) and choose right [architecture](https://en.wikipedia.org/wiki/Computer_architecture).  
Use [wget](https://www.gnu.org/software/wget/) or [curl](https://curl.se/) to download the appropriate pre-compiled [binary](https://developer.hashicorp.com/terraform/install) zipped archive for your system and [unzip](https://linux.die.net/man/1/unzip).  
```sh
wget -c -O ~/Downloads/terraform.zip https://releases.hashicorp.com/terraform/<version>/terraform_<version>_darwin_<arch>.zip
# or
curl -C - -Lo ~/Downloads/terraform.zip https://releases.hashicorp.com/terraform/<version>/terraform_<version>_linux_<arch>.zip
```
##### wget
- **`-c`** or **`--continue`** - Continue getting a partially-downloaded file.  
- **`-O`** - (capital O) for output filename.  

##### curl
**`-C -`** or **`--continue-at -`** - Resume a previous file transfer (the `-` tells curl to automatically figure out where to resume).  
**`-L`** - Follow redirects.  
**`-o`** - Output filename.  

Extract, move to installation directory,  
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

For **Development**, save statefile locally.  
```tf
terraform {
  backend "local" {
    path = "../../state/dev/terraform.tfstate"
  }
}
``` 

For **Production** and **Staging**, save statefile to **S3** bucket to prevent state conflicts.  
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


### Deployment
Initialize Terraform, first time or after module changes.  

#### Staging
Initialize.  
```sh
cd env/staging
terraform init
```

Run.  
```sh
terraform plan -var-file="./staging.tfvars"
terraform apply -var-file="./staging.tfvars"
```

#### Production
Initialize.  
```sh
cd env/staging
terraform init
```

Run.  
```sh
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```

#### SSH key
To get private key from SSM (requires proper IAM permissions).  
```sh
aws ssm get-parameter --name "/myapp/prod/webserver/private-key" --with-decryption
```


## Reference
1. [Terraform installation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
