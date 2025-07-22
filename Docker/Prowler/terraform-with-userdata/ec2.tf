data "local_file" "ssh_key" {
  filename = var.ssh_key_path
}

resource "aws_key_pair" "my_key" {
  key_name   = "my-key"
  public_key = data.local_file.ssh_key.content
}

resource "aws_instance" "web_server" {
  ami                    = var.instance_ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.my_key.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.prowler.id]
  associate_public_ip_address = true
  tags = {
    Name = var.instance_name
  }
}
