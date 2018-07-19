
# terraform-automate-chef
repo that automates the process of building automate and  chef servers (standalone) and the supporting infrastructure and configuration.

What this builds:


1. Security Group for chef and automate (you will need to lock it down)
2. Chef server v 12 (amazon linux)
3. Automate server v 1 (amazon linux)
4. Two runner servers (amazon linux)
5. Installs and applys configuration for both servers via bash script loaded as userdata.


Assumptions:

1. terraform is installed on your workstation.

2. You have AWS Amazon account.

3. awscli and credentials are setup on your workstation.


Directions:

1. Clone repo to your workstation
2. obtain license key for automate from chef.io
3. Create an s3 bucket in aws and upload your automate license to it.
4. Modify the var.tf with appropriate information.
5. generate ssh key called mykey or pick a name and modify terrafrom modules (vars.tf and key.tf) to reflect new name.
6. run "terraform init: in cloned repo directory
7. run "terraform apply" in cloned directory
8. Login to servers

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


-------------------------------------------

Data collection:


Step 1: Configure a Data Collector token in Chef Automate¶

All messages sent to Chef Automate are performed over HTTP and are authenticated with a pre-shared key called a token. Every Chef Automate installation configures a token by default, but we strongly recommend that you create your own.

Note

The Data Collector token has no minimum or maximum character length restrictions. While the UTF-8 character set is supported, US-ASCII is recommended for best results.

To set your own token, add the following to your /etc/delivery/delivery.rb file:

    data_collector['token'] = 'sometokenvalue'
    # Save and close the file

To apply the changes, run:

    sudo automate-ctl reconfigure

If you do not configure a token, the default token value is: 93a49a4f2482c64126f7b6015e6b0f30284287ee4054ff8807fb63d9cbd1c506


Step 2: Configure your Chef server to point to Chef Automate¶

In addition to forwarding Chef run data to Automate, Chef server will send messages to Chef Automate whenever an action is taken on a Chef server object, such as when a cookbook is uploaded to the Chef server or when a user edits a role.



Setting up data collection on Chef server versions 12.14 and higher¶

Channel the token setting through the veil secrets library because the token is considered a secret, and cannot appear in /etc/opscode/chef-server.rb:

    sudo chef-server-ctl set-secret data_collector token 'TOKEN'
    sudo chef-server-ctl restart nginx
    sudo chef-server-ctl restart opscode-erchef

Then add the following setting to /etc/opscode/chef-server.rb on the Chef server:

    data_collector['root_url'] = 'https://my-automate-server.mycompany.com/data-collector/v0/'
    # Add for compliance scanning
    profiles['root_url'] = 'https://my-automate-server.mycompany.com'
    # Save and close the file

To apply the changes, run:

    chef-server-ctl reconfigure

where my-automate-server.mycompany.com is the fully-qualified domain name of your Chef Automate server.

------------------------------------
Automate Compliance:

Use the following cookbook on to get compliance working on your nodes:
https://github.com/daringanitch/automate-compliance-cookbook.git

clone this cookbook into your chef-repo cookbooks folder then upload to your chef server.
1. $git clone https://github.com/daringanitch/automate-compliance-cookbook.git
2. $berks install && berks upload.

Add this cookbook to your nodes and make sure you have downloaded the correct security profiles on the automate server.

current cookbook has these security profiles:

chefadmin/linux-baseline 
chefadmin/windows-baseline

If you need more, add them to the attributes default.rb in this cookbook. (check json formatting) and add profiles on the automate server.
________________________________________________________________________
Workflow / Delivery

Make a working directory (workspace in the example):

$ mkdir ~/workspace && cd ~/workspace
Setup the Delivery CLI to, by default, contact the Chef Automate server at SERVER, with a default ENTERPRISE and ORGANIZATION:

$ delivery setup --server=SERVER --ent=ENTERPRISE --org=ORGANIZATION --user=USERNAME
Note

The server, enterprise, organization, and user must already exist (key generated for user and added to automate).

Create a cookbook:

$ chef generate cookbook NEW-COOKBOOK-NAME
$ cd NEW-COOKBOOK-NAME
This uses the Chef development kit to generate a new cookbook, including a default recipe and default ChefSpec tests.

Create an initial commit (use git status to verify the change) on the “master” branch:

$ git add .
$ git commit -m 'Initial Commit'
Running chef generate initialized a git repository automatically for this cookbook. If you created the build cookbook manually, initialize the git repository with the git init command.

Initialize the cookbook for Chef Automate:

$ delivery init
This creates a new project in Chef Automate, pushes the master branch, creates a feature branch, generates a default Chef Automate project configuration file, pushes the first change for review, and then opens a browser window that shows the change.

Now that you have initialized your project, it is recommended that you integrate the delivery-truck cookbook with your project. Delivery Truck can ensure good build cookbook behavior as well as provide you with recipes already set up to test your project cookbooks and applications.
