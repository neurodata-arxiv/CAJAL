Scalable Processing
*******************

CAJAL facilitates both local exploration and scalable processing.  This section focuses on scalable processing, and is especially valuable for new CAJAL users.  By following these steps and the linked example files, you will learn about basic toolbox functionality and each of the major capabilities of CAJAL.

The major functions involved in scalable processing are: reading data, creating annotations, and uploading said annotations. We will go through several demonstration scripts which will guide you through accomplishing each of these tasks independently, or sequentially.


Read Data
---------
When reading data, you leverage the querying interface of OCP, which is explained in the Queries section. However, some basic queries exist which are most commonly used in the scalable setting.


Create Annotation
-----------------
Creating annotations is where the processing algorithms being used make their mark. When doing voxel classification, block merging, or spatial clustering, you plug the algorithms in here. Say a classification task is being performed, then the result of your algorithm should be a paint volume which identifies the class or cluster of each region by assigning them a unique and consistent intensity (i.e. id). These ids are how OCP distinguishes between different annotations, and metadata associated with each.


Upload Annotation
-----------------
There are several key ways to upload data. One can upload paint (i.e annotations) without associated metadata, metadata by itself, or both of these together. It is worth noting that though often times one wishes to upload both paint and metadata, it is more computationally efficient to upload them sequentially rather than at once for larger volumes.


Example
-------

.. code-block:: matlab

	%define your server, project, and channel
	server = 'openconnecto.me';
	channel = 'testanno';
	token = 'gk1';
	
	%define some region you wish to annotate
	d = zeros(200,200,5);
	d(30:170,30:170,:) = 1;
	
	xstart = 3000;
	ystart = 5000;
	zstart = 400;

	... to be completed
