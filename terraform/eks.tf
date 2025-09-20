# VPC (simple: 2 public, 2 private subnets)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = "innovatemart-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false

  tags = {
    Name        = "innovatemart-vpc"
    Environment = "dev"
  }
}

# EKS Cluster + Node Group
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0.0"

  name               = "innovatemart-cluster"
  kubernetes_version = "1.33"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets # EKS nodes in private subnets
  
  endpoint_public_access = true

  eks_managed_node_groups = {
    default = {
      desired_size = 1
      min_size     = 1
      max_size     = 2

      instance_types = ["t2.micro","m1.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

  tags = {
    Environment = "dev"
    Project     = "bedrock"
  }
}

# Node group IAM policies are handled automatically by the eks module.
# The following resources should be removed to avoid conflicts and follow best practices.
/*
resource "aws_iam_role_policy_attachment" "node_group_worker" {
  role = module.eks.eks_managed_node_groups["default"].iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "node_group_cni" {
  role = module.eks.eks_managed_node_groups["default"].iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_iam_role_policy_attachment" "node_group_ecr" {
  role = module.eks.eks_managed_node_groups["default"].iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}
*/

# Cluster Access for IAM User
resource "aws_eks_access_entry" "admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::491085392395:user/innovatemart-dev-readonly"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_eks_access_entry.admin.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  access_scope {
    type = "cluster"
  }
}
