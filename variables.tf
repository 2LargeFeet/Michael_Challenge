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

variable profile_name {
    default = "default"
}

variable cidr_block {
    default = "10.23.0.0/16"
}

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
