variable "AWS_REGION" {
  default = "us-west-2"
}
variable "PATH_TO_PRIVATE_KEY" {
  default = "mykey"
}
variable "PATH_TO_PUBLIC_KEY" {
  default = "mykey.pub"
}
variable "chef_server_name" {
  default = "chef-server-nvpc"
}
variable "automate_server_name" {
  default = "chef-automate-nvpc"
}
variable "runner_name_1" {
  default = "runner_1_nvpc"
}
variable "runner_name_2" {
  default = "runner_2_nvpc"
}
variable "s3_bucket_name" {
  default = "chef-automate-novpc"
}
variable "aws_iam_role" {
  default = "tr_s3_iam_role"
}
variable "aws_iam_instance_profile" {
  default = "tr_s3_instance_profile"
}
variable "aws_iam_role_policy" {
  default = "tr_s3_iam_role_policy"
}
variable "private_subnet_id_1" {
  default = "subnet-043e4110716c37850"
}
variable "private_subnet_id_2" {
  default = "subnet-043e4110716c37850"
}
variable "public_subnet_id_1" {
  default = "subnet-043e4110716c37850"
}
variable "public_subnet_id_2" {
  default = "subnet-043e4110716c37850"
}
variable "vpc_security_group_ids" {
  default = "sg-04f8f6c4122d58779"
}
variable "AMIS" {
  type = "map"
  default = {
    us-east-1 = "ami-e251209a"
    us-west-2 = "ami-e251209a"
    us-west-1 = "ami-e251209a"
   }
}
