data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_vpc" "main" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "external" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "external"
  }
}

resource "aws_subnet" "subnets" {
  for_each   = { for subnets in setunion(var.external_subnets, var.internal_subnets) : subnets.name => subnets }
  vpc_id     = aws_vpc.main.id
  cidr_block = each.value.cidr
  availability_zone = each.value.availability_zone

  tags = {
    Name = each.value.name
    Location = each.value.location
  }
}

resource "aws_route_table" "out" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.external.id
  }
}

resource "aws_route_table_association" "out" {
  for_each       = aws_subnet.subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.out.id
}

resource "aws_security_group" "restrict_lb" {
  name        = "restrict_lb"
  description = "restrict access to server"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "restrict_instance" {
  name        = "restrict_instance"
  description = "restrict access to server"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32", "10.23.0.0/23"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.body)}/32", "10.23.0.0/23"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Load Balancing
# Can be configured to redirect to HTTPS, however certificates 
# are out of scope currently. For the HTTPS redirect, visit
# the EC2 instance's IP address. Right now, the load balanging
# stuff is just for show.

resource "aws_lb" "http" {

  name          = "siteLB"
  internal      = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.restrict_lb.id]
  subnets       = [for subnet in aws_subnet.subnets : subnet.id if subnet.tags.Location == "external"]
}

resource "aws_lb_target_group" "siteGroup" {
   name               = "httpGroup"
   target_type        = "instance"
   port               = 80
   protocol           = "HTTP"
   vpc_id             = aws_vpc.main.id
   health_check {
      healthy_threshold   = var.health_check["healthy_threshold"]
      interval            = var.health_check["interval"]
      unhealthy_threshold = var.health_check["unhealthy_threshold"]
      timeout             = var.health_check["timeout"]
      path                = var.health_check["path"]
      port                = var.health_check["port"]
  }
}

resource "aws_lb_target_group_attachment" "siteAttach" {
  target_group_arn = aws_lb_target_group.siteGroup.arn
  target_id        = var.site_instance
  port             = 80
}

resource "aws_lb_listener" "lb_listener_http" {
   load_balancer_arn    = aws_lb.http.id
   port                 = "80"
   protocol             = "HTTP"
   default_action {
    target_group_arn = aws_lb_target_group.siteGroup.id
    type             = "forward"
  }
}

resource "aws_wafv2_web_acl" "lb_acl" {
  name  = "lb_acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "RateLimit"
    priority = 1

    action {
      block {}
    }

    statement {

      rate_based_statement {
        aggregate_key_type = "IP"
        limit              = 500
      }
    }

## Cloudwatch disalbed for now so I don't get billed.
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "RateLimit"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "my-web-acl"
    sampled_requests_enabled   = false
  }
}

resource "aws_wafv2_web_acl_association" "waf" {
  resource_arn = aws_lb.http.arn
  web_acl_arn  = aws_wafv2_web_acl.lb_acl.arn
}