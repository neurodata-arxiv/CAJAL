Introduction
************

CAJAL is a toolbox to interface with the NeuroData image and annotation spatial databases.  This provides an easy method for users to create and interact with data across a variety of use cases.  For client applications, users will generally follow these steps:

- Server setup
- Upload Image Data (if not using an existing data set)
- Create and Upload Annotation Data
- Update Annotations (if needed)
- Delete Annotations (if needed)
- Query (Read) Annotations

For most of these usecases, we have created examples, functions, and loni modules to get you started.

Although documentation exists for the API at a method and object level,
we have provided functions and wrappers to allow most of the database interface
to happen via simple code reuse and drag-and-drop modules.

CAJAL Leverages RAMON, our flexible data standard to facilitate data exchange and processing.  More details are available
here:  http://docs.neurodata.io/nddocs/ramon.html

This website documents the major functionality of CAJAL; for more information, please read through the example scripts and unit tests.
CAJAL was written to be very verbose; in MATLAB, tab completing is very helpful for enumerations, setting fields, and exploring available options.
Reading classes (e.g. `edit RAMONSynapse`) may also be of use.
