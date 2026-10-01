# The receiving root: the network's own naming and addressing, in its own
# state. The transfer adds the DNS zone that grew up in the app root - it lands
# in this file, appended by the code move.

resource "random_pet" "vpc_name" {
  length = 2
}

resource "random_uuid" "private_subnet_id" {
}

resource "random_pet" "dns_zone" {
  length = 2
}

resource "random_uuid" "dns_zone_id" {
}

