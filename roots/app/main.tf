# The source root. Two of its resources belong in networking: the DNS zone and
# its id grew up here, beside the app they serve. Both are marked with a bare
# transfer comment; the receiver is named once, on the command line.
#
# endpoint_name reads the moved dns_zone. After the move that reference crosses
# a root boundary, so the code move rewrites it into an input variable here,
# adds the matching output to networking, and adds the wiring that passes the
# value at runtime.

resource "random_pet" "release_name" {
  length = var.release_words
}

resource "random_pet" "endpoint_name" {
  prefix = var.random_pet_dns_zone
}


