variable "device_group" {
  description = "The name of the Panorama device group"
  type        = string
  default     = "StudentXX-DG"
}

variable "template" {
  description = "The name of the Panorama template"
  type        = string
  default     = "StudentXX-Template"
}

variable "stack" {
  description = "The name of the Panorama template stack"
  type        = string
  default     = "StudentXX-Stack"
}
