# Wordpress and Mysql on Aws

* Launched a Wordpress and a mysql instance on Ec2 of amazon aws.
* The wordpress instance is lauched in a public subnet.
* The mysql instance is launched on the private subnet.
* The vpc has acoonection with the outside world through IGW.
* A bastion host is lauched to update the mysql server since it does not have an internet connection.



## Installation

*  <a href="https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html">Download aws cli</a>

* <a href="https://www.terraform.io/downloads.html">Download Terraform</a>

* To login to aws from Cli

```bash
aws configure
```
It will ask the secret key, access key and the region.The access and secret key can be obtained from Aws dashboard.

* Install terraform and make a profile in aws so as to not expose our secret key

```
aws configure --profile sahil
```
It will ask for secret key and access key.

* Initialize a folder 

```
terraform init
```
* Run the below command to run the code

```
terraform apply --auto-approve
```

* To destroy the setup run

```
terraform destroy --auto-approve
```


