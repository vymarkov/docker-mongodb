variable cidr_block {
  default = "0.0.0.0/0"
}

variable aws_azs {
  default = {
    us-east-1 = "us-east-1a,us-east-1c,us-east-1d,us-east-1e"
    eu-west-1 = "eu-west-1a,eu-west-1b,eu-west-1c"
  }
}

variable aws_ami {
  default = "ami-812ec0ec"
}

variable aws_region {
  default = "us-east-1"
}

variable instance_type {
  default = "t2.micro"
}

variable primary_volume_size {
  default = 128
}

variable arbiter_volume_size {
  default = 8
}

variable arbiter_instance_type {
  default = "t2.nano"
}

variable security_groups {
  default = ""
}

variable project_name {}

variable env {}

variable keypair {}

variable private_key {}

variable docker_image {
  default = "vymarkov/mongo:3.4"
}

variable cluster_size {
  default = 3
}

variable enable_arbiter_member {
  default = false
}

variable hidden_members_count {
  default = 0
}

variable delayed_members_count {
  default = 0
}

variable slaveDelay {
  default = 3600
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
  default = 27017
}

variable replsetname {
  default = "rs0"
}

data "template_file" "user_data" {
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

data "template_file" "boot_replset_cluster" {
  template = "${file("${path.module}/bootReplSet.js")}"

  vars {
    primary_addr           = "${aws_instance.primary.private_dns}"
    secondary_members_addr = "${join(",", aws_instance.secondary.*.private_dns)}"
    arbiter_addr           = "${join(",", aws_instance.arbiter.*.private_dns)}"
    delayed_members        = "${join(",", aws_instance.delayed_member.*.private_dns)}"
    hidden_members         = "${join(",", aws_instance.hidden_member.*.private_dns)}"
    port                   = "${var.port}"
    slaveDelay             = "${var.slaveDelay}"
  }
}

resource "null_resource" "cluster" {
  triggers {
    primary           = "${var.cluster_size != 0 ? aws_instance.primary.private_dns :  ""}"
    secondary_members = "${join(",", aws_instance.secondary.*.private_dns)}"
    arbiter           = "${join(",", aws_instance.arbiter.*.private_dns)}"
  }

  connection {
    user        = "rancher"
    host        = "${aws_instance.primary.public_ip}"
    private_key = "${file(var.private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${data.template_file.boot_replset_cluster.rendered}' > /tmp/bootReplSet.js",
      "docker version",
      "docker run --rm -ti mongo:3.2 mongo --version",
      "docker run --rm -ti -v /tmp/bootReplSet.js:/tmp/bootReplSet.js mongo:3.2 mongo -u ${var.username} -p ${var.password} ${aws_instance.primary.private_dns}:${var.port}/admin /tmp/bootReplSet.js",
      "rm /tmp/bootReplSet.js",
    ]
  }

  depends_on = [
    "aws_instance.primary",
    "aws_instance.secondary",
    "aws_instance.arbiter",
    "data.template_file.boot_replset_cluster",
  ]
}

output "mongo_shell_cmd" {
  value = "mongo --norc -u ${var.username} -p ${var.password} ${aws_instance.primary.public_ip}:${var.port}/${var.database}"
}

output "mongodb_conn_string" {
  value = "mongodb://${var.username}:${var.password}@${join(",", aws_instance.secondary.*.private_dns)},${aws_instance.primary.private_dns}/${var.database}?replSet=${var.replsetname}"
}

output "mongodb_develop_conn_string" {
  value = "mongodb://${var.username}:${var.password}${aws_instance.primary.public_ip}/${var.database}?replSet=${var.replsetname}"
}
