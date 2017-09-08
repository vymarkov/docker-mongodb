variable cidr_block {
  default = "0.0.0.0/0"
}

variable aws_azs {
  default = {
    us-east-1 = "us-east-1a,us-east-1c,us-east-1d,us-east-1e"
  }
}

variable aws_ami {
  default = "ami-812ec0ec"
}

variable aws_region {
  default = "us-east-1"
}

variable security_groups {}

variable project_name {}

variable env {}

variable keypair {}

variable private_key {}

variable docker_image {
  default = "vymarkov/mongo:3.2"
}

variable username {
  description = "A username which will be used for further managing MongoDB server"
  default     = "admin"
}

variable password {
  default = "password"
}

variable database {
  default = "test"
}

variable port {
  default = "27017"
}

variable replsetname {
  default = "rs0"
}

data template_file user_data {
  template = "${file("${path.module}/mongo.yml.tpl")}"

  vars {
    username     = "${var.username}"
    password     = "${var.password}"
    database     = "${var.database}"
    port         = "${var.port}"
    replset_name = "${var.replsetname}"
    docker_image = "${var.docker_image}"
  }
}

resource "aws_security_group" "mongo" {
  description = "A security group for MongoDB server"

  ingress {
    from_port   = "${var.port}"
    to_port     = "${var.port}"
    self        = true
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.cidr_block}"]
  }

  tags {
    Name = "${var.project_name}-${var.env}-mongo"
  }
}

resource "aws_instance" "mongo_primary" {
  count                       = "1"
  ami                         = "${var.aws_ami}"
  instance_type               = "t2.micro"
  key_name                    = "${var.keypair}"
  availability_zone           = "${element(split(",", lookup(var.aws_azs, var.aws_region)), count.index % length(split(",", lookup(var.aws_azs, var.aws_region))))}"
  associate_public_ip_address = true
  user_data                   = "${data.template_file.user_data.rendered}"

  root_block_device {
    volume_size = 16
  }

  vpc_security_group_ids = [
    "${aws_security_group.mongo.id}",
    "${var.security_groups}",
  ]

  connection {
    user        = "rancher"
    private_key = "${var.private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo Server has been started successfully!",
      "sudo apt-get update",
      "sudo apt-get install -y python python-pip",
    ]
  }

  tags {
    Name        = "${var.project_name}-${var.env}-mongo-primary"
    ReplSetName = "${var.replsetname}"
    Role        = "primary"
    ProjectName = "${var.project_name}"
    Env         = "${var.env}"
  }
}

output mongo_addr {
  value = "${aws_instance.mongo_primary.public_ip}"
}

output "mongo_shell_cmd" {
  value = "mongo --norc -u ${var.username} -p ${var.password} ${aws_instance.mongo_primary.public_ip}:${var.port}/${var.database}"
}

output "mongodb_conn_string" {
  value = "mongodb://${var.username}:${var.password}@${aws_instance.mongo_primary.public_ip}:${var.port}/${var.database}"
}
