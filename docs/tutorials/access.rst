Accessing Data
**************

This page briefly explains how to access data from CAJAL, and provides brief code snippets illustrating usage.  For more detailed examples, please see the examples folder.
One good starting point is the `Getting Started Script <_static/demoscript/demoScript.html>`_.

CAJAL is intentionally verbose and is designed by be used via 'tab-completion'.

Database Configuration
----------------------

Setup
~~~~~

To begin accessing data, users should first specify the server, token, and channel of their data.
To get a token and channel pair, users should first follow the instructions `here <http://docs.neurodata.io/open-connectome/sphinx/console>`_
.. code-block::

  % Create an OCP Object.  This is the main class used for talking with OCP
  % services. If you want to create an OCP object that will use the
  % distributed semaphore (assuming you've set it up) use OCP('semaphore')
  % instead.
  oo = OCP();

  % Set the server location.  This is the default server and most likely the
  % one you should be using.
  oo.setServerLocation('http://openconnecto.me/');

  % Set the image token.  This is the database for image data reading.
  oo.setImageToken('kasthuri11cc');

  % Set the image token.  This is the database for image data reading. You
  % can also read this from a file using setAnnoTokenFile. Also update
  % propagate status to make the annotation project writeable.
  % Note: We do not propagate in the demo script.
  oo.setAnnoToken('cajal_demo');
  oo.setAnnoChannel('anno');

  % Information about the databases are accessible
  oo.annoInfo.DATASET
  oo.annoInfo.DATASET.IMAGE_SIZE(1)

  % Set the default resolution.  This is the resolution at which operations
  % should occur unless otherwise specified.
  oo.setDefaultResolution(1);

Get information about datasets
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

There are many types of information one can request about available data sets, such as the following examples.

.. code-block:: bash

  % Information about the specified annotation dataset
  oo.annoInfo.DATASET
  oo.annoInfo.DATASET.IMAGE_SIZE(1)

  % Information about available public tokens
  oo.getPublicTokens

Image Data
-----------

CAJAL allows users to access image data and corresponding annotation data.

Upload Data
~~~~~~~~~~~

To upload image data, use the following method:

.. code-block:: bash

  oo.uploadImageData(RAMONVolume)

A detailed example can be found in the examples folder `exampleImageUpload.m`

Download Data
~~~~~~~~~~~~~

To download image data, please see the query page.

Annotation Data
---------------

CAJAL allows users to access image data and corresponding annotation data.

Upload Data
~~~~~~~~~~~

To upload annotation data, users should format their data into the appropriate RAMON datatype and upload using the following command.
Labels (without a RAMONType) can be uploaded as a RAMON volume.

.. code-block:: bash

   oo.createAnnotation(RAMONVolume)

Many examples for this exist throughout the examples directory.  A helper function called 'packages/cubeUpload/cubeUploadDense.m' is available to make this process straightforward.

Download Data
~~~~~~~~~~~~~

To download annotation data, please see the query page.

Update Annotation
-----------------

To update existing annotations, users should download the annotation of interest, adjust its properties, and then update with the following command.

.. code-block:: bash

   oo.updateAnnotation(RAMONVolume)


Delete Annotation
-----------------

To delete existing annotations, users should determine the database id(s) of the objects to delete, and use the following command.

.. code-block:: bash

   oo.deleteAnnotation(ids)
