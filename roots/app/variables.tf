variable "release_words" {
  description = "Words in the generated release name"
  type        = number
  default     = 2
}

variable "random_pet_dns_zone" {
  type        = string
  description = "Upstream input from module \"../networking\" output \"random_pet_dns_zone\""
}

