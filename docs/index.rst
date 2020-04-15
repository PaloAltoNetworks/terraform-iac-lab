.. terraform-iac-lab documentation master file, created by
   sphinx-quickstart on Wed Apr 9 17:08:44 2020.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Terraform Infrastructure as Code Lab Guide
=========================================

.. image:: panw-logo-bw.png
   :align: center

Welcome
-------

Welcome to the Terraform Infrastructure as Code Lab!

In this lab we will be deploying a multi-tiered web application to the cloud.  
To accomplish this we'll first need need to define the infrastructure supporting 
our application as well as how we're going to secure the application.  Rather than 
manually defining the infrastructure elements within the cloud provider portal, 
we're going to define our infrastructure in code using Terraform's declarative 
language and stateful build capabilities.

A key element of our infrastructure design will be the Palo Alto Networks VM-Series 
firewall.  Using the Terraform provider for PAN-OS, we will define the configuration
of the VM-Series firewall, but we'll be using Panorama to manage that configuration.  
The PAN-OS bootstrapping feature will be used to initialize the VM-Series firewall 
and point it to Panorama.  Once it registers with Panorama, it will receive its 
runtime configuration.
 
Lastly, we will ensure that the firewall is able to respond effectively to 
changes made to the application infrastructure.  


Objective
---------
The objective of this workshop is to deploy and secure a 
`WordPress <https://wordpress.org>`_ content management system in Google Cloud 
Platform.  This web application will be supported by an 
`Apache <https://httpd.apache.org>`_ web server and a 
`MariaDB <https://mariadb.org/>`_ database server residing in two separate 
subnets.  

As part of our infrastructure deployment, a VM-Series virtual firewall will be 
inserted between the untrusted public subnet, the web subnet, and the database 
subnet.  Our goal is to define, deploy, and configure all cloud infrastructure 
elements including the VM-series firewall using Terraform exclusively.


Learning Outcomes
----------
- Learn how to use Terraform to define and deploy cloud infrastructure and 
  implement changes to PAN-OS devices
- Learn best practices for managing infrastructure code environments
- Learn about bootstrapping best practices for VM-Series firewalls in the cloud

.. toctree::
   :maxdepth: 2
   :hidden:
   :caption: overview

   00-overview/introduction

.. toctree::
    :maxdepth: 2
    :hidden:
    :caption: getting started

    01-getting-started/requirements
    01-getting-started/setup

.. toctree::
    :maxdepth: 2
    :hidden:
    :caption: configure

    02-configure/terraform
    02-configure/configure

.. toctree::
    :maxdepth: 2
    :hidden:
    :caption: deploy

    03-deploy/deploy
    03-deploy/validation
    

.. toctree::
    :maxdepth: 2
    :hidden:
    :caption: summary

    05-summary/summary
    05-summary/cleanup
    05-summary/moreinfo

.. toctree::
    :maxdepth: 2
    :hidden:
    :caption: appendix

    06-appendix/terraform-commit
