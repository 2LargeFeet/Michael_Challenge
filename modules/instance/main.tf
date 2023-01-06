data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "site" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  key_name                    = var.private_key
  vpc_security_group_ids      = [var.security_group]
  subnet_id                   = var.subnet
  associate_public_ip_address = true

  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "sudo add-apt-repository ppa:deadsnakes/ppa -y",
      "sudo apt update",
      "sudo apt upgrade -y",
      "sudo apt install apache2 python3-pip -y",
      "sudo a2enmod ssl",
      "sudo pip install ansible",
      "sudo chown -R ubuntu:ubuntu /var/www",
      "git clone https://github.com/2LargeFeet/Michael_Challenge.git",
      "sudo cp Michael_Challenge/modules/instance/configs/index.html /var/www/html/index.html",
      "sudo ansible-playbook Michael_Challenge/modules/instance/configs/cert.yml --extra-vars='{\"server_ip\": ${aws_instance.site.public_ip}}'"
#      "sudo systemctl restart apache2",
#      "sudo systemctl enable apache2"
    ]

    connection {
      host        = coalesce(self.public_ip, self.private_ip)
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.private_key_file)
    }
  }
}

### Test deployed server

data "http" "hello" {
  url = "http://${aws_instance.site.public_ip}"
  insecure = true
}

resource "null_resource" "hello_test" {

  lifecycle {
    postcondition {
      condition = length(split("Hello", data.http.hello.body)) > 1
      error_message = "The site does not greet the world."
    }
  }
}

output "ip" {
  value = aws_instance.site.public_ip
}