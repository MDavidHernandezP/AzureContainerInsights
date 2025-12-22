variable "location" {
  default = "East US"
}

variable "resource_group_name" {
  default = "rg-aks-monitoring"
}

variable "trainer_object_id" {
  description = "Azure AD Object ID of the trainer"
}
