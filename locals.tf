# locals {
#   # Common tags applied to all resources
#   common_tags = {
#     Environment     = var.environment
#     Project        = var.project_name
#     ManagedBy      = "Terraform"
#     SecurityLevel  = "High"
#     KeyAlgorithm   = "ED25519"
#     CreatedDate    = formatdate("YYYY-MM-DD", timestamp())
#     RotationDue    = formatdate("YYYY-MM-DD", timeadd(timestamp(), "${var.key_rotation_days * 24}h"))
#   }
  
#   # Resource naming convention
#   resource_prefix = "${var.project_name}-${var.environment}"
  
#   # Security-specific locals
#   kms_key_name = "${local.resource_prefix}-webserver-keys"
#   ssm_parameter_prefix = "/${var.project_name}/${var.environment}/webserver"
  
#   # Conditional values based on environment
#   log_retention_days = var.environment == "prod" ? 365 : 90
#   enable_deletion_protection = var.environment == "prod" ? true : false
  
#   # CloudWatch alarm thresholds by environment
#   key_access_threshold = {
#     dev     = 50
#     staging = 25
#     prod    = 10
#   }
  
#   # SNS topic naming
#   security_topic_name = "${local.resource_prefix}-security-alerts"
  
#   # IAM policy naming
#   key_access_policy_name = "${local.resource_prefix}-webserver-key-access"
# }