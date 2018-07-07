# Create an IAM role for the Web Servers.
resource "aws_iam_role" "tr_s3_iam_role" {
    name = "${var.aws_iam_role}"
        assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "tr_s3_instance_profile" {
    name = "${var.aws_iam_instance_profile}"
    role = "${var.aws_iam_role}"
}

  resource "aws_iam_role_policy" "tr_s3_iam_role_policy" {
  name = "${var.aws_iam_role_policy}"
  role = "${aws_iam_role.tr_s3_iam_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::${var.s3_bucket_name}"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": ["arn:aws:s3:::${var.s3_bucket_name}/*"]
    }
  ]
}
EOF
}
