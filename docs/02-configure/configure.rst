=======================
Panorama Configuration
=======================

In this activity you will:

- Initialize the Terraform provider
- Create the terraform.tfvars file
- Learn about the provided modules
- Assemble configuration/main.tf


For this portion of the lab, you will be using the Palo Alto Networks
`PAN-OS Terraform provider <https://www.terraform.io/docs/providers/panos/index.html>`_.

First, change to the Terraform configuration directory.

.. code-block:: bash

    $ cd ~/terraform-iac-lab/configuration


Why Panorama?
-------------
In this lab we will be leveraging a Panorama instance to configure the VM-Series firewall we'll be deploying.
There are other options for configuring the VM-Series firewall such as using Terraform to configure the firewall 
directly or, even simpler, bootstrapping the firewall with a full `bootstrap.xml` file.  However, we can make our 
boostrap package simpler and reusable across multiple VM-Series instances by leveraging Panorama.  

In this scenario we can provide VM-Series instance with the address of its Panorama console, the Device Group and 
Template Stack it will be a member of, and an authorization key to register the instance securely with Panorama.  
Once it registers with Panorama, the VM-Series instance will be mapped into the appropriate Device Group and Template 
Stack and the configurations contained therein will be pushed to the firewall.

The following is an example of an ``init-cfg.txt`` file used in the bootstrap process.

.. code-block:: none

    type=dhcp-client
    ip-address=
    default-gateway=
    netmask=
    ipv6-address=
    ipv6-default-gateway=
    hostname=Ca-FW-DC1
    vm-auth-key=755036225328715
    panorama-server=10.5.107.20
    panorama-server-2=10.5.107.21
    tplname=FINANCE_TG4
    dgname=finance_dg
    dns-primary=10.5.6.6
    dns-secondary=10.5.6.7
    op-command-modes=jumbo-frame, mgmt-interface-swap**
    op-cmd-dpdk-pkt-io=***
    dhcp-send-hostname=yes
    dhcp-send-client-id=yes
    dhcp-accept-server-hostname=yes
    dhcp-accept-server-domain=yes

Provider Initialization
-----------------------
Your first task is to set up the communications between the provider and the provided Panorama instance.  There's
several ways this can be done.  The IP address, username, and password (or API key) can be set as variables in
Terraform, and can be typed in manually each time the Terraform plan is run, or specified on the command line using
the ``-var`` command line option to ``terraform plan`` and ``terraform apply``.  You can also reference a JSON file in
the provider configuration which can contain the configuration.

Another way you can accomplish this is by using environment variables.  Use the following commands to add the
appropriate environment variables, substituting in the values provided by the instructor:

.. code-block:: bash

    $ export PANOS_HOSTNAME="<YOUR PANORAMA MGMT IP GOES HERE>"
    $ export PANOS_USERNAME="<YOUR STUDENT NAME>"
    $ export PANOS_PASSWORD="Ignite2020!"

.. note:: Replace the text ``<YOUR PANORAMA MGMT IP GOES HERE>`` and ``<YOUR STUDENT NAME>`` with the values provided
          to you by the instructor.

Now, you should see the variables exported in your shell, which you can verify using the ``env | grep PANOS`` command:

.. code-block:: bash

   PANOS_HOSTNAME=panorama.panlabs.org
   PANOS_USERNAME=studentXX
   PANOS_PASSWORD=Ignite2020!

With these values defined, we can now initialize the Terraform panos provider with the following command.

.. code-block:: bash

   $ terraform init

The provider is now ready to communicate with our Panorama instance.


Create the terraform.tfvars file
--------------------------------

Our Terraform plan in this directory will create a device group, template, and template stack on our shared Panorama.
So we don't overwrite the configuration of other students in the class, create a file called ``terraform.tfvars`` and
define values for the device group, template name, and template stack name:

.. code-block:: terraform

   device_group    = "studentXX-dg"
   template        = "studentXX-template"
   stack           = "studentXX-stack"

Replace the strings ``studentXX-dg``, ``studentXX-template``, and ``studentXX-stack`` with the values provided by the
instructor.


