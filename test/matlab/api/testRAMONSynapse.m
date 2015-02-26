function test_suite= testRAMONSynapse%#ok<STOUT>
    %testRAMONSeed Unit test of the synapse datatype
    
    %% Init the test suite
    initTestSuite;
    
end

function testDefaultRAMONSynapse
    % Create default seed
    s1 = RAMONSynapse();
    
    assertEqual(s1.synapseType, eRAMONSynapseType.unknown);
    assertEqual(s1.weight, []);
    assertEqual(s1.segments, containers.Map('KeyType', 'uint32','ValueType','uint32'));
    assertEqual(s1.seeds, []);
    assertEqual(s1.id,[]);
    assertEqual(s1.confidence,1);
    assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(s1.dynamicMetadata,containers.Map());
    assertEqual(s1.data, []);
    assertEqual(s1.xyzOffset, []);
    assertEqual(s1.name, 'Volume1');
    assertEqual(s1.author, 'unspecified');
end

function testGoodRAMONSynapse1
    % Create default seed
    d = repmat(magic(100),[1 1 100]);
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense);
    
    assertEqual(s1.data, d);
    
    assertEqual(s1.xyzOffset, []);
    assertEqual(s1.synapseType, eRAMONSynapseType.unknown);
    assertEqual(s1.weight, []);
    assertEqual(s1.segments, containers.Map('KeyType', 'uint32','ValueType','uint32'));
    assertEqual(s1.seeds, []);
    assertEqual(s1.id,[]);
    assertEqual(s1.confidence,1);
    assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(s1.dynamicMetadata,containers.Map());
    assertEqual(s1.author, 'unspecified');
end

function testGoodRAMONSynapse2
    % Create default seed
    d = repmat(magic(100),[1 1 100]);
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65]);
    
    assertEqual(s1.data, d);
    assertEqual(s1.xyzOffset, [45 54 65]);
    
    assertEqual(s1.synapseType, eRAMONSynapseType.unknown);
    assertEqual(s1.weight, []);
    assertEqual(s1.segments, containers.Map('KeyType', 'uint32','ValueType','uint32'));
    assertEqual(s1.seeds, []);
    assertEqual(s1.id,[]);
    assertEqual(s1.confidence,1);
    assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(s1.dynamicMetadata,containers.Map());
    assertEqual(s1.author, 'unspecified');
end

function testGoodRAMONSynapse3
    % Create default seed
    d = repmat(magic(100),[1 1 100]);
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],1);
    
    assertEqual(s1.data, d);
    assertEqual(s1.xyzOffset, [45 54 65]);
    assertEqual(s1.resolution, 1);
    
    assertEqual(s1.synapseType, eRAMONSynapseType.unknown);    
    assertEqual(s1.weight, []);
    assertEqual(s1.segments, containers.Map('KeyType', 'uint32','ValueType','uint32'));
    assertEqual(s1.seeds, []);
    assertEqual(s1.id,[]);
    assertEqual(s1.confidence,1);
    assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(s1.dynamicMetadata,containers.Map());
    assertEqual(s1.author, 'unspecified');
end

function testGoodRAMONSynapse4
    % Create default seed
    d = repmat(magic(100),[1 1 100]);
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONSynapseType.excitatory);
    
    assertEqual(s1.data, d);
    assertEqual(s1.xyzOffset, [45 54 65]);
    assertEqual(s1.resolution, 1);
    assertEqual(s1.synapseType, eRAMONSynapseType.excitatory);
    
    assertEqual(s1.weight, []);
    assertEqual(s1.segments, containers.Map('KeyType', 'uint32','ValueType','uint32'));
    assertEqual(s1.seeds, []);
    assertEqual(s1.id,[]);
    assertEqual(s1.confidence,1);
    assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(s1.dynamicMetadata,containers.Map());
    assertEqual(s1.author, 'unspecified');
end

function testGoodRAMONSynapse5
    % Create default seed
    d = repmat(magic(100),[1 1 100]);
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONSynapseType.excitatory, 100);
    
    assertEqual(s1.data, d);
    assertEqual(s1.xyzOffset, [45 54 65]);
    assertEqual(s1.resolution, 1);
    assertEqual(s1.synapseType, eRAMONSynapseType.excitatory);
    assertEqual(s1.weight, 100);
    
    assertEqual(s1.segments, containers.Map('KeyType', 'uint32','ValueType','uint32'));
    assertEqual(s1.seeds, []);
    assertEqual(s1.id,[]);
    assertEqual(s1.confidence,1);
    assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(s1.dynamicMetadata,containers.Map());
    assertEqual(s1.author, 'unspecified');
end

