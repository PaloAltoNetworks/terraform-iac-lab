==============
Lab Deployment
==============

In this activity you will:

- Create a service account credential file
- Create an SSH key-pair
- Create the terraform.tfvars file
- Add the bootstrap module
- Add the firewall module
- Deploy the infrastructure


Introduction
------------

The lab infrastructure will also be deployed in GCP using Terraform.  A Terraform plan has been provided that will
initialize the GCP provider, and call most of the modules responsible for creating the network, compute, and storage
resources needed.  You will add the modules for creating the bootstrap configuration as well as the VM-Series firewall.

First, change to the Terraform deployment directory:

.. code-block:: bash

    $ cd ~/terraform-iac-lab/deployment


Create a service account credential file
----------------------------------------

Terraform will need to authenticate to GCP to perform the deployment.  We *could* authenticate to GCP using the
username presented in the Qwiklabs panel when the lab was started.  However, the Compute Engine default service
account is typically used because it is certain to have all the neccesary permissions.

List the email address of the Compute Engine default service account.

.. code-block:: bash

    $ gcloud iam service-accounts list

Use the following ``gcloud`` command to download the credentials for the **Compute Engine default service account**
using its associated email address (displayed in the output of the previous command).

.. code-block:: bash

    $ gcloud iam service-accounts keys create ~/gcp_compute_key.json --iam-account <EMAIL_ADDRESS>

Verify the JSON credentials file was successfully created.

.. code-block:: bash

    $ cat ~/gcp_compute_key.json


Create an SSH key-pair
----------------------
All Compute Engine instances are required to have an SSH key-pair defined when the instance is created.  This is done
to ensure secure access to the instance will be available once it is created.

Create an SSH key-pair with an empty passphrase and save them in the ``~/.ssh`` directory.

.. code-block:: bash

    $ ssh-keygen -t rsa -b 1024 -N '' -f ~/.ssh/lab_ssh_key

.. note:: GCP has the ability to manage all of its own SSH keys and propagate
          them automatically to projects and instances. However, the VM-Series
          is only able to make use of a single SSH key. Rather than leverage
          GCP's SSH key management process, we've created our own SSH key and
          configured Compute Engine to use our key exclusively.


Create deployment/terraform.tfvars
----------------------------------

In this directory you will find the three main files associated with a Terraform plan: ``main.tf``, ``variables.tf``,
and ``outputs.tf``.  View the contents of these files to see what they contain and how they're structured.

.. code-block:: bash

    $ more main.tf
    $ more variables.tf
    $ more outputs.tf

The file ``main.tf`` defines the providers that will be used and the resources that will be created (more on that
shortly).  Since it is poor practice to hard code values into the plan, the file ``variables.tf`` will be used to
declare the variables that will be used in the plan (but not necessarily their values).  The ``outputs.tf`` file
will define the values to display that result from applying the plan.

Create a file called ``terraform.tfvars`` in the current directory that contains the following variables and their
values.  You will need to add a number of things:

- GCP configuration: The GCP project ID, region, and zone.
    - **project**: The GCP project ID that Qwiklabs created for you.
    - **region**: The GCP region we are using (supplied by instructor).
    - **zone**: The GCP zone we are using (supplied by instructor).
- Authentication information:
    - **credentials_file**: The path to our JSON credentials file.
    - **public_key_file**: The path to our SSH public key file.
- Firewall information:
    - **fw_name**: The name for the firewall.
- Panorama bootstrap information:
    - **panorama**: The hostname/IP address of Panorama (supplied by instructor).
    - **tplname**: The template stack you created in the previous section (replace XX with your student number).
    - **dgname**: The device group you created in the previous section (replace XX with your student number).
    - **vm_auth_key**: The VM auth key for Panorama (supplied by instructor).

Your file should look similar to the following, with the appropriate values replaced:

.. code-block:: terraform
   :force:

    project             = "<YOUR_GCP_PROJECT_ID>"
    region              = "<SEE_INSTRUCTOR_PRESENTATION>"
    zone                = "<SEE_INSTRUCTOR_PRESENTATION>"
    credentials_file    = "~/gcp_compute_key.json"
    public_key_file     = "~/.ssh/lab_ssh_key.pub"

    fw_name     = "studentXX-fw"
    panorama    = "<SEE_INSTRUCTOR_PRESENTATION>"
    tplname     = "studentXX-stack"
    dgname      = "studentXX-dg"
    vm_auth_key = "<SEE_INSTRUCTOR_PRESENTATION>"


