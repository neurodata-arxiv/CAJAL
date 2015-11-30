RAMON and RAMONifying Data
--------------------------

An overview of the RAMON Data Standard can be found `here <docs.neurodata.io/nddocs/ramon.html>`_.
For more detailed examples, please see the examples folder.  One good starting point is the `Getting Started Script <_static/demoscript/demoScript.html>`_.
CAJAL implements the RAMON data standard.  These data types can be seamlessly used with NeuroData/OCP, or as standalone objects.

To interact with a RAMONObject, first initialize it:

.. code-block:: bash

  syn = RAMONSynapse;

Fields can be set using setters.  Fields can be retrieved directly (no getters).

.. code-block:: bash

  syn.setWeight(0.5);
  syn.weight

ID is usually set by the database as the primary key; do not set this field as a user unless you have a reason.

Some fields have enumerated types.  More on these types can be found on the RAMON overview page:

.. code-block:: bash

  syn.setType(eRAMONSynapseType.excitatory);

Examples of using RAMON exist throughout the documentation and examples.  One good references is code to RAMONify AC4 (a small EM volume); this procedure uses spatial overlap to infer connections and proceeds based only on raw labels. The code is reproduced here, and can be found in the examples folder (`ramonify_basic.m`)

.. code-block:: bash

  % RAMONify AC4 and generate a graph
  % Version 1:  Without the algorithms
  % This is essentially a step-by-step method demonstrating the utility of
  % CAJAL, RAMON, and NeuroData.

  % Depending on the case, bidirectional links are not required; in practice,
  % the neuron abstraction may be skipped for processing efficiency if all
  % segments are merged via another process.  Here we include both of these
  % steps to demonstrate functionality.

  % Prerequisite:  Project and tokens
  % Channels should be neuron, synapse

  % This is not cube aligned because AC4 maps to a manually annoted
  % dataset.  We block upload for efficiency.

  % Assume that server is openconnecto.me

  %
  token = 'test_ramonify_public';
  %% Setup server connection
  clear SYN SEG NEU

  odown = OCP();
  odown.setImageToken('kasthuri11cc');
  odown.setAnnoToken('ac4_raw');

  %% Find Synapses

  % Here we download from an existing database
  %http://openconnecto.me/ocp/overlay/0.7/openconnecto.me/kasthuri11cc/image/openconnecto.me/ac4_raw/neuron/xy/1/4400,5424/5440,6464/1105/
  odown.setAnnoChannel('synapse');

  q = OCPQuery;
  q.setType(eOCPQueryType.annoDense);
  q.setCutoutArgs([4400,5424],[5440,6464],[1100,1200],1);

  synPaint = odown.query(q);


  %% Find Neuron Segments

  % Here we download raw data from an existing database
  odown.setAnnoChannel('neuron');

  neuPaint = odown.query(q);

  %% Associate Segments and Synapses

  % Simple image processing function

  % [seg1, seg2, synapse, direction]
  eList = neusyn_associate_simple(neuPaint,synPaint);

     for ii = 1:size(eList,1)
              ee = eList(ii,1:2);
              eList(ii,1) = min(ee);
              eList(ii,2) = max(ee);
     end

  usyn = unique(synPaint.data); %unique values, disregard 0
  usyn(usyn == 0) = [];
  nsyn = length(usyn);

  uneu = unique(neuPaint.data);
  uneu(uneu == 0) = [];
  nneu = length(uneu);

  rps = regionprops(synPaint.data,'Centroid');
  rpn = regionprops(neuPaint.data,'Centroid');

  for i = 1:nsyn
      syn = RAMONSynapse();
      syn.setAuthor('test upload');
      syn.setId(usyn(i));

      cVal = round(rps(i).Centroid+synPaint.xyzOffset)-[1,1,1];

      syn.addDynamicMetadata('centroid',cVal);

      idx = find(eList(:,3) == usyn(i));

      for j = 1:length(idx)
          if eList(j,1) > 0
              syn.addSegment(eList(idx(j),1), eRAMONFlowDirection.unknown);
          end
          if eList(j,2) > 0
              syn.addSegment(eList(idx(j),2), eRAMONFlowDirection.unknown);
          end
      end
      SYN{i} = syn;
      clear syn
  end

  oup = OCP();
  oup.setImageToken('kasthuri11cc');
  oup.setAnnoToken(token);
  oup.setAnnoChannel('synapse');

  synPaint.setChannel('synapse');
  oup.createAnnotation(synPaint);

  oup.createAnnotation(SYN);

  %% Create segment metadata

  for i = 1:nneu
      seg = RAMONSegment();
      seg.setAuthor('test upload');
      seg.setId(uneu(i));

      idx = find(eList(:,1) == uneu(i));

      for j = 1:length(idx)
          seg.setSynapses([seg.synapses, eList(idx(j),3)]);
      end

      idx = find(eList(:,2) == uneu(i));
      for j = 1:length(idx)
          seg.setSynapses([seg.synapses, eList(idx(j),3)]);
      end

      SEG{i} = seg;
      clear seg
  end

  oup = OCP();
  oup.setImageToken('kasthuri11cc');
  oup.setAnnoToken(token);
  oup.setAnnoChannel('neuron');

  neuPaint.setChannel('neuron');
  oup.createAnnotation(neuPaint);

  oup.createAnnotation(SEG);


  %% Need to create neurons and assign segments to neurons

  % This step is artificial here; we assign neuron IDs = segID + 100000

  for i = 1:length(SEG)
      neu = RAMONNeuron;
      neu.setId(SEG{i}.id + 100000);

      NEU{i} = neu;
      clear neu
  end

  oup.createAnnotation(NEU);

  %% Need to add segments to neurons
  % Could have been done in previous step.  Demonstrating updateAnnotation

  q = OCPQuery;
  q.setType(eOCPQueryType.RAMONMetaOnly);

  for i = 1:length(NEU)

      q.setId(NEU{i}.id);
      neu = oup.query(q);

      neu.setSegments([neu.segments, SEG{i}.id]); %true by construction
      oup.updateAnnotation(neu);
  end

  %% Need to add neurons to segments
  % Demonstrating OCPFields

  f = OCPFields();

  for i = 1:length(NEU)
  % i
      segMap =  oup.getField(NEU{i}.id,f.neuron.segments);

      for j = 1:length(segMap)

          oup.setField(segMap(j),f.segment.neuron,NEU{i}.id);  %segments belong to only one neuron
      end
  end



A second example is the RAMONification of the Kasthuri2015 cell paper (found here `https://github.com/openconnectome/kasthuri2015/blob/master/ramonify/ramonify_kasthuri.m`).  This is similar in spirit, but leverages manually curated associations and metadata to parse the hierarchy and associate objects.
