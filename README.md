
# terraform-automate-chef
repo that automates the process of building automate and  chef servers (standalone) and the supporting infrastructure and configuration.

What this builds:

1. VPC with six subnets, three private and three public
2. Security Group for chef and automate (you will need to lock it down)
3. Chef server v 12 (amazon linux)
4. Automate server v 1 (amazon linux)
5. Two runner servers (amazon linux)
6. Installs and applys configuration for both servers via bash script loaded as userdata.


Assumptions:

1. terraform is installed on your workstation.

2. You have AWS Amazon account.

3. awscli and credentials are setup on your workstation.




Directions:

1. Clone repo to your workstation
2. obtain license key for automate from chef.io
3. Create an s3 bucket in aws and upload your automate license to it.
4. Modify the role.tf to reflect name of new s3 bucket.
5. modify userdata in instances.tf to reflect new bucket name
6. generate ssh key called mykey or pick a name and modify terrafrom modules (vars.tf and key.tf) to reflect new name.
7. run "terraform init: in cloned repo directory
8. run "terraform apply" in cloned directory
9. Login to servers

Troubleshooting:  

1. troubleshoot if stuff goes wrong.
2. reference material: https://learn.chef.io/modules/manage-a-node-chef-automate/rhel/automate/set-up-your-chef-server#/
3. https://docs.chef.io/install_chef_automate.html
4. https://docs.chef.io/install_server.html#standalone

Note:
automate runs a preflight check , you can see the output file on the automate server in the tmp directory.
errors may need to be fixed if automate isnt working correctly.


If you are used to a management console for chef,  ssh into chef server
run:

#Configure management console

sudo chef-manage-ctl reconfigure
