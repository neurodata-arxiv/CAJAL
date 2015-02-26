function test_suite= testRAMONSeed%#ok<STOUT>
    %TESTSEED Unit test of the seed datatype
    
    %% Init the test suite
    initTestSuite;
    
end


function testTooManyArguments %#ok<*DEFNU>
    % Create seed with too many arguments
    assertExceptionThrown(@() RAMONSeed([50 23 12],eRAMONCubeOrientation.pos_z,124,14,31234,.89,eRAMONAnnoStatus.locked,{'test',23},'test',234,3234), 'RAMONSeed:TooManyArguments');
end

function testDefaultRAMONSeed
    % Create default seed
    s1 = RAMONSeed();
    assertEqual(s1.position, [0 0 0]);
    assertEqual(s1.cubeOrientation, eRAMONCubeOrientation.centered);
    assertEqual(s1.parentSeed, []);
    assertEqual(s1.sourceEntity, []);
    assertEqual(s1.id,[]);
    assertEqual(s1.confidence,1);
    assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(s1.dynamicMetadata,containers.Map());
    assertEqual(s1.author,'unspecified');
end

function testGoodRAMONSeed1
    % Create default seed
    s1 = RAMONSeed([50 23 12]);
    assertEqual(s1.position, [50 23 12]);
    assertEqual(s1.cubeOrientation, eRAMONCubeOrientation.centered);
    assertEqual(s1.parentSeed, []);
    assertEqual(s1.sourceEntity, []);
    assertEqual(s1.id,[]);
    assertEqual(s1.confidence,1);
    assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(s1.dynamicMetadata,containers.Map());
    assertEqual(s1.author,'unspecified');
end

function testGoodRAMONSeed2
    % Create default seed
    s1 = RAMONSeed([50 23 12],eRAMONCubeOrientation.pos_z);
    assertEqual(s1.position, [50 23 12]);
    assertEqual(s1.cubeOrientation, eRAMONCubeOrientation.pos_z);
    assertEqual(s1.parentSeed, []);
    assertEqual(s1.sourceEntity, []);
    assertEqual(s1.id,[]);
    assertEqual(s1.confidence,1);
    assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(s1.dynamicMetadata,containers.Map());
    assertEqual(s1.author,'unspecified');
end

function testGoodRAMONSeed3
    % Create default seed
    s1 = RAMONSeed([50 23 12],eRAMONCubeOrientation.pos_z,124);
    assertEqual(s1.position, [50 23 12]);
    assertEqual(s1.cubeOrientation, eRAMONCubeOrientation.pos_z);
    assertEqual(s1.parentSeed, 124);
    assertEqual(s1.sourceEntity, []);
    assertEqual(s1.id,[]);
    assertEqual(s1.confidence,1);
    assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(s1.dynamicMetadata,containers.Map());
    assertEqual(s1.author,'unspecified');
end

function testGoodRAMONSeed4
    % Create default seed
    s1 = RAMONSeed([50 23 12],eRAMONCubeOrientation.pos_z,124,14);
    assertEqual(s1.position, [50 23 12]);
    assertEqual(s1.cubeOrientation, eRAMONCubeOrientation.pos_z);
    assertEqual(s1.parentSeed, 124);
    assertEqual(s1.sourceEntity, 14);
    assertEqual(s1.id,[]);
    assertEqual(s1.confidence,1);
    assertEqual(s1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(s1.dynamicMetadata,containers.Map());
    assertEqual(s1.author,'unspecified');
end

function testGoodRAMONSeed5
    % Create RAMONSeed that is partially specified
    s1 = RAMONSeed([50 23 12],eRAMONCubeOrientation.pos_z,124,14,31234,.89,eRAMONAnnoStatus.locked,{'test',23});
    assertEqual(s1.id,31234);
    assertEqual(s1.confidence,.89);
    assertEqual(s1.status,eRAMONAnnoStatus.locked);
    assertEqual(s1.dynamicMetadata('test'),23);
    assertEqual(s1.author,'unspecified');
end

function testGoodRAMONSeed6
    % Create RAMONSeed that is partially specified
    s1 = RAMONSeed([50 23 12],eRAMONCubeOrientation.pos_z,124,14,31234,.89,eRAMONAnnoStatus.locked,{'test',23},'test');
    assertEqual(s1.id,31234);
    assertEqual(s1.confidence,.89);
    assertEqual(s1.status,eRAMONAnnoStatus.locked);
    assertEqual(s1.dynamicMetadata('test'),23);
    assertEqual(s1.author,'test');
end

function testWrongInputTypes
    % Test catching the wrong datatype for each field
    assertExceptionThrown(@() RAMONSeed([50 23],eRAMONCubeOrientation.pos_z,124,14), 'MATLAB:incorrectSize');
    assertExceptionThrown(@() RAMONSeed('a',eRAMONCubeOrientation.pos_z,124,14), 'MATLAB:invalidType');
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
    
    assertExceptionThrown(@() RAMONSeed([50 23 15],eRAMONCubeOrientation.positive_x), 'MATLAB:subscripting:classHasNoPropertyOrMethod');
    
    seed1.setCubeOrientation(0);
    assertEqual(seed1.cubeOrientation,eRAMONCubeOrientation.pos_x);
    seed1.setCubeOrientation(1);
    assertEqual(seed1.cubeOrientation,eRAMONCubeOrientation.neg_x);
    
    seed1.setCubeOrientation(2);
    assertEqual(seed1.cubeOrientation,eRAMONCubeOrientation.pos_y);
    seed1.setCubeOrientation(3);
    assertEqual(seed1.cubeOrientation,eRAMONCubeOrientation.neg_y);
    
    seed1.setCubeOrientation(4);
    assertEqual(seed1.cubeOrientation,eRAMONCubeOrientation.pos_z);
    seed1.setCubeOrientation(5);
    assertEqual(seed1.cubeOrientation,eRAMONCubeOrientation.neg_z);
    
    seed1.setCubeOrientation(6);
    assertEqual(seed1.cubeOrientation,eRAMONCubeOrientation.centered);
    
    
    assertExceptionThrown(@() RAMONSeed([50 23 15],7), 'MATLAB:class:InvalidEnum');
    
end


function testDeepCopy
    % Create default seed
    s1 = RAMONSeed([50 23 12],eRAMONCubeOrientation.pos_z,124,14,31234,.89,eRAMONAnnoStatus.locked,{'test',23},'test');
    s2 = s1.clone();
     
    assertEqual(s1.position, s2.position);
    assertEqual(s1.cubeOrientation, s2.cubeOrientation);
    assertEqual(s1.parentSeed, s2.parentSeed);
    assertEqual(s1.sourceEntity, s2.sourceEntity);
    assertEqual(s1.id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    assertEqual(s1.dynamicMetadata('test'),s2.dynamicMetadata('test'));
    assertEqual(s1.author, s2.author);
end