function testGoodRAMONSynapse6
    % Create default seed
    d = repmat(magic(100),[1 1 100]);
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONSynapseType.excitatory, 100,...
        [1,1;2,0]);
    
    assertEqual(s1.data, d);
    assertEqual(s1.xyzOffset, [45 54 65]);
    assertEqual(s1.resolution, 1);
    assertEqual(s1.synapseType, eRAMONSynapseType.excitatory);
    assertEqual(s1.weight, 100);
    
    keys = s1.segments.keys;
    assertEqual(s1.segments(keys{1}), uint32(1));
    assertEqual(s1.segments(keys{2}), uint32(0));
    
    assertEqual(s1.seeds, []);
    assertEqual(s1.id,[]);
    assertEqual(s1.confidence,1);
    assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(s1.dynamicMetadata,containers.Map());
    assertEqual(s1.author, 'unspecified');
end

function testGoodRAMONSynapse7
    % Create default seed
    d = repmat(magic(100),[1 1 100]);
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONSynapseType.excitatory, 100,...
        [1,1;2,0],[2,34]);
    
    assertEqual(s1.data, d);
    assertEqual(s1.xyzOffset, [45 54 65]);
    assertEqual(s1.resolution, 1);
    assertEqual(s1.synapseType, eRAMONSynapseType.excitatory);
    assertEqual(s1.weight, 100);
    
    keys = s1.segments.keys;
    assertEqual(s1.segments(keys{1}), uint32(1));
    assertEqual(s1.segments(keys{2}), uint32(0));
    assertEqual(s1.seeds, [2,34]);
    
    assertEqual(s1.id,[]);
    assertEqual(s1.confidence,1);
    assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(s1.dynamicMetadata,containers.Map());
    assertEqual(s1.author, 'unspecified');
end

function testGoodRAMONSynapse8
    % Create default seed
    d = repmat(magic(100),[1 1 100]);
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONSynapseType.excitatory, 100,...
        [1,1;2,0],[2,34],12);
    
    assertEqual(s1.data, d);
    assertEqual(s1.xyzOffset, [45 54 65]);
    assertEqual(s1.resolution, 1);
    assertEqual(s1.synapseType, eRAMONSynapseType.excitatory);
    assertEqual(s1.weight, 100);
    
    keys = s1.segments.keys;
    assertEqual(s1.segments(keys{1}), uint32(1));
    assertEqual(s1.segments(keys{2}), uint32(0));  
    assertEqual(s1.seeds, [2,34]);
    assertEqual(s1.id,12);
    
    assertEqual(s1.confidence,1);
    assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(s1.dynamicMetadata,containers.Map());
    assertEqual(s1.author, 'unspecified');
end

function testGoodRAMONSynapse9
    % Create default seed
    d = repmat(magic(100),[1 1 100]);
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONSynapseType.excitatory, 100,...
        [1,1;2,0],[2,34],12,.64);
    
    assertEqual(s1.data, d);
    assertEqual(s1.xyzOffset, [45 54 65]);
    assertEqual(s1.resolution, 1);
    assertEqual(s1.synapseType, eRAMONSynapseType.excitatory);
    assertEqual(s1.weight, 100);
    
    keys = s1.segments.keys;
    assertEqual(s1.segments(keys{1}), uint32(1));
    assertEqual(s1.segments(keys{2}), uint32(0));
    assertEqual(s1.seeds, [2,34]);
    assertEqual(s1.id,12);
    assertEqual(s1.confidence,.64);
    
    assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(s1.dynamicMetadata,containers.Map());
    assertEqual(s1.author, 'unspecified');
end

function testGoodRAMONSynapse10
    % Create default seed
    d = repmat(magic(100),[1 1 100]);
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONSynapseType.excitatory, 100,...
        [1,1;2,0],[2,34],12,.64, eRAMONAnnoStatus.processed);
    
    assertEqual(s1.data, d);
    assertEqual(s1.xyzOffset, [45 54 65]);
    assertEqual(s1.resolution, 1);
    assertEqual(s1.synapseType, eRAMONSynapseType.excitatory);
    assertEqual(s1.weight, 100);
    
    keys = s1.segments.keys;
    assertEqual(s1.segments(keys{1}), uint32(1));
    assertEqual(s1.segments(keys{2}), uint32(0)); 
    assertEqual(s1.seeds, [2,34]);
    assertEqual(s1.id,12);
    assertEqual(s1.confidence,.64);
    assertEqual(s1.status,eRAMONAnnoStatus.processed);
    
    assertEqual(s1.dynamicMetadata,containers.Map());
    assertEqual(s1.author, 'unspecified');
end

