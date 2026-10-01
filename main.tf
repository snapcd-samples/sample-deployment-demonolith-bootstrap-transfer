# Hands the two roots to Snap CD as two modules, so a transfer can be proved
# and migrated by the server rather than by hand in a shell. The namespace is
# this sample's own; the stack is whichever one already exists.

data "snapcd_stack" "this" {
  name = var.stack_name
}

resource "snapcd_namespace" "this" {
  name           = var.namespace_name
  stack_id       = data.snapcd_stack.this.id
  default_engine = var.engine
}

data "snapcd_runner" "this" {
  name = var.runner_name
}

data "snapcd_state_store" "default" {
  name = "default"
}

# Neither root declares a backend, so Snap CD supplies one: this file is
# written beside the code, and the -backend-config flags below point it at the
# state store. Each module keys its own state by its own name, which is what
# keeps the two states apart through the transfer.
resource "snapcd_namespace_extra_file" "backend" {
  file_name    = "backend.tf"
  namespace_id = snapcd_namespace.this.id
  overwrite    = false
  contents     = <<-EOT
    terraform {
      backend "http" {}
    }
  EOT
}

resource "snapcd_namespace_input_from_definition" "module_name" {
  name            = "SNAPCD_MODULE_NAME"
  namespace_id    = snapcd_namespace.this.id
  definition_name = "ModuleName"
  input_kind      = "EnvVar"
}

resource "snapcd_namespace_terraform_array_flag" "backend_config" {
  for_each = {
    address        = "${var.snapcd_server_url_from_runner}/api/${var.organization_id}/state/${data.snapcd_state_store.default.id}/$${SNAPCD_MODULE_NAME}"
    lock_address   = "${var.snapcd_server_url_from_runner}/api/${var.organization_id}/state/${data.snapcd_state_store.default.id}/$${SNAPCD_MODULE_NAME}/lock"
    unlock_address = "${var.snapcd_server_url_from_runner}/api/${var.organization_id}/state/${data.snapcd_state_store.default.id}/$${SNAPCD_MODULE_NAME}/unlock"
    lock_method    = "POST"
    unlock_method  = "POST"
    username       = "$${SNAPCD_CLIENT_ID}"
    password       = "$${SNAPCD_CLIENT_SECRET}"
  }

  namespace_id = snapcd_namespace.this.id
  task         = "Init"
  flag         = "BackendConfig"
  value        = "${each.key}=${each.value}"
}

# The source: the root the marked resources leave.
resource "snapcd_module" "app" {
  name                = var.source_module_name
  namespace_id        = snapcd_namespace.this.id
  source_url          = var.source_url
  source_revision     = var.branch_name
  source_subdirectory = "roots/app"
  runner_id           = data.snapcd_runner.this.id
  engine              = var.engine
}

# The receiver: the root they arrive in.
resource "snapcd_module" "networking" {
  name                = var.receiver_module_name
  namespace_id        = snapcd_namespace.this.id
  source_url          = var.source_url
  source_revision     = var.branch_name
  source_subdirectory = "roots/networking"
  runner_id           = data.snapcd_runner.this.id
  engine              = var.engine
}

resource "snapcd_module_input_from_literal" "app_params" {
  for_each = {
    release_words = var.release_words
  }

  module_id     = snapcd_module.app.id
  name          = each.key
  literal_value = each.value
  input_kind    = "Param"
  type          = "String"
}

resource "snapcd_module_input_from_output" "app_random_pet_dns_zone" {
  input_kind       = "Param"
  module_id        = snapcd_module.app.id
  name             = "random_pet_dns_zone"
  output_module_id = snapcd_module.networking.id
  output_name      = "random_pet_dns_zone"
}

