function test_suite= testRAMONSegment%#ok<STOUT>
%testRAMONSegment Unit test of the synapse datatype

%% Init the test suite
initTestSuite;

end

function testDefaultRAMONSegment
% Create default segment
s1 = RAMONSegment();
assertEqual(s1.data, []);
assertEqual(s1.xyzOffset, []);
assertEqual(s1.resolution([]),[]);
assertEqual(s1.class, eRAMONSegmentClass.unknown);

assertEqual(s1.neuron, []);
assertEqual(s1.synapses, []);
assertEqual(s1.organelles, []);
assertEqual(s1.parentSeed,[]);
assertEqual(s1.id,[]);
assertEqual(s1.confidence,1);
assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
assertEqual(s1.dynamicMetadata,containers.Map());


end

function testGoodRAMONSegment1
% Create segment with partial initialization
s1 = RAMONSegment([1 2 1; 2 3 4],eRAMONDataFormat.dense);
assertEqual(s1.data, [1 2 1; 2 3 4]);
assertEqual(s1.xyzOffset, []);
assertEqual(s1.resolution,[]);
assertEqual(s1.class, eRAMONSegmentClass.unknown);

assertEqual(s1.neuron, []);
assertEqual(s1.synapses, []);
assertEqual(s1.organelles, []);
assertEqual(s1.parentSeed,[]);
assertEqual(s1.id,[]);
assertEqual(s1.confidence,1);
assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
assertEqual(s1.dynamicMetadata,containers.Map());

end

function testGoodRAMONSegment2
% Create segment with partial initialization
s1 = RAMONSegment([1 2 1; 2 3 4],eRAMONDataFormat.dense, [2 2 20]);
assertEqual(s1.data, [1 2 1; 2 3 4]);
assertEqual(s1.xyzOffset, [2 2 20]);
assertEqual(s1.resolution,[]);
assertEqual(s1.class, eRAMONSegmentClass.unknown);

assertEqual(s1.neuron, []);
assertEqual(s1.synapses, []);
assertEqual(s1.organelles, []);
assertEqual(s1.parentSeed,[]);
assertEqual(s1.id,[]);
assertEqual(s1.confidence,1);
assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
assertEqual(s1.dynamicMetadata,containers.Map());
end


function testGoodRAMONSegment3
s1 = RAMONSegment([1 2 1; 2 3 4],eRAMONDataFormat.dense, [2 2 20],1);
assertEqual(s1.data, [1 2 1; 2 3 4]);
assertEqual(s1.xyzOffset, [2 2 20])
assertEqual(s1.resolution,1);
assertEqual(s1.class, eRAMONSegmentClass.unknown);

assertEqual(s1.neuron, []);
assertEqual(s1.synapses, []);
assertEqual(s1.organelles, []);
assertEqual(s1.parentSeed,[]);
assertEqual(s1.id,[]);
assertEqual(s1.confidence,1);
assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
assertEqual(s1.dynamicMetadata,containers.Map());
end

function testGoodRAMONSegment4
s1 = RAMONSegment([1 2 1; 2 3 4],eRAMONDataFormat.dense, [2 2 20],1, eRAMONSegmentClass.axon);
assertEqual(s1.data, [1 2 1; 2 3 4]);
assertEqual(s1.xyzOffset, [2 2 20]);
assertEqual(s1.resolution,1);
assertEqual(s1.class, eRAMONSegmentClass.axon);

assertEqual(s1.neuron, []);
assertEqual(s1.synapses, []);
assertEqual(s1.organelles, []);
assertEqual(s1.parentSeed,[]);
assertEqual(s1.id,[]);
assertEqual(s1.confidence,1);
assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
assertEqual(s1.dynamicMetadata,containers.Map());
end

function testGoodRAMONSegment5
s1 = RAMONSegment([1 2 1; 2 3 4],eRAMONDataFormat.dense, [2 2 20],1, eRAMONSegmentClass.axon, 52);
assertEqual(s1.data, [1 2 1; 2 3 4]);
assertEqual(s1.xyzOffset, [2 2 20]);
assertEqual(s1.resolution,1);
assertEqual(s1.class, eRAMONSegmentClass.axon);

