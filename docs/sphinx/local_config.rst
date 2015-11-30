Configuration
*************

In order to use this API, users should have the following software:

 * `CAJAL Toolbox <http://github.com/openconnectome/cajal>`_
 * A recent version of MATLAB

 * To install CAJAL, please follow the installation instructions here:  https://github.com/openconnectome/cajal.  For user (client) installations, the user only needs to clone the repository and run the "cajal.m" script in the API root to set up the toolbox.

 * To add CAJAL to your startup path (highly recommended), run `<cajalroot>/tools/matlab_install/setupEnvironment.m`

 * Toolboxes may also be added, by typing `cajal.installToolbox(<setup script for toolbox>)`.  A very simple setup example follows:

.. code-block:: bash

  % assume macho has been cloned to /share0/macho
  % setup.m is in macho root, and contains two lines:
  % addpath(genpath(pwd));
  % display('adding macho toolbox');

  cajal.installToolbox('/share0/macho/setup.m')

This toolbox will be loaded each time cajal is run, including on startup, if configured.
