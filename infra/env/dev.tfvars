region      = "eu-central-1"
environment = "dev"

vpc_id  = "vpc-040b966ad9e2c2b50"
default_sg_id = "sg-0e1b1afc478bbacd8"
subnets = ["subnet-0ec17bc93f5797862", "subnet-03f07e825b001bf8e", "subnet-0041297007edd0456"]

frontend_image = "427058101105.dkr.ecr.eu-central-1.amazonaws.com/waste-classifier-repo:frontend-latest"
endpoint_image  = "427058101105.dkr.ecr.eu-central-1.amazonaws.com/waste-classifier-repo:endpoint-latest"