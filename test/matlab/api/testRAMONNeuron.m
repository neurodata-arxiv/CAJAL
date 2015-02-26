function test_suite= testRAMONNeuron%#ok<STOUT>
    %TESTNeuron Unit test of the neuron datatype
    
    %% Init the test suite
    initTestSuite;
    
end

function testTooManyArguments %#ok<*DEFNU>
    % Create neuron with too many arguments
    assertExceptionThrown(@() RAMONNeuron(1,32,.1,1,[{'test'},{'test2'}],'sample author','too many'), 'RAMONNeuron:TooManyArguments');
end

function testDefaultRAMONNeuron %#ok<*DEFNU>
    % Create default seed
    n1 = RAMONNeuron();
    assertEqual(n1.segments, []);
    assertEqual(n1.id, []);
    assertEqual(n1.confidence,1);
    assertEqual(n1.status,eRAMONAnnoStatus.unprocessed)
    assertEqual(n1.dynamicMetadata,containers.Map());
    assertEqual(n1.author,'unspecified');
end

function testGoodRAMONNeuron1
    %one input argument - partial neuron specification
    n1 = RAMONNeuron([23, 46]);
    assertEqual(n1.segments, [23, 46]);
    assertEqual(n1.id, []);
    assertEqual(n1.confidence,1);
    assertEqual(n1.status,eRAMONAnnoStatus.unprocessed)
    assertEqual(n1.dynamicMetadata,containers.Map());
    assertEqual(n1.author,'unspecified');
end

function testGoodRAMONNeuron2
    %two input arguments - partial neuron specification
    n1 = RAMONNeuron([23, 46], 4200);
    assertEqual(n1.segments, [23, 46]);
    assertEqual(n1.id, 4200);
    assertEqual(n1.confidence,1);
    assertEqual(n1.status,eRAMONAnnoStatus.unprocessed)
    assertEqual(n1.dynamicMetadata,containers.Map());
    assertEqual(n1.author,'unspecified');
end

function testGoodRAMONNeuron3
    %three input arguments - partial neuron specification
    n1 = RAMONNeuron([23, 46], 4200, 0.8);
    assertEqual(n1.segments, [23, 46]);
    assertEqual(n1.id, 4200);
    assertEqual(n1.confidence,0.8);
    assertEqual(n1.status,eRAMONAnnoStatus.unprocessed)
    assertEqual(n1.dynamicMetadata,containers.Map());
    assertEqual(n1.author,'unspecified');
end

function testGoodRAMONNeuron4
    %four input arguments - partial neuron specification
    n1 = RAMONNeuron([23, 46], 4200, 0.8,eRAMONAnnoStatus.ignored);
    assertEqual(n1.segments, [23, 46]);
    assertEqual(n1.id, 4200);
    assertEqual(n1.confidence,0.8);
    assertEqual(n1.status,eRAMONAnnoStatus.ignored)
    assertEqual(n1.dynamicMetadata,containers.Map());
    assertEqual(n1.author,'unspecified');
end

function testGoodRAMONNeuron5
    %five input arguments - partial neuron specification
    n1 = RAMONNeuron([23, 46], 4200, 0.8,eRAMONAnnoStatus.ignored,[{'testKey'},{'testValue'}]);
    assertEqual(n1.segments, [23, 46]);
    assertEqual(n1.id, 4200);
    assertEqual(n1.confidence,0.8);
    assertEqual(n1.status,eRAMONAnnoStatus.ignored)
    assertEqual(n1.dynamicMetadata('testKey'),'testValue');
    assertEqual(n1.author,'unspecified');
end

function testGoodRAMONNeuron6
    %six input arguments - full neuron specification
    n1 = RAMONNeuron([23, 46], 4200, 0.8,eRAMONAnnoStatus.ignored,[{'testKey'},{'testValue'}],'testAuthor');
    assertEqual(n1.segments, [23, 46]);
    assertEqual(n1.id, 4200);
    assertEqual(n1.confidence,0.8);
    assertEqual(n1.status,eRAMONAnnoStatus.ignored)
    assertEqual(n1.dynamicMetadata('testKey'),'testValue');
    assertEqual(n1.author,'testAuthor');
