# Obtener la última AMI de Amazon Linux 2023 desde el Parameter Store de AWS
data "aws_ssm_parameter" "amzn2" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "kind-host" {
  ami                         = data.aws_ssm_parameter.amzn2.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.sg.id]
  associate_public_ip_address = true
  
  key_name = null
  iam_instance_profile = "LabInstanceProfile"
  user_data = file("${path.module}/user_data.sh")
  
  tags = {
    Name = "kind-control-plane"
  }
}
