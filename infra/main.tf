# Clusters
resource "aws_ecs_cluster" "cluster" {
  name = "waste-classifier-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}


# Frontend Service
module "frontend" {
  source           = "./modules/ecs-service"
  app_name         = "frontend"
  region           = var.region
  environment      = var.environment
  cluster_id       = aws_ecs_cluster.cluster.id
  vpc_id           = var.vpc_id
  subnets          = var.subnets
  docker_image_uri = var.frontend_image
  container_port   = 80
  listener_port    = 80
  default_sg_id    = var.default_sg_id
}

# Backend Service
module "backend" {
  source           = "./modules/ecs-service"
  app_name         = "endpoint"
  region           = var.region
  environment      = var.environment
  cluster_id       = aws_ecs_cluster.cluster.id
  vpc_id           = var.vpc_id
  subnets          = var.subnets
  docker_image_uri = var.endpoint_image
  container_port   = 8000
  listener_port    = 80
  default_sg_id    = var.default_sg_id
}
