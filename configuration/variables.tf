variable "device_group" {
  description = "The name of the Panorama device group"
  type        = string
  default     = "Terraform-IAC"
}

variable "template" {
  description = "The name of the Panorama template"
  type        = string
  default     = "Terraform-IAC-Template"
}

variable "stack" {
  description = "The name of the Panorama template stack"
  type        = string
  default     = "Terraform-IAC-Stack"
}
