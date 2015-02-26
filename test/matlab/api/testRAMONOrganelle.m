function test_suite= testRAMONOrganelle%#ok<STOUT>
    %TESTSEED Unit test of the seed datatype
    
    %% Init the test suite
    initTestSuite;
    
    
end

function testDefaultRAMONOrganelle
    % Create default seed
    o1 = RAMONOrganelle();
    
    assertEqual(o1.class, eRAMONOrganelleClass.unknown);
    assertEqual(o1.seeds, []);
    assertEqual(o1.parentSeed, []);
    assertEqual(o1.id,[]);
    assertEqual(o1.confidence,1);
    assertEqual(o1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(o1.dynamicMetadata,containers.Map());
    assertEqual(o1.data, []);
    assertEqual(o1.xyzOffset, []);
    assertEqual(o1.resolution, []);
    assertEqual(o1.name, 'Volume1');
    assertEqual(o1.author, 'unspecified');
end

function testGoodRAMONOrganelle1
    d = repmat(magic(100),[1 1 100]);
    o1 = RAMONOrganelle(d,eRAMONDataFormat.dense);
    
    assertEqual(o1.data, d);
    
    assertEqual(o1.xyzOffset, []);
    assertEqual(o1.resolution, []);
    assertEqual(o1.class, eRAMONOrganelleClass.unknown);
    assertEqual(o1.seeds, []);
    assertEqual(o1.parentSeed, []);
    assertEqual(o1.id,[]);
    assertEqual(o1.confidence,1);
    assertEqual(o1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(o1.dynamicMetadata,containers.Map());
    assertEqual(o1.author, 'unspecified');
end

function testGoodRAMONOrganelle2
    d = repmat(magic(100),[1 1 100]);
    o1 = RAMONOrganelle(d,eRAMONDataFormat.dense,[45 54 65]);
    
    assertEqual(o1.data, d);
    assertEqual(o1.xyzOffset, [45 54 65]);    
    
    assertEqual(o1.resolution, []);
    assertEqual(o1.class, eRAMONOrganelleClass.unknown);
    assertEqual(o1.seeds, []);
    assertEqual(o1.parentSeed, []);
    assertEqual(o1.id,[]);
    assertEqual(o1.confidence,1);
    assertEqual(o1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(o1.dynamicMetadata,containers.Map());
    assertEqual(o1.author, 'unspecified');
end

function testGoodRAMONOrganelle3
    d = repmat(magic(100),[1 1 100]);
    o1 = RAMONOrganelle(d,eRAMONDataFormat.dense,[45 54 65],1);
    
    assertEqual(o1.data, d);
    assertEqual(o1.xyzOffset, [45 54 65]);
    assertEqual(o1.resolution, 1);
    

    assertEqual(o1.class, eRAMONOrganelleClass.unknown);
    assertEqual(o1.seeds, []);
    assertEqual(o1.parentSeed, []);
    assertEqual(o1.id,[]);
    assertEqual(o1.confidence,1);
    assertEqual(o1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(o1.dynamicMetadata,containers.Map());
    assertEqual(o1.author, 'unspecified');
end

function testGoodRAMONOrganelle4
    d = repmat(magic(100),[1 1 100]);
    o1 = RAMONOrganelle(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONOrganelleClass.mitochondria);
    
    assertEqual(o1.data, d);
    assertEqual(o1.xyzOffset, [45 54 65]);
    assertEqual(o1.resolution, 1);
    assertEqual(o1.class, eRAMONOrganelleClass.mitochondria);
    
    assertEqual(o1.seeds, []);
    assertEqual(o1.parentSeed, []);
    assertEqual(o1.id,[]);
    assertEqual(o1.confidence,1);
    assertEqual(o1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(o1.dynamicMetadata,containers.Map());
    assertEqual(o1.author, 'unspecified');
end

function testGoodRAMONOrganelle5
    d = repmat(magic(100),[1 1 100]);
    o1 = RAMONOrganelle(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONOrganelleClass.mitochondria, [123 345 56]);
    
    assertEqual(o1.data, d);
    assertEqual(o1.xyzOffset, [45 54 65]);
    assertEqual(o1.resolution, 1);
    assertEqual(o1.class, eRAMONOrganelleClass.mitochondria);    
    assertEqual(o1.seeds, [123 345 56]);
    
    assertEqual(o1.parentSeed, []);
    assertEqual(o1.id,[]);
    assertEqual(o1.confidence,1);
    assertEqual(o1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(o1.dynamicMetadata,containers.Map());
    assertEqual(o1.author, 'unspecified');
end

function testGoodRAMONOrganelle6
    d = repmat(magic(100),[1 1 100]);
    o1 = RAMONOrganelle(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONOrganelleClass.mitochondria, [123 345 56],...
        3);
    
    assertEqual(o1.data, d);
    assertEqual(o1.xyzOffset, [45 54 65]);
    assertEqual(o1.resolution, 1);
    assertEqual(o1.class, eRAMONOrganelleClass.mitochondria);    
    assertEqual(o1.seeds, [123 345 56]);    
    assertEqual(o1.parentSeed, 3);
    
    assertEqual(o1.id,[]);
    assertEqual(o1.confidence,1);
    assertEqual(o1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(o1.dynamicMetadata,containers.Map());
    assertEqual(o1.author, 'unspecified');
end

function testGoodRAMONOrganelle7
    d = repmat(magic(100),[1 1 100]);
    o1 = RAMONOrganelle(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONOrganelleClass.mitochondria, [123 345 56],...
        3,3456);
    
    assertEqual(o1.data, d);
    assertEqual(o1.xyzOffset, [45 54 65]);
    assertEqual(o1.resolution, 1);
    assertEqual(o1.class, eRAMONOrganelleClass.mitochondria);    
    assertEqual(o1.seeds, [123 345 56]);    
    assertEqual(o1.parentSeed, 3);    
    assertEqual(o1.id,3456);
    
    assertEqual(o1.confidence,1);
    assertEqual(o1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(o1.dynamicMetadata,containers.Map());
    assertEqual(o1.author, 'unspecified');
end


function testGoodRAMONOrganelle8
    d = repmat(magic(100),[1 1 100]);
    o1 = RAMONOrganelle(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONOrganelleClass.mitochondria, [123 345 56],...
        3,3456,.263);
    
    assertEqual(o1.data, d);
    assertEqual(o1.xyzOffset, [45 54 65]);
    assertEqual(o1.resolution, 1);
    assertEqual(o1.class, eRAMONOrganelleClass.mitochondria);    
    assertEqual(o1.seeds, [123 345 56]);    
    assertEqual(o1.parentSeed, 3);    
    assertEqual(o1.id,3456);    
    assertEqual(o1.confidence,.263);
    
    assertEqual(o1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(o1.dynamicMetadata,containers.Map());
    assertEqual(o1.author, 'unspecified');
end


function testGoodRAMONOrganelle9
    d = repmat(magic(100),[1 1 100]);
    o1 = RAMONOrganelle(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONOrganelleClass.mitochondria, [123 345 56],...
        3,3456,.263, eRAMONAnnoStatus.processed);
    
    assertEqual(o1.data, d);
    assertEqual(o1.xyzOffset, [45 54 65]);
    assertEqual(o1.resolution, 1);
    assertEqual(o1.class, eRAMONOrganelleClass.mitochondria);    
    assertEqual(o1.seeds, [123 345 56]);    
    assertEqual(o1.parentSeed, 3);    
    assertEqual(o1.id,3456);    
    assertEqual(o1.confidence,.263);    
    assertEqual(o1.status,eRAMONAnnoStatus.processed);
    
    assertEqual(o1.dynamicMetadata,containers.Map());
    assertEqual(o1.author, 'unspecified');
end


function testGoodRAMONOrganelle10
    d = repmat(magic(100),[1 1 100]);
    o1 = RAMONOrganelle(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONOrganelleClass.mitochondria, [123 345 56],...
        3,3456,.263, eRAMONAnnoStatus.processed,{'tester',1212});
    
    assertEqual(o1.data, d);
    assertEqual(o1.xyzOffset, [45 54 65]);
    assertEqual(o1.resolution, 1);
    assertEqual(o1.class, eRAMONOrganelleClass.mitochondria);    
    assertEqual(o1.seeds, [123 345 56]);    
    assertEqual(o1.parentSeed, 3);    
    assertEqual(o1.id,3456);    
    assertEqual(o1.confidence,.263);    
    assertEqual(o1.status,eRAMONAnnoStatus.processed);
    assertEqual(o1.dynamicMetadata('tester'),1212);
    
    assertEqual(o1.author, 'unspecified');
end


function testGoodRAMONOrganelle11
    d = repmat(magic(100),[1 1 100]);
    o1 = RAMONOrganelle(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONOrganelleClass.mitochondria, [123 345 56],...
        3,3456,.263, eRAMONAnnoStatus.processed,{'tester',1212},'unit test');
    
    assertEqual(o1.data, d);
    assertEqual(o1.xyzOffset, [45 54 65]);
    assertEqual(o1.resolution, 1);
    assertEqual(o1.class, eRAMONOrganelleClass.mitochondria);    
    assertEqual(o1.seeds, [123 345 56]);    
    assertEqual(o1.parentSeed, 3);    
    assertEqual(o1.id,3456);    
    assertEqual(o1.confidence,.263);    
    assertEqual(o1.status,eRAMONAnnoStatus.processed);
    assertEqual(o1.dynamicMetadata('tester'),1212);  
    assertEqual(o1.author, 'unit test');
end

function testTooManyArguments %#ok<*DEFNU>

    d = repmat(magic(100),[1 1 100]);
    % Create organelle with too many arguments
    assertExceptionThrown(@() RAMONOrganelle(d,eRAMONDataFormat.dense,...
        [45 54 65],1,eRAMONOrganelleClass.mitochondria, [123 345 56],...
        3,3456,.263, eRAMONAnnoStatus.processed,{'tester',1212},'unit test',12,436),...
        'RAMONOrganelle:TooManyArguments');
end


function testWrongInputTypes
    % Test catching the wrong datatype for each field
    
    d = repmat(magic(100),[1 1 100]);
    
    assertExceptionThrown(@() RAMONOrganelle([1 -2;5,2],eRAMONDataFormat.dense,[45 54 65],1,eRAMONOrganelleClass.mitochondria, [123 345 56],...
        3,3456,.263, eRAMONAnnoStatus.processed,{'tester',1212},'unit test'),'MATLAB:expectedNonnegative');
    assertExceptionThrown(@() RAMONOrganelle(d,67,[45 54 65],1,eRAMONOrganelleClass.mitochondria, [123 345 56],...
        3,3456,.263, eRAMONAnnoStatus.processed,{'tester',1212},'unit test'),'MATLAB:class:InvalidEnum');
    assertExceptionThrown(@() RAMONOrganelle(d,eRAMONDataFormat.dense,[45 54 65 123],1,eRAMONOrganelleClass.mitochondria, [123 345 56],...
        3,3456,.263, eRAMONAnnoStatus.processed,{'tester',1212},'unit test'),'MATLAB:incorrectSize');
    assertExceptionThrown(@() RAMONOrganelle(d,eRAMONDataFormat.dense,[45 54 65],-1,eRAMONOrganelleClass.mitochondria, [123 345 56],...
        3,3456,.263, eRAMONAnnoStatus.processed,{'tester',1212},'unit test'),'MATLAB:expectedNonnegative');
    assertExceptionThrown(@() RAMONOrganelle(d,eRAMONDataFormat.dense,[45 54 65],1,'df', [123 345 56],...
        3,3456,.263, eRAMONAnnoStatus.processed,{'tester',1212},'unit test'),'MATLAB:invalidType');
    assertExceptionThrown(@() RAMONOrganelle(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONOrganelleClass.mitochondria, [123 345 -56],...
        3,3456,.263, eRAMONAnnoStatus.processed,{'tester',1212},'unit test'),'MATLAB:expectedNonnegative');
    assertExceptionThrown(@() RAMONOrganelle(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONOrganelleClass.mitochondria, [123 345 56],...
        [3 34],3456,.263, eRAMONAnnoStatus.processed,{'tester',1212},'unit test'),'MATLAB:expectedScalar'); 
    assertExceptionThrown(@() RAMONOrganelle(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONOrganelleClass.mitochondria, [123 345 56],...
        3,-2,.263, eRAMONAnnoStatus.processed,{'tester',1212},'unit test'),'MATLAB:expectedNonnegative');
    assertExceptionThrown(@() RAMONOrganelle(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONOrganelleClass.mitochondria, [123 345 56],...
        3,3456,1561, eRAMONAnnoStatus.processed,{'tester',1212},'unit test'),'MATLAB:notLessEqual');
    assertExceptionThrown(@() RAMONOrganelle(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONOrganelleClass.mitochondria, [123 345 56],...
        3,3456,.263, 9,{'tester',1212},'unit test'),'MATLAB:class:InvalidEnum');
    assertExceptionThrown(@() RAMONOrganelle(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONOrganelleClass.mitochondria, [123 345 56],...
        3,3456,.263, eRAMONAnnoStatus.processed,23,'unit test'),'RAMONBase:MetadataFormatInvalid');
    assertExceptionThrown(@() RAMONOrganelle(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONOrganelleClass.mitochondria, [123 345 56],...
        3,3456,.263, eRAMONAnnoStatus.processed,{'tester',1212},2134),'RAMONBase:InvalidAuthor');
end


function testDeepCopy
    % Create default seed
    d = repmat(magic(100),[1 1 100]);
    s1 = RAMONOrganelle(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONOrganelleClass.mitochondria, [123 345 56],...
        3,3456,.263, eRAMONAnnoStatus.processed,{'tester',1212},'unit test');
    s2 = s1.clone();
    
    assertEqual(s1.data, s2.data);
    assertEqual(s1.xyzOffset, s2.xyzOffset);
    assertEqual(s1.resolution, s2.resolution);    
   
    assertEqual(s1.parentSeed, s2.parentSeed);
    assertEqual(s1.class, s2.class);
    assertEqual(s1.seeds, s2.seeds);
    assertEqual(s1.id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    assertEqual(s1.dynamicMetadata('tester'),s2.dynamicMetadata('tester'));
    assertEqual(s1.author, s2.author);
end
