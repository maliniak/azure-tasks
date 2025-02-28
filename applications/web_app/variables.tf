variable "environment" {
  description = "The environment to deploy (dev, staging, prod)"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "vnet_address_space" {
  description = "Address space for the VNet"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_address_endpoint_prefix" {
  description = "Address prefix for the subnet"
  type        = string
}

variable "subnet_address_app_prefix" {
  description = "Address prefix for the subnet"
  type        = string
}

variable "db_admin_username" {
  description = "Admin username for MySQL"
  type        = string
  default     = "adminuser"
}

variable "db_name" {
  description = "Name of the database"
  type        = string
  default     = "mydb"
}

variable "mysql_sku_name" {
  description = "SKU name for MySQL server"
  type        = string
}

variable "mysql_storage_size" {
  description = "Storage size for MySQL in GB"
  type        = number
}

variable "backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
}

variable "app_service_sku" {
  description = "SKU for the App Service Plan"
  type        = string
}

variable "docker_image" {
  description = "Docker image name for the App Service"
  type        = string
}

variable "docker_registry_url" {
  description = "URL of the Docker registry"
  type        = string
}