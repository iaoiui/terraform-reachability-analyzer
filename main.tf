terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.4.0"
    }
  }
}

locals {
  region = "ap-northeast-1"
}

provider "aws" {
  profile = "home"
  region = "ap-northeast-1"
}

