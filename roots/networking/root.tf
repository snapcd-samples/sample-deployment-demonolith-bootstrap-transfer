# No backend block: Snap CD supplies one, written beside this code as an extra
# file and pointed at the state store by the flags the deployment root sets.
terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}
