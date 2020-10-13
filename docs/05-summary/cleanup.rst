===========
Cleaning Up
===========

In this activity you will:

- Destroy the lab deployment

Destroy the lab deployment
--------------------------
When deploying infrastructure in the public cloud it is important to tear it down when you are done, otherwise you will
end up paying for services that are no longer needed.  We'll need to go back to the deployment directory and use
Terraform to destroy the infrastructure we deployed at the start of the lab.

Change into the ``deployment`` directory, and tell Terraform to destroy all of the resources it has created by running
``terraform destroy``.

.. code-block:: bash

    $ cd ~/terraform-iac-lab/deployment
    $ terraform destroy

.. warning::

   If you are doing the lab on your own, this is a critical step to stop being
   charged by GCP.

   Qwiklabs will take care of destroying everything when the lab expires, but
   destroying cloud resources when they are no longer needed is a good habit to
   get in to.
