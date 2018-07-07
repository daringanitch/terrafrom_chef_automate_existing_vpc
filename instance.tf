resource "aws_instance" "chef-server" {
  ami           = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type = "t2.2xlarge"
  root_block_device {
  volume_type = "gp2"
  volume_size = "100"
  delete_on_termination = "true"

}
  tags {
        Name =  "${var.chef_server_name}"
        Department = "organization"
    }

    iam_instance_profile = "${aws_iam_instance_profile.tr_s3_instance_profile.id}"
    user_data = <<HEREDOC
    #!/bin/bash
    sudo yum update
    sudo yum -y install curl
    echo $(curl -s http://169.254.169.254/latest/meta-data/public-hostname) | xargs sudo hostname


    # create staging directories
  if [ ! -d /drop ]; then
     mkdir /drop
  fi
  if [ ! -d /downloads ]; then
      mkdir /downloads
  fi

    # download the Chef server package
  if [ ! -f /downloads/chef-server-core_12.17.33_amd64.rpm ]; then
    echo "Downloading the Chef server package..."
    wget -nv -P /downloads https://packages.chef.io/files/stable/chef-server/12.17.33/el/7/chef-server-core-12.17.33-1.el7.x86_64.rpm
    wget -nv -P /downloads https://packages.chef.io/files/stable/chef-manage/2.5.16/el/7/chef-manage-2.5.16-1.el7.x86_64.rpm
  fi

# install Chef server
  if [ ! $(which chef-server-ctl) ]; then
    echo "Installing Chef server..."
    rpm -Uvh /downloads/chef-server-core-12.17.33-1.el7.x86_64.rpm
    sudo chef-server-ctl reconfigure

    echo "Waiting for services..."
    until (curl -D - http://localhost:8000/_status) | grep "200 OK"; do sleep 15s; done
    while (curl http://localhost:8000/_status) | grep "fail"; do sleep 15s; done

    echo "Creating initial user and organization..."
    sudo chef-server-ctl user-create chefadmin Chef Admin support@example.com Island988876 --filename /drop/chefadmin.pem
    echo $(curl -s http://169.254.169.254/latest/meta-data/local-hostname)>/drop/hostname.txt
    aws s3 cp /drop/chefadmin.pem s3://chef-automate-novpc/
    aws s3 cp /drop/hostname.txt s3://chef-automate-novpc/
    sudo chef-server-ctl org-create myorg "myorg" --association_user chefadmin --filename myorg.pem
    sleep 5
    rpm -Uvh /downloads/chef-manage-2.5.16-1.el7.x86_64.rpm
    sudo chef-server-ctl reconfigure
    sudo chef-manage-ctl reconfigure
    sudo ACCEPT_EULA=Yes
 fi

 echo "Your Chef server is ready!"
HEREDOC


  iam_instance_profile = "${aws_iam_instance_profile.tr_s3_instance_profile.id}"

  # the VPC subnet
  subnet_id = "${var.public_subnet_id_1}"

  # the security group
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]

  # the public SSH key
  key_name = "${aws_key_pair.mykeypair.key_name}"
}

resource "aws_instance" "automate-server" {
  ami           = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type = "t2.2xlarge"
  root_block_device {
  volume_type = "gp2"
  volume_size = "100"
  delete_on_termination = "true"

}
  tags {
        Name = "${var.automate_server_name}"
        Department = "organization"
    }

    iam_instance_profile = "${aws_iam_instance_profile.tr_s3_instance_profile.id}"
    user_data = <<HEREDOC
    #!/bin/bash -x
    sudo yum update
    sudo yum -y install curl
    echo $(curl -s http://169.254.169.254/latest/meta-data/public-hostname) | xargs sudo hostname




    # create downloads directory
    if [ ! -d /downloads ]; then
      mkdir /downloads
    fi

    # download the Chef Automate package
    if [ ! -f /downloads/automate_1.8.38-1_amd64.rpm ]; then
      echo "Downloading the Chef Automate package..."
      wget -nv -P /downloads https://packages.chef.io/files/stable/automate/1.8.68/el/7/automate-1.8.68-1.el7.x86_64.rpm
    fi

    # install Chef Automate
    if [ ! $(which automate-ctl) ]; then
      echo "Installing Chef Automate..."
      rpm -Uvh /downloads/automate-1.8.68-1.el7.x86_64.rpm

    # run preflight check
      sudo automate-ctl preflight-check

    # run setup
      sleep 300
      aws s3 cp s3://ist-chef-license/hostname.txt /tmp/
      chef_server_fqdn=$(cat /tmp/hostname.txt)
      aws s3 cp s3://chef-automate-novpc/chefadmin.pem /tmp/
      aws s3 cp s3://chef-automate-novpc/automate.license /tmp/
      sleep 30
      sudo automate-ctl setup --license /tmp/automate.license --key /tmp/chefadmin.pem --server-url https://$chef_server_fqdn/organizations/ist --fqdn $(hostname) --enterprise default --configure --no-build-node
      sudo automate-ctl reconfigure

    # wait for all services to come online
      echo "Waiting for services..."
      until (curl --insecure -D - https://localhost/api/_status) | grep "200 OK"; do sleep 1m && automate-ctl restart; done
      while (curl --insecure https://localhost/api/_status) | grep "fail"; do sleep 15s; done

    # create an initial user
      echo "Creating chefadmin user..."
      sudo automate-ctl create-user default chefadmin --password Island988876 --roles "admin"
    fi

echo "Your Chef Automate server is ready!"
HEREDOC

    # the VPC subnet
  subnet_id = "${var.public_subnet_id_2}"

  # the security group
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]

  # the public SSH key
  key_name = "${aws_key_pair.mykeypair.key_name}"
}


resource "aws_instance" "runner1" {
  ami           = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type = "t2.micro"
  root_block_device {
  volume_type = "gp2"
  volume_size = "20"
  delete_on_termination = "true"
}
  tags {
        Name = "${var.runner_name_1}"
        Department = "organization"
    }

    iam_instance_profile = "${aws_iam_instance_profile.tr_s3_instance_profile.id}"
    user_data = <<HEREDOC
    #!/bin/bash
    sudo yum update -y
    echo $(curl -s http://169.254.169.254/latest/meta-data/local-hostname) | xargs sudo hostname
HEREDOC

  # the VPC subnet
  subnet_id = "${var.private_subnet_id_2}"

  # the security group
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]

  # the public SSH key
  key_name = "${aws_key_pair.mykeypair.key_name}"
}


resource "aws_instance" "runner2" {
  ami           = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type = "t2.micro"
  root_block_device {
  volume_type = "gp2"
  volume_size = "20"
  delete_on_termination = "true"


}
  tags {
        Name = "${var.runner_name_2}"
        Department = "organization"
    }

    iam_instance_profile = "${aws_iam_instance_profile.tr_s3_instance_profile.id}"
    user_data = <<HEREDOC
    #!/bin/bash
    sudo yum update -y
    echo $(curl -s http://169.254.169.254/latest/meta-data/local-hostname) | xargs sudo hostname
HEREDOC

  # the VPC subnet
  subnet_id = "${var.private_subnet_id_1}"

  # the security group
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]

  # the public SSH key
  key_name = "${aws_key_pair.mykeypair.key_name}"
}
