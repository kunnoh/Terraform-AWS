# Terraform AWS
This document outlines the process of installing and configuring [Terraform](https://developer.hashicorp.com/terraform) and using it on [AWS](https://aws.amazon.com/) to provision resources on the cloud.  

## Install
### Terraform
This tool can be installed using distro [package manager](https://en.wikipedia.org/wiki/List_of_software_package_management_systems) or [manually](https://developer.hashicorp.com/terraform/install#linux).  

#### Manual install  
Use [wget](https://www.gnu.org/software/wget/) to download the appropriate pre-compiled [binary](https://developer.hashicorp.com/terraform/install) zipped archive for your system and [unzip](https://linux.die.net/man/1/unzip).  
```sh
# Download zip file
wget -O ~/Downloads/ https://releases.hashicorp.com/terraform/<version>/terraform_<version>_darwin_<arch>.zip

unzip terraform_<version>_linux_<arch>.zip # Extract terraform

mv ~/Downloads/terraform /usr/local/bin/ # Move to installation dir

echo -e "export $PATH:/usr/local/bin" >> ~/.bashrc # Add to $PATH persistently
```  
- **echo -e** - Force a newline.  


### Run
```sh
terraform init
terraform plan -var="environment=prod" -var="project_name=myapp"
```

Get private key from SSM (requires proper IAM permissions).  
```sh
aws ssm get-parameter --name "/myapp/prod/webserver/private-key" --with-decryption
```


## Reference
1. [Terraform installation](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)