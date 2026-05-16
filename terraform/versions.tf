terraform {
  required_version = ">= 1.6.0"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.40"
    }
  }

  # Remote state stored in DigitalOcean Spaces (S3-compatible).
  # Before first use, create a Space and set these env vars:
  #   AWS_ACCESS_KEY_ID     = <spaces_access_key>
  #   AWS_SECRET_ACCESS_KEY = <spaces_secret_key>
  # Then run: terraform init
  backend "s3" {
    endpoints = {
      s3 = "https://nyc3.digitaloceanspaces.com"
    }
    bucket = "sre-capstone-tfstate"
    key    = "terraform.tfstate"
    region = "us-east-1" # placeholder required by S3 backend

    # Credentials are read automatically from env vars:
    #   export AWS_ACCESS_KEY_ID="<spaces_access_key>"
    #   export AWS_SECRET_ACCESS_KEY="<spaces_secret_key>"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
}

provider "digitalocean" {
  token = var.do_token
}