assertEqual(s1.neuron, 52);
assertEqual(s1.synapses, []);
assertEqual(s1.organelles, []);
assertEqual(s1.parentSeed,[]);
assertEqual(s1.id,[]);
assertEqual(s1.confidence,1);
assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
assertEqual(s1.dynamicMetadata,containers.Map());
assertEqual(s1.dataFormat, eRAMONDataFormat.dense);
end

function testGoodRAMONSegment6
s1 = RAMONSegment([1 2 1; 2 3 4],eRAMONDataFormat.dense, [2 2 20],1, eRAMONSegmentClass.axon, 52, 1000);
assertEqual(s1.data, [1 2 1; 2 3 4]);
assertEqual(s1.xyzOffset, [2 2 20]);
assertEqual(s1.resolution,1);
assertEqual(s1.class, eRAMONSegmentClass.axon);

assertEqual(s1.neuron, 52);
assertEqual(s1.synapses, 1000);
assertEqual(s1.organelles, []);
assertEqual(s1.parentSeed,[]);
assertEqual(s1.id,[]);
assertEqual(s1.confidence,1);
assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
assertEqual(s1.dynamicMetadata,containers.Map());
end

function testGoodRAMONSegment7
s1 = RAMONSegment([1 2 1; 2 3 4],eRAMONDataFormat.dense, [2 2 20],1, eRAMONSegmentClass.axon, 52,...
    1000, 10);
assertEqual(s1.data, [1 2 1; 2 3 4]);
assertEqual(s1.xyzOffset, [2 2 20]);
assertEqual(s1.resolution,1);
assertEqual(s1.class, eRAMONSegmentClass.axon);

assertEqual(s1.neuron, 52);
assertEqual(s1.synapses, 1000);
assertEqual(s1.organelles, 10);
assertEqual(s1.parentSeed,[]);
assertEqual(s1.id,[]);
assertEqual(s1.confidence,1);
assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
assertEqual(s1.dynamicMetadata,containers.Map());
end


function testGoodRAMONSegment8
s1 = RAMONSegment([1 2 1; 2 3 4],eRAMONDataFormat.dense, [2 2 20],1, eRAMONSegmentClass.axon, 52,...
    1000, 10);
assertEqual(s1.data, [1 2 1; 2 3 4]);
assertEqual(s1.xyzOffset, [2 2 20]);
assertEqual(s1.resolution,1);
assertEqual(s1.class, eRAMONSegmentClass.axon);

assertEqual(s1.neuron, 52);
assertEqual(s1.synapses, 1000);
assertEqual(s1.organelles, 10);
assertEqual(s1.parentSeed,[]);
assertEqual(s1.id,[]);
assertEqual(s1.confidence,1);
assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
assertEqual(s1.dynamicMetadata,containers.Map());
end

function testGoodRAMONSegment9
s1 = RAMONSegment([1 2 1; 2 3 4],eRAMONDataFormat.dense, [2 2 20],1, eRAMONSegmentClass.axon, 52,...
    1000, 10, 222);
assertEqual(s1.data, [1 2 1; 2 3 4]);
assertEqual(s1.xyzOffset, [2 2 20]);
assertEqual(s1.resolution,1);
assertEqual(s1.class, eRAMONSegmentClass.axon);

assertEqual(s1.neuron, 52);
assertEqual(s1.synapses, 1000);
assertEqual(s1.organelles, 10);
assertEqual(s1.parentSeed,222);
assertEqual(s1.id,[]);
assertEqual(s1.confidence,1);
assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
assertEqual(s1.dynamicMetadata,containers.Map());
end

function testGoodRAMONSegment10
s1 = RAMONSegment([1 2 1; 2 3 4],eRAMONDataFormat.dense, [2 2 20],1, eRAMONSegmentClass.axon, 52,...
    1000, 10, 222,22);
assertEqual(s1.data, [1 2 1; 2 3 4]);
assertEqual(s1.xyzOffset, [2 2 20]);
assertEqual(s1.resolution,1);
assertEqual(s1.class, eRAMONSegmentClass.axon);

assertEqual(s1.neuron, 52);
assertEqual(s1.synapses, 1000);
assertEqual(s1.organelles, 10);
assertEqual(s1.parentSeed,222);
assertEqual(s1.id,22);
assertEqual(s1.confidence,1);
assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
assertEqual(s1.dynamicMetadata,containers.Map());
end

