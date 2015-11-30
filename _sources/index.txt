.. meta::
   :description: Official documentation for CAJAL:  Collaborative Annotation for Joint Analysis of Large Data
   :keywords: annotation, tracing, neuroscience, object detection
.. title::
   manno

.. raw:: html

	<h1>CAJAL Matlab Toolbox:  Collaborative Annotation for Joint Analysis of Large Data </h1>
	<br>


The CAJAL toolbox (or API) provides functionality to interact with NeuroData image and annotation databases, including querying raw image data, annotation data, and RAMON objects. Complex HTTP queries are wrapped in easy to use Matlab code - helper functions and example files are provided.  New users may wish to begin with the `Getting Started Script <_static/demoscript/demoScript.html>`_.

.. figure:: images/cajal_pipeline.jpg
    :width: 800px
    :align: center


.. raw:: html

  <div>
    <img style="width:30px;height:30px;vertical-align:middle">
    <span style=""></span>
    <IMG SRC="_static/GitHub.png" height="50" width="50"> <a href="https://github.com/openconnectome/CAJAL/zipball/master"> [ZIP]   </a>
    <a image="_static/GitHub.png" href="https://github.com/openconnectome/CAJAL/tarball/master">[TAR.GZ] </a></p>
  </div>

Please see the tutorials section for information about getting and putting data, querying for data, RAMONifying your dataset, and generating graphs.
CAJAL implements the RAMON data standard explained `here <docs.neurodata.io/nddocs/ramon.html>`_ and `here <docs.neurodata.io/nddocs/ramonnd.html>`_.

.. sidebar:: CAJAL Contact Us

   If you have questions about CAJAL, or have data to analyze, let us know:  support@neurodata.io

.. toctree::
   :maxdepth: 1
   :caption: Overview

   sphinx/introduction
   sphinx/local_config
   sphinx/ocp
   sphinx/faq

.. toctree::
  :maxdepth: 2
  :caption: Tutorials

  tutorials/access
  tutorials/query
  tutorials/ramonify
  tutorials/graphs

.. toctree::
   :maxdepth: 1
   :caption: Further Reading

   api/functions
   Github repo <https://github.com/openconnectome/CAJAL>
   Release Notes <https://github.com/openconnectome/cajal/releases/>