function testGoodRAMONSynapse11
    % Create default seed
    d = repmat(magic(100),[1 1 100]);
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONSynapseType.excitatory, 100,...
        [1,1;2,0],[2,34],12,.64, eRAMONAnnoStatus.processed,{'tester',1212});
    
    assertEqual(s1.data, d);
    assertEqual(s1.xyzOffset, [45 54 65]);
    assertEqual(s1.resolution, 1);
    assertEqual(s1.synapseType, eRAMONSynapseType.excitatory);
    assertEqual(s1.weight, 100);
    keys = s1.segments.keys;
    assertEqual(s1.segments(keys{1}), uint32(1));
    assertEqual(s1.segments(keys{2}), uint32(0));
    assertEqual(s1.seeds, [2,34]);
    assertEqual(s1.id,12);
    assertEqual(s1.confidence,.64);
    assertEqual(s1.status,eRAMONAnnoStatus.processed);
    assertEqual(s1.dynamicMetadata('tester'),1212);
    assertEqual(s1.author, 'unspecified');
end

function testGoodRAMONSynapse12
    % Create default seed
    d = repmat(magic(100),[1 1 100]);
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONSynapseType.excitatory, 100,...
        [1,1;2,0],[2,34],12,.64, eRAMONAnnoStatus.processed,{'tester',1212},'test');
    
    assertEqual(s1.data, d);
    assertEqual(s1.xyzOffset, [45 54 65]);
    assertEqual(s1.resolution, 1);
    assertEqual(s1.synapseType, eRAMONSynapseType.excitatory);
    assertEqual(s1.weight, 100);
    
    keys = s1.segments.keys;
    assertEqual(s1.segments(keys{1}), uint32(1));
    assertEqual(s1.segments(keys{2}), uint32(0));
    assertEqual(s1.seeds, [2,34]);
    assertEqual(s1.id,12);
    assertEqual(s1.confidence,.64);
    assertEqual(s1.status,eRAMONAnnoStatus.processed);
    assertEqual(s1.dynamicMetadata('tester'),1212);
    assertEqual(s1.author, 'test');
end


function testTooManyArguments %#ok<*DEFNU>
    d = repmat(magic(100),[1 1 100]);
    % Create synapse with too many arguments
    assertExceptionThrown(@() RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],1,...
        eRAMONSynapseType.excitatory, 100,...
        [1,1;2,0],[2,34],12,.64, eRAMONAnnoStatus.processed,...
        {'tester',1212},'test',23,345), 'RAMONSynapse:TooManyArguments');
end

function testWrongInputTypes
    % Test catching the wrong datatype for each field
    
    d = repmat(magic(100),[1 1 100]);
    assertExceptionThrown(@() RAMONSynapse(-1,eRAMONDataFormat.dense,[45 54 65],0,eRAMONSynapseType.excitatory, 100,...
        [1,1;2,0],[2,34],12,.64, eRAMONAnnoStatus.processed,{'tester',1212}),...
        'MATLAB:expectedNonnegative');
    assertExceptionThrown(@() RAMONSynapse(d,eRAMONDataFormat.dense,[45 54],0,eRAMONSynapseType.excitatory, 100,...
        [1,1;2,0],[2,34],12,.64, eRAMONAnnoStatus.processed,{'tester',1212}),...
        'MATLAB:incorrectSize');
    assertExceptionThrown(@() RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],0,9, 100,...
        [1,1;2,0],[2,34],12,.64, eRAMONAnnoStatus.processed,{'tester',1212}),...
        'MATLAB:class:InvalidEnum');
    assertExceptionThrown(@() RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],0,1, 'a',...
        [1,1;2,0],[2,34],12,.64, eRAMONAnnoStatus.processed,{'tester',1212}),...
        'MATLAB:invalidType');
    assertExceptionThrown(@() RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],0,1, 100,...
        [1,1,0],[2,34],12,.64, eRAMONAnnoStatus.processed,{'tester',1212}),...
        'RAMONSynapse:SegmentsFormatInvalid');
    assertExceptionThrown(@() RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],0,1, 100,...
        [1,1],[2,34],'s',.64, eRAMONAnnoStatus.processed,{'tester',1212}),...
        'MATLAB:invalidType');
    assertExceptionThrown(@() RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],0,1, 100,...
        [1,1],[2,34],64,1.1, eRAMONAnnoStatus.processed,{'tester',1212}),...
        'MATLAB:notLessEqual');
    assertExceptionThrown(@() RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],0,1, 100,...
        [1,1],[2,34],64,1, 12,{'tester',1212}),...
        'MATLAB:class:InvalidEnum');
    assertExceptionThrown(@() RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],0,1, 100,...
        [1,1],[2,34],64,1, 0,[1 2]),...
        'MATLAB:cellRefFromNonCell');
     assertExceptionThrown(@() RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],0,eRAMONSynapseType.excitatory, 100,...
        [1,1;2,0],[2.5,34],12,.64, eRAMONAnnoStatus.processed,{'tester',1212}),...
        'MATLAB:expectedInteger');
     assertExceptionThrown(@() RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONSynapseType.excitatory, 100,...
        [1,1;2,0],[2,34],12,.64, eRAMONAnnoStatus.processed,{'tester',1212},361),...
        'RAMONBase:InvalidAuthor');
     assertExceptionThrown(@() RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],1.1,eRAMONSynapseType.excitatory, 100,...
        [1,1;2,0],[2,34],12,.64, eRAMONAnnoStatus.processed,{'tester',1212},'test'),...
        'MATLAB:expectedInteger');
