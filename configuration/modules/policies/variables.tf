############################################################################################
# Copyright 2020 Palo Alto Networks.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
############################################################################################


variable "device_group" {
  description = "The name of the Panorama device group"
  type        = string
}

variable "zone_untrust" {
  description = "The untrust zone"
  type        = string
}

variable "zone_web" {
  description = "The web zone"
  type        = string
}

variable "zone_db" {
  description = "The database zone"
  type        = string
}

variable "interface_untrust" {
  description = "The untrust interface"
  type        = string
}

variable "interface_web" {
  description = "The web interface"
  type        = string
}

variable "interface_db" {
  description = "The database interface"
  type        = string
}
