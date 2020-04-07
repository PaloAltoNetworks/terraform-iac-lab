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

//  Panorama template and template stack
resource "panos_panorama_template" "demo_template" {
  name = var.template
}

resource "panos_panorama_template_stack" "demo_stack" {
  name      = var.stack
  templates = [panos_panorama_template.demo_template.name]
}

// Ethernet interfaces
resource "panos_panorama_ethernet_interface" "untrust" {
  name                      = "ethernet1/1"
  comment                   = "untrust interface"
  vsys                      = "vsys1"
  mode                      = "layer3"
  enable_dhcp               = true
  create_dhcp_default_route = true
  template                  = panos_panorama_template.demo_template.name
}

resource "panos_panorama_ethernet_interface" "web" {
  name        = "ethernet1/2"
  comment     = "web interface"
  vsys        = "vsys1"
  mode        = "layer3"
  enable_dhcp = true
  template    = panos_panorama_template.demo_template.name
}

resource "panos_panorama_ethernet_interface" "db" {
  name        = "ethernet1/3"
  comment     = "database interface"
  vsys        = "vsys1"
  mode        = "layer3"
  enable_dhcp = true
  template    = panos_panorama_template.demo_template.name
}

// Virtual router
resource "panos_panorama_virtual_router" "lab_vr" {
  name = "lab_vr"
  interfaces = [
    panos_panorama_ethernet_interface.untrust.name,
    panos_panorama_ethernet_interface.web.name,
    panos_panorama_ethernet_interface.db.name
  ]
  template = panos_panorama_template.demo_template.name
}

// Static routes for GCP
resource "panos_panorama_static_route_ipv4" "outbound" {
  name           = "outbound"
  virtual_router = panos_panorama_virtual_router.lab_vr.name
  destination    = "0.0.0.0/0"
  interface      = panos_panorama_ethernet_interface.untrust.name
  next_hop       = "10.5.1.1"
  template       = panos_panorama_template.demo_template.name
}

resource "panos_panorama_static_route_ipv4" "to-web" {
  name           = "to-web"
  virtual_router = panos_panorama_virtual_router.lab_vr.name
  destination    = "10.5.2.0/24"
  interface      = panos_panorama_ethernet_interface.web.name
  next_hop       = "10.5.2.1"
  template       = panos_panorama_template.demo_template.name
}

resource "panos_panorama_static_route_ipv4" "to-db" {
  name           = "to-db"
  virtual_router = panos_panorama_virtual_router.lab_vr.name
  destination    = "10.5.3.0/24"
  interface      = panos_panorama_ethernet_interface.db.name
  next_hop       = "10.5.3.1"
  template       = panos_panorama_template.demo_template.name
}

// Security zones
resource "panos_panorama_zone" "untrust" {
  name       = "untrust-zone"
  mode       = "layer3"
  interfaces = [panos_panorama_ethernet_interface.untrust.name]
  template   = panos_panorama_template.demo_template.name
}

resource "panos_panorama_zone" "web" {
  name       = "web-zone"
  mode       = "layer3"
  interfaces = [panos_panorama_ethernet_interface.web.name]
  template   = panos_panorama_template.demo_template.name
}

resource "panos_panorama_zone" "db" {
  name       = "db-zone"
  mode       = "layer3"
  interfaces = [panos_panorama_ethernet_interface.db.name]
  template   = panos_panorama_template.demo_template.name
}