Add the bootstrap module
------------------------

Add the following module definition to ``deployment/main.tf``:

.. code-block:: terraform
   :force:

    module "bootstrap" {
        source  = "PaloAltoNetworks/panos-bootstrap/google"
        version = "1.0.0"

        bootstrap_project = var.project
        bootstrap_region  = var.region

        hostname        = var.fw_name
        panorama-server = var.panorama
        tplname         = var.tplname
        dgname          = var.dgname
        vm-auth-key     = var.vm_auth_key
    }

This uses a module that has been published to the Terraform module registry for public use.  (If you'd like to review
the code, it's on the
`PaloAltoNetworks GitHub page <https://github.com/PaloAltoNetworks/terraform-google-panos-bootstrap>`_.) This will
create the Google Storage bucket for holding a PAN-OS bootstrap configuration, as well as 
`the required files <https://docs.paloaltonetworks.com/vm-series/10-0/vm-series-deployment/bootstrap-the-vm-series-firewall.html>`_.


Add the firewall module
-----------------------

Now we need to add another module definition to ``deployment/main.tf`` to specify the firewall configuration:

.. code-block:: terraform
   :force:

    module "firewall" {
        source = "./modules/firewall"

        fw_name             = var.fw_name
        fw_zone             = var.zone
        fw_image            = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-flex-bundle2-1000"
        fw_machine_type     = "n1-standard-4"
        fw_machine_cpu      = "Intel Skylake"
        fw_bootstrap_bucket = module.bootstrap.bootstrap_name

        fw_ssh_key = "admin:${file(var.public_key_file)}"

        fw_mgmt_subnet = module.vpc.mgmt_subnet
        fw_mgmt_ip     = "10.5.0.4"
        fw_mgmt_rule   = module.vpc.mgmt-allow-inbound-rule

        fw_untrust_subnet = module.vpc.untrust_subnet
        fw_untrust_ip     = "10.5.1.4"
        fw_untrust_rule   = module.vpc.untrust-allow-inbound-rule

        fw_web_subnet = module.vpc.web_subnet
        fw_web_ip     = "10.5.2.4"
        fw_web_rule   = module.vpc.web-allow-outbound-rule

        fw_db_subnet = module.vpc.db_subnet
        fw_db_ip     = "10.5.3.4"
        fw_db_rule   = module.vpc.db-allow-outbound-rule
    }

`This module <https://github.com/PaloAltoNetworks/terraform-iac-lab/blob/master/deployment/modules/firewall/main.tf>`_
creates the VM-Series instance.  Notice how the outputs from the *bootstrap* and *vpc* modules are used as inputs to
this one.


Deploy the infrastructure
-------------------------

Your completed ``deployment/main.tf`` file should look like this:

