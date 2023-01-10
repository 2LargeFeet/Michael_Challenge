variable "cidr_block" {
}

#variable "external_cidr_subnets" {
#}

#variable "internal_cidr_subnets"{  
#}

variable "external_subnets" {
}

variable "internal_subnets" {
}

variable "site_instance" {
}

variable "health_check" {
   type = map(string)
   default = {
      "timeout"  = "10"
      "interval" = "20"
      "path"     = "/"
      "port"     = "443"
      "unhealthy_threshold" = "2"
      "healthy_threshold" = "3"
    }
}