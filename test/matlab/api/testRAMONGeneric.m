function test_suite= testRAMONGeneric%#ok<STOUT>
    %TESTSEED Unit test of the seed datatype
    
    %% Init the test suite
    initTestSuite;
    
    
end

function testDefaultGenericAnnotation %#ok<*DEFNU>
    % Create default seed
    a1 = RAMONGeneric();
    assertEqual(a1.id,[]);
    assertEqual(a1.confidence,1);
    assertEqual(a1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(a1.dynamicMetadata,containers.Map);
    assertEqual(a1.author,'unspecified');
    
    assertEqual(a1.data,[]);
    assertEqual(a1.xyzOffset,[]);
    assertEqual(a1.resolution,[]);
    assertEqual(a1.name,'Volume1');
    assertEqual(a1.sliceDisplayIndex,1);
    assertEqual(a1.dataFormat,eRAMONDataFormat.dense);
end


function testGenericFields %#ok<*DEFNU>
    % Create default seed
    a1 = RAMONGeneric();
    a1.setStatus(eRAMONAnnoStatus.locked);
    assertEqual(a1.status,eRAMONAnnoStatus.locked);
end

function testConvertTypes
    a1 = RAMONGeneric();
    a1.setAuthor('dean');
    a1.setStatus(eRAMONAnnoStatus.locked);
    a1.setResolution(3);
    a1.setXyzOffset([23 34 45]);
    d = magic(10);
    a1.setCutout(d);
    
    synapse = a1.toSynapse();
    assertEqual(isa(synapse,'RAMONSynapse'),true);
    assertEqual(synapse.author,'dean');
    assertEqual(synapse.status,eRAMONAnnoStatus.locked);
    assertEqual(synapse.data,d);
    assertEqual(synapse.xyzOffset,[23 34 45]);
    assertEqual(synapse.resolution,3);
    
    seed = a1.toSeed();
    assertEqual(isa(seed,'RAMONSeed'),true);
    assertEqual(seed.author,'dean');
    assertEqual(seed.status,eRAMONAnnoStatus.locked);
    
    segment = a1.toSegment();
    assertEqual(isa(segment,'RAMONSegment'),true);
    assertEqual(segment.author,'dean');
    assertEqual(segment.status,eRAMONAnnoStatus.locked);
    assertEqual(segment.data,d);
    assertEqual(segment.xyzOffset,[23 34 45]);
    assertEqual(segment.resolution,3);
    
    neuron = a1.toNeuron();
    assertEqual(isa(neuron,'RAMONNeuron'),true);
    assertEqual(neuron.author,'dean');
    assertEqual(neuron.status,eRAMONAnnoStatus.locked);  
end

function testConvertHDF5
    a1 = RAMONGeneric();
    a1.setAuthor('dean');
    a1.setStatus(eRAMONAnnoStatus.locked);
    a1.setResolution(3);
    a1.setXyzOffset([23 34 45]);
    d = magic(10);
    a1.setCutout(d);
    a1.addDynamicMetadata('test',213);
    
    hfile = a1.toHDF();
    
    data = h5read(hfile.filename,'/0/METADATA/AUTHOR');
    assertEqual(a1.author,data{:});
    data = h5read(hfile.filename,'/0/RESOLUTION');
    assertEqual(a1.resolution,double(data));
    
    
end

function testDeepCopy   
    d = repmat(magic(100),[1 1 100]);
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONSynapseType.excitatory, 100,...
        [1,1;2,0],[2,34],12,.64, eRAMONAnnoStatus.processed,{'tester',1212},'test');
    s1 = s1.toGeneric();
    s2 = s1.clone();
    
    assertEqual(s1.data, s2.data);
    assertEqual(s1.xyzOffset, s2.xyzOffset);
    assertEqual(s1.resolution, s2.resolution);   
    
    assertEqual(s1.id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    assertEqual(s1.dynamicMetadata('tester'),s2.dynamicMetadata('tester'));
    assertEqual(s1.author, s2.author);
end

