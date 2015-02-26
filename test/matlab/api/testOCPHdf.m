function test_suite= testOCPHdf%#ok<STOUT>
    %TESTSEED Unit test of the seed datatype
    
    %% Init the test suite
    initTestSuite;
    
end

%% Error checks
function testNotRAMONObj %#ok<*DEFNU>
    assertExceptionThrown(@() OCPHdf(34), 'OCPHdf:ArgError');
end
%% Seed
function testSeedFull
    % Create seed
    s1 = RAMONSeed();
    s1.setId(100);
    s1.setPosition([10 20 30]);
    s1.setCubeOrientation(eRAMONCubeOrientation.neg_y);
    s1.setParentSeed(43);
    s1.setSourceEntity(57);
    s1.setConfidence(.78);
    s1.setStatus(eRAMONAnnoStatus.processed);
    s1.addDynamicMetadata('key1','some words');
    s1.addDynamicMetadata('key2',35336);
    s1.setAuthor('test');
    
    hdfSeed = OCPHdf(s1);
    s2 = hdfSeed.toRAMONObject();
    
    assertEqual(s1.position, s2.position);
    assertEqual(s1.cubeOrientation, s2.cubeOrientation);
    assertEqual(s1.parentSeed, s2.parentSeed);
    assertEqual(s1.sourceEntity, s2.sourceEntity);
    assertEqual(s1.id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    assertEqual(s1.dynamicMetadata,s2.dynamicMetadata);
    assertEqual(s1.author,s2.author);
end

function testSeedRequiredOnly
    % Create seed
    s1 = RAMONSeed();
    s1.setId(100);
    s1.setPosition([10 20 30]);
    
    hdfSeed = OCPHdf(s1);
    s2 = hdfSeed.toRAMONObject();
    
    assertEqual(s2.position, s1.position);
    assertEqual(s2.cubeOrientation, eRAMONCubeOrientation.centered);
    assertEqual(s2.parentSeed, []);
    assertEqual(s2.sourceEntity, []);
    assertEqual(s2.id,s1.id);
    assertEqual(s2.confidence,1);
    assertEqual(s2.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(s2.dynamicMetadata,containers.Map());
end

%% Synapse
function testSynapseFull
    % Create seed
    s1 = RAMONSynapse();
    
    d = repmat(magic(100),[1 1 100]);
    d(:,:,70:100) = [];
    d(:,20:30,:) = [];
    s1.setCutout(d);
    s1.setResolution(3);
    s1.setXyzOffset([23 45 67]);
    s1.setId(102);
    s1.setSeeds([2 3 4]);
    s1.addSegment(23,eRAMONFlowDirection.postSynaptic);
    s1.setSynapseType(eRAMONSynapseType.inhibitory);
    s1.setWeight(.5);
    s1.setConfidence(.78);
    s1.setStatus(eRAMONAnnoStatus.processed);
    s1.addDynamicMetadata('key1','some words');
    s1.addDynamicMetadata('key2',35336);
    s1.setAuthor('tester');
    
    hdfSeed = OCPHdf(s1);
    s2 = hdfSeed.toRAMONObject(eOCPQueryType.RAMONDense);
    
    assertEqual(s1.synapseType, s2.synapseType);
    assertEqual(s1.weight, s2.weight);
    assertEqual(s1.segments, s2.segments);
    assertEqual(s1.seeds, s2.seeds);
    assertEqual(s1.id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    assertEqual(s1.dynamicMetadata,s2.dynamicMetadata);
    assertEqual(s1.author,s2.author);
    assertEqual(eRAMONDataFormat.dense,s2.dataFormat);
    
    assertEqual(s1.data,s2.data);
    assertEqual(s1.resolution,s2.resolution);
    assertEqual(s1.xyzOffset,s2.xyzOffset);
end

function testSyanpseRequiredOnly
    % Create seed
    s1 = RAMONSynapse();
    s1.setId(101);
    s1.setAuthor('tester');
    
    
    warning('off','OCPHdf:NoVoxelData');
    hdfSeed = OCPHdf(s1);
    s2 = hdfSeed.toRAMONObject(eOCPQueryType.RAMONDense);
    warning('on','OCPHdf:NoVoxelData');
    
    
    assertEqual(s1.synapseType, s2.synapseType);
    assertEqual(s1.weight, s2.weight);
    assertEqual(s1.segments, s2.segments);
    assertEqual(s1.seeds, s2.seeds);
    assertEqual(s1.id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    assertEqual(s1.dynamicMetadata,s2.dynamicMetadata);
    assertEqual(s1.author,s2.author);
    assertEqual(eRAMONDataFormat.dense,s2.dataFormat);
    assertEqual(s2.name, 'Volume1');
    assertEqual(s1.data,s2.data);
    assertEqual(s1.resolution,s2.resolution);
    assertEqual(s1.xyzOffset,s2.xyzOffset);
end

function testSynapseNoData
    
    % Create seed
    s1 = RAMONSynapse();
    s1.setId(101);
    s1.setAuthor('tester');
    
    hdfSeed = OCPHdf(s1);
    s2 = hdfSeed.toRAMONObject(eOCPQueryType.RAMONMetaOnly);
    
    assertEqual(s1.synapseType, s2.synapseType);
    assertEqual(s1.weight, s2.weight);
    assertEqual(s1.segments, s2.segments);
    assertEqual(s1.seeds, s2.seeds);
    assertEqual(s1.id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    assertEqual(s1.dynamicMetadata,s2.dynamicMetadata);
    assertEqual(s1.author,s2.author);
    assertEqual(eRAMONDataFormat.dense,s2.dataFormat);
    assertEqual(s2.name, 'Volume1');
    assertEqual(s1.data,s2.data);
    assertEqual(s1.resolution,s2.resolution);
    assertEqual(s1.xyzOffset,s2.xyzOffset);
end

%% Generic
function testGeneric
    a1 = RAMONGeneric();
    a1.setAuthor('dean');
    a1.setStatus(eRAMONAnnoStatus.locked);
    a1.setResolution(3);
    a1.setXyzOffset([23 34 45]);
    d = magic(10);
    a1.setCutout(d);
    
    hdfSeed = OCPHdf(a1);
    a2 = hdfSeed.toRAMONObject(eOCPQueryType.RAMONDense);
    
    assertEqual(a1.id,a2.id);
    assertEqual(a1.confidence,a2.confidence);
    assertEqual(a1.status,a2.status);
    assertEqual(a1.dynamicMetadata,a2.dynamicMetadata);
    assertEqual(a1.author,a2.author);
    assertEqual(eRAMONDataFormat.dense,a2.dataFormat);
    assertEqual(a2.name, 'Volume1');
    assertEqual(a1.data,a2.data);
    assertEqual(a1.resolution,a2.resolution);
    assertEqual(a1.xyzOffset,a2.xyzOffset);
end


%% Volume
function testVolume
    a1 = RAMONVolume();
    a1.setAuthor('dean');
    a1.setStatus(eRAMONAnnoStatus.locked);
    a1.setResolution(3);
    a1.setXyzOffset([23 34 45]);
    d = magic(10);
    a1.setCutout(d);
    
    hdfVol = OCPHdf(a1);
    a2 = hdfVol.toRAMONObject(eOCPQueryType.RAMONDense);
    
    assertEqual(a1.id,a2.id);
    assertEqual(a1.confidence,a2.confidence);
    assertEqual(a1.status,a2.status);
    assertEqual(a1.dynamicMetadata,a2.dynamicMetadata);
    assertEqual(a1.author,a2.author);
    assertEqual(eRAMONDataFormat.dense,a2.dataFormat);
    assertEqual(a2.name, 'Volume1');
    assertEqual(a1.data,a2.data);
    assertEqual(a1.resolution,a2.resolution);
    assertEqual(a1.xyzOffset,a2.xyzOffset);
  
    
    filename = [tempname '.h5'];
    hdfVol = OCPHdf(a1,filename);
    a2 = hdfVol.toRAMONObject(eOCPQueryType.RAMONDense);
    
    assertEqual(a1.id,a2.id);
    assertEqual(a1.confidence,a2.confidence);
    assertEqual(a1.status,a2.status);
    assertEqual(a1.dynamicMetadata,a2.dynamicMetadata);
    assertEqual(a1.author,a2.author);
    assertEqual(eRAMONDataFormat.dense,a2.dataFormat);
    assertEqual(a2.name, 'Volume1');
    assertEqual(a1.data,a2.data);
    assertEqual(a1.resolution,a2.resolution);
    assertEqual(a1.xyzOffset,a2.xyzOffset);    
end

function testVolumeFromService
    oo = OCP();
    oo.setImageToken('kasthuri11');
    q = OCPQuery(eOCPQueryType.imageDense);
    q.setCutoutArgs([2000 2200],[2000 2200],[1000 1010],1);
    a1 = oo.query(q);
    
    hdfVol = OCPHdf(a1);
    a2 = hdfVol.toRAMONObject(eOCPQueryType.RAMONDense);
    
    assertEqual(a1.id,a2.id);
    assertEqual(a1.confidence,a2.confidence);
    assertEqual(a1.status,a2.status);
    assertEqual(a1.dynamicMetadata,a2.dynamicMetadata);
    assertEqual(a1.author,a2.author);
    assertEqual(eRAMONDataFormat.dense,a2.dataFormat);
    assertEqual(a2.name, 'Volume1');
    assertEqual(double(a1.data),a2.data);
    assertEqual(a1.resolution,a2.resolution);
    assertEqual(a1.xyzOffset,a2.xyzOffset);
end



