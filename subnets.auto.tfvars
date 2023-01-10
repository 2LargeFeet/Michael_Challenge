external_subnets = [
    {
        name  = "subnet1",
        cidr  = "10.23.0.0/24",
        availability_zone = "us-east-1a",
        location = "external"
    },
    {
        name  = "subnet2",
        cidr  = "10.23.1.0/24",
        availability_zone = "us-east-1b",
        location = "external"
    }
]

internal_subnets = [
    {
        name  = "subnet3",
        cidr  = "10.23.2.0/24",
        availability_zone = "us-east-1a",
        location = "internal"
    }
]