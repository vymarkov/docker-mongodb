resource "aws_instance" "primary" {
  count                       = "1"
  ami                         = "${var.aws_ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.keypair}"
  availability_zone           = "${element(split(",", lookup(var.aws_azs, var.aws_region)), count.index % length(split(",", lookup(var.aws_azs, var.aws_region))))}"
  associate_public_ip_address = true
  user_data                   = "${data.template_file.user_data.rendered}"

  root_block_device {
    volume_size = "${var.primary_volume_size}"
  }
  vpc_security_group_ids = [
    "${var.security_groups}"
  ]
  connection {
    user        = "rancher"
    private_key = "${file(var.private_key)}"
    timeout     = "10m"
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

resource "aws_instance" "secondary" {
  count                       = "${var.cluster_size - var.arbiter_count - 1}"
  ami                         = "${var.aws_ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${file(var.keypair)}"
  availability_zone           = "${element(split(",", lookup(var.aws_azs, var.aws_region)), count.index % length(split(",", lookup(var.aws_azs, var.aws_region))))}"
  associate_public_ip_address = true
  user_data                   = "${data.template_file.user_data.rendered}"

  root_block_device {
    volume_size = "${var.primary_volume_size}"
  }
  vpc_security_group_ids = [
    "${var.security_groups}",
  ]

  connection {
    user        = "rancher"
    private_key = "${file(var.private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo Server has been started successfully!",
      "sudo apt-get update",
      "sudo apt-get install -y python python-pip",
    ]
  }

  tags {
    Name        = "${var.project_name}-${var.env}-mongo-${format("secondary-%02d", count.index + 1)}"
    ReplSetName = "${var.replsetname}"
    Role        = "secondary"
    ProjectName = "${var.project_name}"
    Env         = "${var.env}"
  }
  depends_on = ["aws_instance.primary"]
}

resource "aws_instance" "arbiter" {
  count                       = "${var.arbiter_count}"
  ami                         = "${var.aws_ami}"
  instance_type               = "${var.arbiter_instance_type}"
  key_name                    = "${var.keypair}"
  availability_zone           = "${element(split(",", lookup(var.aws_azs, var.aws_region)), count.index % length(split(",", lookup(var.aws_azs, var.aws_region))))}"
  associate_public_ip_address = true
  user_data                   = "${data.template_file.user_data.rendered}"

  root_block_device {
    volume_size = 16
  }
  vpc_security_group_ids = [
    "${var.security_groups}",
  ]
  connection {
    user        = "rancher"
    private_key = "${file(var.private_key)}"
  }
  provisioner "remote-exec" {
    inline = [
      "echo Server has been started successfully!",
      "sudo apt-get update",
      "sudo apt-get install -y python python-pip",
    ]
  }
  tags {
    Name        = "${var.project_name}-${var.env}-mongo-arbiter"
    ReplSetName = "${var.replsetname}"
    Role        = "arbiter"
    ProjectName = "${var.project_name}"
    Env         = "${var.env}"
  }
  depends_on = ["aws_instance.primary"]
}

resource "aws_instance" "hidden_member" {
  count                       = "${var.hidden_members_count}"
  ami                         = "${var.aws_ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.keypair}"
  availability_zone           = "${element(split(",", lookup(var.aws_azs, var.aws_region)), count.index % length(split(",", lookup(var.aws_azs, var.aws_region))))}"
  associate_public_ip_address = true
  user_data                   = "${data.template_file.user_data.rendered}"

  root_block_device {
    volume_size = "${var.primary_volume_size}"
  }

  vpc_security_group_ids = [
    "${var.security_groups}"
  ]

  connection {
    user        = "rancher"
    private_key = "${file(var.private_key)}"
  }

  provisioner "remote-exec" {
    inline = [
      "echo Server has been started successfully!",
      "sudo apt-get update",
      "sudo apt-get install -y python python-pip",
    ]
  }
  tags {
    Name        = "${var.project_name}-${var.env}-mongo-${format("hidden-member-%02d", count.index + 1)}"
    ReplSetName = "${var.replsetname}"
    Role        = "hidden-member"
    ProjectName = "${var.project_name}"
    Env         = "${var.env}"
  }
  depends_on = ["aws_instance.primary"]
}

resource "aws_instance" "delayed_member" {
  count                       = "${var.delayed_members_count}"
  ami                         = "${var.aws_ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${var.keypair}"
  availability_zone           = "${element(split(",", lookup(var.aws_azs, var.aws_region)), count.index % length(split(",", lookup(var.aws_azs, var.aws_region))))}"
  associate_public_ip_address = true
  user_data                   = "${data.template_file.user_data.rendered}"

  root_block_device {
    volume_size = "${var.primary_volume_size}"
  }

  vpc_security_group_ids = [
    "${var.security_groups}"
  ]

  connection {
    user        = "rancher"
    private_key = "${file(var.private_key)}"
  }
  
  provisioner "remote-exec" {
    inline = [
      "echo Server has been started successfully!",
      "sudo apt-get update",
      "sudo apt-get install -y python python-pip",
    ]
  }
  tags {
    Name        = "${var.project_name}-${var.env}-mongo-${format("delayed-member-%02d", count.index + 1)}"
    ReplSetName = "${var.replsetname}"
    Role        = "delayed-member"
    ProjectName = "${var.project_name}"
    Env         = "${var.env}"
  }
  depends_on = ["aws_instance.primary"]
}
