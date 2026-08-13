variable "imagebuilder_images" {
  description = <<EOT
Map of imagebuilder_images, attributes below
Required:
    - infrastructure_configuration_arn
Optional:
    - container_recipe_arn
    - distribution_configuration_arn
    - enhanced_image_metadata_enabled
    - execution_role
    - image_recipe_arn
    - region
    - tags
    - tags_all
    - image_scanning_configuration (block):
        - ecr_configuration (optional, block):
            - container_tags (optional)
            - repository_name (optional)
        - image_scanning_enabled (optional)
    - image_tests_configuration (block):
        - image_tests_enabled (optional)
        - timeout_minutes (optional)
    - logging_configuration (block):
        - log_group_name (required)
    - workflow (block):
        - on_failure (optional)
        - parallel_group (optional)
        - parameter (optional, block):
            - name (required)
            - value (required)
        - workflow_arn (required)
EOT

  type = map(object({
    infrastructure_configuration_arn = string
    container_recipe_arn             = optional(string)
    distribution_configuration_arn   = optional(string)
    enhanced_image_metadata_enabled  = optional(bool)
    execution_role                   = optional(string)
    image_recipe_arn                 = optional(string)
    region                           = optional(string)
    tags                             = optional(map(string))
    tags_all                         = optional(map(string))
    image_scanning_configuration = optional(object({
      ecr_configuration = optional(object({
        container_tags  = optional(set(string))
        repository_name = optional(string)
      }))
      image_scanning_enabled = optional(bool)
    }))
    image_tests_configuration = optional(object({
      image_tests_enabled = optional(bool)
      timeout_minutes     = optional(number)
    }))
    logging_configuration = optional(object({
      log_group_name = string
    }))
    workflow = optional(list(object({
      on_failure     = optional(string)
      parallel_group = optional(string)
      parameter = optional(list(object({
        name  = string
        value = string
      })))
      workflow_arn = string
    })))
  }))
  validation {
    condition = alltrue([
      for k, v in var.imagebuilder_images : (
        v.image_tests_configuration == null || (v.image_tests_configuration.timeout_minutes == null || (v.image_tests_configuration.timeout_minutes >= 60 && v.image_tests_configuration.timeout_minutes <= 1440))
      )
    ])
    error_message = "must be between 60 and 1440"
  }
  validation {
    condition = alltrue([
      for k, v in var.imagebuilder_images : (
        v.workflow == null || alltrue([for item in v.workflow : (item.parallel_group == null || (can(regex("^[A-Za-z0-9][A-Za-z0-9-_+#]{0,99}$", item.parallel_group))))])
      )
    ])
    error_message = "valid parallel group string must be provider"
  }
  # Note: 8 additional provider-side validators are enforced at apply time but not mirrored as validation{} blocks here (bespoke or non-mechanically-translatable).
}