end


function testSynapseTypeOptions
    % Test all options for synapseType field and an invalid option
    d = repmat(magic(100),[1 1 100]);
    syn1 = RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],0,eRAMONSynapseType.unknown, 100,...
        [1,1],[],64,1, eRAMONAnnoStatus.unprocessed,[]);
    assertEqual(syn1.synapseType,eRAMONSynapseType.unknown);
    syn1 = RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],0,eRAMONSynapseType.excitatory, 100,...
        [1,1],[],64,1, eRAMONAnnoStatus.unprocessed,[]);
    assertEqual(syn1.synapseType,eRAMONSynapseType.excitatory);
    syn1 = RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],0,eRAMONSynapseType.inhibitory, 100,...
        [1,1],[],64,1, eRAMONAnnoStatus.unprocessed,[]);
    assertEqual(syn1.synapseType,eRAMONSynapseType.inhibitory);
    
    
    assertExceptionThrown(@() RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],0,eRAMONSynapseType.super, 100,...
        [1,1],[],64,1, 0,[]),...
        'MATLAB:subscripting:classHasNoPropertyOrMethod');
    
    syn1.setSynapseType(0);
    assertEqual(syn1.synapseType,eRAMONSynapseType.unknown);
    syn1.setSynapseType(1);
    assertEqual(syn1.synapseType,eRAMONSynapseType.excitatory);
    syn1.setSynapseType(2);
    assertEqual(syn1.synapseType,eRAMONSynapseType.inhibitory);
    
    assertExceptionThrown(@() RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],0,66, 100,...
        [1,1],[],64,1, 0,[]),...
        'MATLAB:class:InvalidEnum');
end


function testSegmentOperations
   % Test all metadata operations   
    s1 = RAMONSynapse();
    
    % Add a bunch of segments
    s1.addSegment(12,eRAMONFlowDirection.preSynaptic);
    s1.addSegment(13,eRAMONFlowDirection.postSynaptic);    
    
    % Check listing
    keys = s1.segments.keys;
    assertEqual(eRAMONFlowDirection(s1.segments(keys{1})),eRAMONFlowDirection.preSynaptic);
    assertEqual(eRAMONFlowDirection(s1.segments(keys{2})),eRAMONFlowDirection.postSynaptic);
    
    % Add more
    s1.addSegment(14,eRAMONFlowDirection.biDirectional);
    s1.addSegment(15,eRAMONFlowDirection.unknown);  

    % Add to an exisiting key error
    assertExceptionThrown(@() s1.addSegment(12,eRAMONFlowDirection.unknown), 'RAMONSynapse:IDExists'); 
           
    % delete a key
    s1.removeSegment(12);
    s1.removeSegment(13);
    keys = s1.segments.keys;
    assertEqual(eRAMONFlowDirection(s1.segments(keys{1})),eRAMONFlowDirection.biDirectional);
    assertEqual(eRAMONFlowDirection(s1.segments(keys{2})),eRAMONFlowDirection.unknown);
end

function testDeepCopy
    % Create default seed
    d = repmat(magic(100),[1 1 100]);
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONSynapseType.excitatory, 100,...
        [1,1;2,0],[2,34],12,.64, eRAMONAnnoStatus.processed,{'tester',1212},'test');
    s2 = s1.clone();
    
    assertEqual(s1.data, s2.data);
    assertEqual(s1.xyzOffset, s2.xyzOffset);
    assertEqual(s1.resolution, s2.resolution);
    assertEqual(s1.synapseType, s2.synapseType);
    assertEqual(s1.weight, s2.weight);
    
    keys = s1.segments.keys;
    assertEqual(s1.segments(keys{1}), s2.segments(keys{1}));
    assertEqual(s1.segments(keys{2}), s2.segments(keys{2}));
    assertEqual(s1.seeds, s2.seeds);
    assertEqual(s1.id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    assertEqual(s1.dynamicMetadata('tester'),s2.dynamicMetadata('tester'));
    assertEqual(s1.author, s2.author);
end





