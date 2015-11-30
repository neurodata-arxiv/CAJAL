Querying Data
*************

CAJAL uses queries to aid users in retrieving data of interest from the database.  Examples of commonly used queries are shown on this page.
For more detailed examples, please see the examples folder.  One good starting point is the `Getting Started Script <_static/demoscript/demoScript.html>`_.

Queries are discussed in more data `here <http://docs.neurodata.io/nddocs/ramonnd.html>`_.

Users should first setup a database endpoint, following the setup instructions in `Access <tutorials/access>`_.
For testing, the following may be used:

.. code-block:: bash

   oo = OCP();
   oo.setServerLocation('openconnecto.me');
   oo.setDefaultResolution(1);
   oo.setImageToken('kasthuri11cc');
   oo.setImageChannel('image');
   oo.setAnnoToken('test_ramonify_public');
   oo.setAnnoChannel('synapse');

Query Setup
-----------

To define a query, first initialize a query object, using the following command:

.. code-block:: bash

   q = OCPQuery;

Each query type requires setting various properties to specify the desired data to request from the server.
To check to see if your query is complete, run the following command:

.. code-block:: bash

   [valid, error] = q.validate;

To run a valid query against a specific server/token/channel, use the following command:

.. code-block:: bash

   data = oo.query(q);

The following are the six most frequently used queries:

RAMONIdList
-----------
This returns a list of ids that meet some list of predicates (e.g. type equal to synapse and status equal to unprocessed)

.. code-block:: bash

   q = OCPQuery;
   q.setType(eOCPQueryType.RAMONIdList);
   q.setResolution(1);
   ids = oo.query(q);

imageDense
----------
This returns a RAMONVolume containing a image voxel data in cutout format
To get slice z only, zStart = z, zStop = z+1;
.. code-block:: bash

   q = OCPQuery;
   q.setType(eOCPQueryType.imageDense);
   % set xStart,xStop,yStart,yStop,zStart,zStop, resolution
   q.setCutoutArgs([4400,5424],[5440,6464],[1100,1120],1);
   im = oo.query(q);

annoDense
---------
This returns a RAMONVolume containing a annotation voxel data in cutout format

.. code-block:: bash

   q = OCPQuery;
   q.setType(eOCPQueryType.annoDense);
   % set xStart,xStop,yStart,yStop,zStart,zStop, resolution
   q.setCutoutArgs([4400,5424],[5440,6464],[1100,1120],1);
   anno = oo.query(q);

To visualize progress thus far, CAJAL has a viewer built in:

.. code-block:: bash

   h = image(im); h.associate(anno);
   %type the 'a' key to turn on annotations, and scroll with the arrow keys


RAMONDense
----------
This returns a RAMON data type associated with a provided id with the voxel data in cutout form.  If no voxel data a warning is given.

.. code-block:: bash

   q = OCPQuery;
   q.setType(eOCPQueryType.RAMONDense);
   q.setId(42);
   q.setResolution(1);
   ramon1 = oo.query(q);

RAMONVoxelList
--------------
This returns a RAMON data type associated with a provided id with the voxel data in voxel list form.  If no voxel data a warning is given.

.. code-block:: bash

   q = OCPQuery;
   q.setType(eOCPQueryType.RAMONVoxelList);
   q.setId(42);
   q.setResolution(1);
   ramon2 = oo.query(q);

RAMONMetaOnly
-------------
This returns a RAMON data type associated with a provided id with only the metadata fields populated

.. code-block:: bash

   q = OCPQuery;
   q.setType(eOCPQueryType.RAMONMetaOnly);
   q.setId(42);
   q.setResolution(1);
   ramon3 = oo.query(q);

Multiple RAMON Volumes can be retrieved at a time for any of the RAMON queries by passing in an array of IDs, instead of just one.

.. code-block:: bash

   q = OCPQuery;
   q.setType(eOCPQueryType.RAMONMetaOnly);
   q.setId([42,45,1]);
   q.setResolution([1]);
   ramonMulti = oo.query(q);


Example Retrieving Centroids
----------------------------

To retrieve centroids that have been previously uploaded, users can combine ID queries with RAMONMetaOnly queries.
There is an advanced mode to retrieve this information using OCPFields, which is not documented here.  This example is in git as `exampleCentroidRetrieval.m`
This example retrieves centroids for AC4 RAMONSynapses.

The data upload process is documented in the RAMONify page.

.. code-block:: bash

  fileout = 'test.csv';
  annoToken = 'test_ramonify_public';
  annoChannel = 'synapse'
  step = 100; %number of annotations to process at a time
  oo = OCP;
  oo.setAnnoToken(annoToken);
  oo.setAnnoChannel(annoChannel);

  q = OCPQuery;
  q.setType(eOCPQueryType.RAMONIdList);
  q.validate
  id = oo.query(q);
  q.setType(eOCPQueryType.RAMONMetaOnly);

  cen = [];
  for i = 1:step:length(id)
      i
      endId = min(i + step-1, length(id));
      q.setId(id(i:1:endId));
      c = oo.query(q);
      for j = 1:length(c)
          cen(end+1,:) = [c{j}.id,str2num(c{j}.dynamicMetadata('centroid'))];
      end
  end

  % IDs are returned in non-sorted order from OCP
  [~,idx] = sort(cen(:,1),'ascend');
  cen = cen(idx,:);

  csvwrite(fileout,cen)

Example Counting Mitochondria
-----------------------------

The data upload process is documented in the RAMONify page.

To count objects, users can proceed the classical way and download large data volumes, followed by a connected components process.  However this may require extensive memory and a long period of time to compute!  Instead, using the NeuroData infrastructure and RAMON, we can retrieve this information quickly via a simple ID query.  Here we find 1053 mitochondria in about 0.1 of a second.

The mitochondria data we count here is part of the Kasthuri2015 Cell paper.

.. code-block:: bash

   oo = OCP;
   oo.setAnnoToken('kasthuri2015_ramon_v1');
   oo.setAnnoChannel('mitochondria');
   q = OCPQuery;
   q.setType(eOCPQueryType.RAMONIdList);
   q.setResolution(3);
   tic
   ids = oo.query(q);
   sprintf('The total number of mitochondria are: %d!\n', length(ids))
   toc
