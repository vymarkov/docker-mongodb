// resource "aws_security_group" "mongo" {
//   description = "A security group for MongoDB server"

//   ingress {
//     from_port   = "22"
//     to_port     = "22"
//     self        = true
//     protocol    = "tcp"
//     cidr_blocks = ["${var.cidr_block}"]
//   }

//   ingress {
//     from_port   = "${var.port}"
//     to_port     = "${var.port}"
//     self        = true
//     protocol    = "tcp"
//     cidr_blocks = ["${var.cidr_block}"]
//   }

//   egress {
//     from_port   = 0
//     to_port     = 0
//     protocol    = "-1"
//     cidr_blocks = ["${var.cidr_block}"]
//   }

//   tags {
//     Name = "${var.project_name}-${var.env}-mongo"
//   }
// }
