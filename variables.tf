variable "region" {
    default = "us-east-1"
}

variable "access_key" {
}

variable "secret_key" {
}

variable "private_key_file" {
}

variable "private_key" {
}

# variable "site_instance" {
# }

variable profile_name {
    default = "default"
}

variable cidr_block {
    default = "10.23.0.0/16"
}

#variable external_cidr_subnets {
#    type = map
#    default = {
#        "us-east-1a" = "10.23.0.0/24"
#        "us-east-1b" = "10.23.1.0/24"
#    }
#}

#variable internal_cidr_subnets {
#    type = map
#    default = {
#        "us-east-1a" = "10.23.2.0/24"
#    }
#}

variable external_subnets {
    type = list(object({
        name  = string,
        availability_zone = string,
        cidr = string,
        location = string
    }))
}

variable internal_subnets {
    type = list(object({
        name  = string,
        availability_zone = string,
        cidr = string,
        location = string
    }))
}

#variable availability_zone {
#    type = list
#    default = [
#        us-east-1a,
#        us-east-1b
#    ]
#}