end


function testWrongInputTypes
    % Test catching the wrong datatype for each field
    assertExceptionThrown(@() RAMONNeuron('blue'), 'MATLAB:invalidType');
    assertExceptionThrown(@() RAMONNeuron(3.2), 'MATLAB:expectedInteger');
    assertExceptionThrown(@() RAMONNeuron([23, 46], -2), 'MATLAB:expectedNonnegative');
    assertExceptionThrown(@() RAMONNeuron([23, 46], 4200, 1.1), 'MATLAB:notLessEqual');
    assertExceptionThrown(@() RAMONNeuron([23, 46], 4200, 0.8,'ignored'), 'MATLAB:invalidType');
    assertExceptionThrown(@() RAMONNeuron([23, 46], 4200, 0.8,eRAMONAnnoStatus.ignored,[42,{'testValue'}]), 'RAMONBase:InvalidKey');
    assertExceptionThrown(@() RAMONSeed([50 23 456],eRAMONCubeOrientation.pos_z,124.2,14), 'MATLAB:expectedInteger');
    assertExceptionThrown(@() RAMONSeed([50 23 456],eRAMONCubeOrientation.centered,124,14.4), 'MATLAB:expectedInteger');
end

function testCubeLocationOptions
    % Test all options for cube orientaiton field and an invalid option
    
    seed1 = RAMONSeed([50 23 15],eRAMONCubeOrientation.pos_x);
    assertEqual(seed1.cubeOrientation,eRAMONCubeOrientation.pos_x);
    seed1 = RAMONSeed([50 23 15],eRAMONCubeOrientation.pos_y);
    assertEqual(seed1.cubeOrientation,eRAMONCubeOrientation.pos_y);
    seed1 = RAMONSeed([50 23 15],eRAMONCubeOrientation.pos_z);
    assertEqual(seed1.cubeOrientation,eRAMONCubeOrientation.pos_z);
    seed1 = RAMONSeed([50 23 15],eRAMONCubeOrientation.neg_z);
    assertEqual(seed1.cubeOrientation,eRAMONCubeOrientation.neg_z);
    seed1 = RAMONSeed([50 23 15],eRAMONCubeOrientation.neg_y);
    assertEqual(seed1.cubeOrientation,eRAMONCubeOrientation.neg_y);
    seed1 = RAMONSeed([50 23 15],eRAMONCubeOrientation.neg_x);
    assertEqual(seed1.cubeOrientation,eRAMONCubeOrientation.neg_x);
    seed1 = RAMONSeed([50 23 15],eRAMONCubeOrientation.centered);
    assertEqual(seed1.cubeOrientation,eRAMONCubeOrientation.centered);
    
    %Other checks
    n1 = RAMONNeuron;
    
    %directly set a field
    try
        n1.segments = 5;
    catch output
        assertEqual(output.identifier,'MATLAB:class:SetProhibited');
    end
    
    %retrieve a field that does not exist
    try
        ss = n1.seg;
    catch output
        assertEqual(output.identifier,'MATLAB:noSuchMethodOrField');
    end
    
    function testNeuronOperations
        % to be implemented
    end
end


function testDeepCopy
    % Create default seed
    s1 = RAMONNeuron([23, 46], 4200, 0.8,eRAMONAnnoStatus.ignored,[{'testKey'},{'testValue'}],'testAuthor');
    s2 = s1.clone();    
    
    assertEqual(s1.segments, s2.segments);
    assertEqual(s1.id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    assertEqual(s1.dynamicMetadata('testKey'),s2.dynamicMetadata('testKey'));
    assertEqual(s1.author, s2.author);
end