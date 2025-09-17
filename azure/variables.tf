# variables.tf

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  default     = "Uk South"
  description = "Azure region"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
}

variable "public_key_path" {
  type        = string
  description = "Path to your SSH public key"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "allowed_ip_address" {
  type        = string
  description = "Your public IP address to allow SSH connections"
}  

variable "vm_dns_label" {
  type        = string
  description = "DNS name label for the VM's public IP"
}

variable "storage_account_name" {
  type        = string
  description = "A globally unique name for the storage account"
}

variable "storage_container_name" {
  type        = string
  description = "A name for the storage container"
}

variable "alert_email_address" {
  type        = string
  description = "Email address for alert notifications"
}

variable "key_vault_name" {
  type        = string
  description = "A globally unique name for the Azure Key Vault"
}

variable "secret_name" {
  type        = string
  description = "The name of the secret in the Key Vault"
}