resource "aws_efs_file_system" "efs" {
  creation_token = var.efs_name
  tags = {
    Name = var.efs_name
  }
}

resource "aws_security_group" "efs_sg" {
  name        = var.efs_sg_name
  description = "Allow NFS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.efs_sg_name
  }
}