.. code-block:: terraform
   :force:

    provider "google" {
        credentials = file(var.credentials_file)
        project     = var.project
        region      = var.region
    }

    module "bootstrap" {
        source  = "PaloAltoNetworks/panos-bootstrap/google"
        version = "1.0.0"

        bootstrap_project = var.project
        bootstrap_region  = var.region

        hostname        = "terraform-iac-fw"
        panorama-server = var.panorama
        tplname         = var.tplname
        dgname          = var.dgname
        vm-auth-key     = var.vm_auth_key
    }

    module "vpc" {
        source = "./modules/vpc"

        vpc_region = var.region

        vpc_mgmt_network_name = "management-network"
        vpc_mgmt_subnet_cidr  = "10.5.0.0/24"
        vpc_mgmt_subnet_name  = "management-subnet"

        vpc_untrust_network_name = "untrust-network"
        vpc_untrust_subnet_cidr  = "10.5.1.0/24"
        vpc_untrust_subnet_name  = "untrust-subnet"

        vpc_web_network_name = "web-network"
        vpc_web_subnet_cidr  = "10.5.2.0/24"
        vpc_web_subnet_name  = "web-subnet"

        vpc_db_network_name = "database-network"
        vpc_db_subnet_cidr  = "10.5.3.0/24"
        vpc_db_subnet_name  = "database-subnet"

        allowed_mgmt_cidr = var.allowed_mgmt_cidr
    }

    module "web" {
        source = "./modules/web"

        web_name         = "web-vm"
        web_zone         = var.zone
        web_machine_type = "n1-standard-1"
        web_ssh_key      = "admin:${file(var.public_key_file)}"
        web_subnet_id    = module.vpc.web_subnet
        web_ip           = "10.5.2.5"
        web_image        = "debian-9"
    }

    module "db" {
        source = "./modules/db"

        db_name         = "db-vm"
        db_zone         = var.zone
        db_machine_type = "n1-standard-1"
        db_ssh_key      = "admin:${file(var.public_key_file)}"
        db_subnet_id    = module.vpc.db_subnet
        db_ip           = "10.5.3.5"
        db_image        = "debian-9"
    }

    module "firewall" {
        source = "./modules/firewall"

        fw_name             = var.fw_name
        fw_zone             = var.zone
        fw_image            = "https://www.googleapis.com/compute/v1/projects/paloaltonetworksgcp-public/global/images/vmseries-flex-bundle2-1000"
        fw_machine_type     = "n1-standard-4"
        fw_machine_cpu      = "Intel Skylake"
        fw_bootstrap_bucket = module.bootstrap.bootstrap_name

        fw_ssh_key = "admin:${file(var.public_key_file)}"

        fw_mgmt_subnet = module.vpc.mgmt_subnet
        fw_mgmt_ip     = "10.5.0.4"
        fw_mgmt_rule   = module.vpc.mgmt-allow-inbound-rule

        fw_untrust_subnet = module.vpc.untrust_subnet
        fw_untrust_ip     = "10.5.1.4"
        fw_untrust_rule   = module.vpc.untrust-allow-inbound-rule

        fw_web_subnet = module.vpc.web_subnet
        fw_web_ip     = "10.5.2.4"
        fw_web_rule   = module.vpc.web-allow-outbound-rule

        fw_db_subnet = module.vpc.db_subnet
        fw_db_ip     = "10.5.3.4"
        fw_db_rule   = module.vpc.db-allow-outbound-rule
    }

    resource "google_compute_route" "web-route" {
        name                   = "web-route"
        dest_range             = "0.0.0.0/0"
        network                = module.vpc.web_network
        next_hop_instance      = module.firewall.firewall-instance
        next_hop_instance_zone = var.zone
        priority               = 100
    }

    resource "google_compute_route" "db-route" {
        name                   = "db-route"
        dest_range             = "0.0.0.0/0"
        network                = module.vpc.db_network
        next_hop_instance      = module.firewall.firewall-instance
        next_hop_instance_zone = var.zone
        priority               = 100
    }


Now, you're ready to deploy the infrastructure.  Run the following commands:

.. code-block:: bash

    $ terraform init
    $ terraform plan
    $ terraform apply

As we saw before, ``terraform init`` will install all required providers and modules, ``terraform plan`` will show all
the infrastructure that will be created, and ``terraform apply`` will create the infrastructure.

At a high level, the completed Terraform configuration will:

#. Run the ``bootstrap`` module
    #. Create a GCP storage bucket for the firewall bootstrap package
    #. Apply a policy to the bucket allowing read access to ``allUsers``
    #. Create the ``/config/init-cfg.txt``, ``/config/bootstrap.xml``,
       ``/software``, ``/content``, and ``/license`` objects in the bootstrap
       bucket
#. Run the ``vpc`` module
    #. Create the VPC
    #. Create the Internet gateway
    #. Create the ``management``, ``untrust``, ``web``, and ``database``
       subnets
    #. Create the security groups for each subnet
    #. Create the default route for the ``web`` and ``database`` subnets
#. Run the ``firewall`` module
    #. Create the VM-Series firewall instance
    #. Create the VM-Series firewall interfaces
    #. Create the public IPs for the ``management`` and ``untrust`` interfaces
#. Run the ``web`` module
    #. Create the web server instance
    #. Create the web server interface
#. Run the ``database`` module
    #. Create the database server instance
    #. Create the database server interface

The deployment process should finish in a few minutes and you will be presented with the public IP addresses of the
VM-Series firewall management and untrust interfaces.  However, the VM-Series firewall can take up to *ten minutes* to
complete the initial bootstrap process.

Once the firewall has completed the bootstrap process, it should be listed in Panorama as a managed device in your
device group under Panorama > Managed Devices > Summary.