Learn about the provided modules
--------------------------------

You have been provided with two Terraform modules in the ``configuration/modules`` directory that will build out our
Panorama configuration.  Here's a snippet of the contents of 
`main.tf <https://github.com/PaloAltoNetworks/terraform-iac-lab/blob/master/configuration/modules/networking/main.tf>`_
in the ``configuration/modules/network`` directory:

.. code-block:: terraform
   :force:

   resource "panos_panorama_template" "demo_template" {
       name = var.template
   }

   resource "panos_panorama_template_stack" "demo_stack" {
       name      = var.stack
       templates = [panos_panorama_template.demo_template.name]
   }

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

Terraform will use this configuration to build out the contents of the template and template stack specified by the
``template`` and ``stack`` variables.

The ``network`` module also specifies some 
`outputs <https://github.com/PaloAltoNetworks/terraform-iac-lab/blob/master/configuration/modules/networking/outputs.tf>`_
that can be fed to other modules in the configuration:

.. code-block:: terraform
   :force:

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

The module to populate the 
`device group <https://github.com/PaloAltoNetworks/terraform-iac-lab/blob/master/configuration/modules/policies/main.tf>`_
works in a similar fashion.

Assemble configuration/main.tf
------------------------------

Add the following to ``configuration/main.tf`` to build out the template and template stack on our Panorama instance:

.. code-block:: terraform
   :force:

    module "networking" {
        source = "./modules/networking"

        template = var.template
        stack    = var.stack
    }

Now run ``terraform init`` (you need to run ``init`` each time you add a new module) and ``terraform plan``.  You will
see the Terraform provider determine what changes need to be made, and output all the changes that will be made to the
configuration.  If you run ``terraform apply``, those changes will be added to the candidate configuration, but not
committed (:ref:`why? <terraform-commits>`).

Add the next section to ``configuration/main.tf`` to build out the device group:

.. code-block:: terraform
   :force:

    module "policies" {
        source = "./modules/policies"

        device_group = var.device_group

        zone_untrust = module.networking.zone_untrust
        zone_web     = module.networking.zone_web
        zone_db      = module.networking.zone_db

        interface_untrust = module.networking.interface_untrust
        interface_web     = module.networking.interface_web
        interface_db      = module.networking.interface_db
    }

This module has variables for the names of zones and interfaces to avoid hard coding values.  Our networking module
outputs those names from what it creates, so we can chain these two modules together.

You can run ``terraform init``, ``terraform plan``, and ``terraform apply`` to populate the device group on Panorama.

Since Terraform is unable to commit configuration to PAN-OS on it's own, we have provided a Golang helper program to
commit your user's changes to Panorama.  You use a null resource provisioner in your main.tf to have Terraform run the
program for you.

Add the following section to ``configuration/main.tf`` to issue the commit:

.. code-block:: terraform
   :force:

    resource "null_resource" "commit_panorama" {
        provisioner "local-exec" {
            command = "./commit"
        }
        depends_on = [
            module.policies.security_rule_group,
            module.policies.nat_rule_group
        ]
    }

Your completed ``configuration/main.tf`` should look like this:

.. code-block:: terraform
   :force:

    provider "panos" {}

    module "networking" {
        source = "./modules/networking"

        template = var.template
        stack    = var.stack
    }

    module "policies" {
        source = "./modules/policies"

        device_group = var.device_group

        zone_untrust = module.networking.zone_untrust
        zone_web     = module.networking.zone_web
        zone_db      = module.networking.zone_db

        interface_untrust = module.networking.interface_untrust
        interface_web     = module.networking.interface_web
        interface_db      = module.networking.interface_db
    }

    resource "null_resource" "commit_panorama" {
        provisioner "local-exec" {
            command = "./commit"
        }
        depends_on = [
            module.policies.security_rule_group,
            module.policies.nat_rule_group
        ]
    }


Now, run ``terraform init`` and ``terraform apply`` to finalize the changes.  Log in to the Panorama web UI and verify
that your changes have been committed.  You're now ready to deploy the environment and have your firewall bootstrap
from this configuration.