function testGoodRAMONSegment11
s1 = RAMONSegment([1 2 1; 2 3 4],eRAMONDataFormat.dense, [2 2 20],1, eRAMONSegmentClass.axon, 52,...
    1000, 10, 222,22, 0.1);
assertEqual(s1.data, [1 2 1; 2 3 4]);
assertEqual(s1.xyzOffset, [2 2 20]);
assertEqual(s1.resolution,1);
assertEqual(s1.class, eRAMONSegmentClass.axon);

assertEqual(s1.neuron, 52);
assertEqual(s1.synapses, 1000);
assertEqual(s1.organelles, 10);
assertEqual(s1.parentSeed,222);
assertEqual(s1.id,22);
assertEqual(s1.confidence,.1);
assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
assertEqual(s1.dynamicMetadata,containers.Map());
end

function testGoodRAMONSegment12
s1 = RAMONSegment([1 2 1; 2 3 4],eRAMONDataFormat.dense, [2 2 20],1, eRAMONSegmentClass.axon, 52,...
    1000, 10, 222,22, 0.1, eRAMONAnnoStatus.locked);
assertEqual(s1.data, [1 2 1; 2 3 4]);
assertEqual(s1.xyzOffset, [2 2 20]);
assertEqual(s1.resolution,1);
assertEqual(s1.class, eRAMONSegmentClass.axon);

assertEqual(s1.neuron, 52);
assertEqual(s1.synapses, 1000);
assertEqual(s1.organelles, 10);
assertEqual(s1.parentSeed,222);
assertEqual(s1.id,22);
assertEqual(s1.confidence,.1);
assertEqual(s1.status,eRAMONAnnoStatus.locked);
assertEqual(s1.dynamicMetadata,containers.Map());
end

function testGoodRAMONSegment13
s1 = RAMONSegment([1 2 1; 2 3 4],eRAMONDataFormat.dense, [2 2 20],1, eRAMONSegmentClass.axon, 52,...
    1000, 10, 222,22, 0.1, eRAMONAnnoStatus.locked,[{'tempKey'},{'tempVal'}]);
assertEqual(s1.data, [1 2 1; 2 3 4]);
assertEqual(s1.xyzOffset, [2 2 20]);
assertEqual(s1.resolution,1);
assertEqual(s1.class, eRAMONSegmentClass.axon);

assertEqual(s1.neuron, 52);
assertEqual(s1.synapses, 1000);
assertEqual(s1.organelles, 10);
assertEqual(s1.parentSeed,222);
assertEqual(s1.id,22);
assertEqual(s1.confidence,.1);
assertEqual(s1.status,eRAMONAnnoStatus.locked);
assertEqual(s1.dynamicMetadata('tempKey'),'tempVal');
end

function testTooManyArguments %#ok<*DEFNU>
% Create synapse with too many arguments
assertExceptionThrown(@() RAMONSegment([1 2 1; 2 3 4],eRAMONDataFormat.dense,...
    [2 2 20],1, eRAMONSegmentClass.axon, 52,...
    1000, 10, 222,22, 0.1, eRAMONAnnoStatus.locked,[{'tempKey'},{'tempVal'}],'asdf',234,345),...
    'RAMONSegment:TooManyArguments');
end


function testDeepCopy
    % Create default seed
    d = repmat(magic(100),[1 1 100]);
    s1 = RAMONSegment(d ,eRAMONDataFormat.dense, [2 2 20],1, eRAMONSegmentClass.axon, 52,...
    1000, 10, 222,22, 0.1, eRAMONAnnoStatus.locked,[{'tempKey'},{'tempVal'}]);
    s2 = s1.clone();
    
    assertEqual(s1.data, s2.data);
    assertEqual(s1.xyzOffset, s2.xyzOffset);
    assertEqual(s1.resolution, s2.resolution);
    
    assertEqual(s1.class, s2.class);
    assertEqual(s1.neuron, s2.neuron);
    assertEqual(s1.synapses, s2.synapses);
    assertEqual(s1.organelles, s2.organelles);
    assertEqual(s1.parentSeed, s2.parentSeed);
    assertEqual(s1.id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    assertEqual(s1.dynamicMetadata('tempKey'),s2.dynamicMetadata('tempKey'));
    assertEqual(s1.author, s2.author);
end


% Additional tests will be implemented soon.