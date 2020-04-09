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


output "zone_untrust" {
  value = panos_panorama_zone.untrust.name
}

output "zone_web" {
  value = panos_panorama_zone.web.name
}

output "zone_db" {
  value = panos_panorama_zone.db.name
}

output "interface_untrust" {
  value = panos_panorama_ethernet_interface.untrust.name
}

output "interface_web" {
  value = panos_panorama_ethernet_interface.web.name
}

output "interface_db" {
  value = panos_panorama_ethernet_interface.db.name
}
