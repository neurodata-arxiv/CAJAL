function test_suite= testRAMONBase%#ok<STOUT>
    %TESTSEED Unit test of the seed datatype
    
    %% Init the test suite
    initTestSuite;
    
    
end


function testTooManyArguments %#ok<*DEFNU>
    % Create seed with too many arguments
    assertExceptionThrown(@() RAMONBase([],.6,eRAMONAnnoStatus.ignored,[],'tester',132,534,0,1,56,7), 'RAMONBase:TooManyArguments');
end

function testWrongMetadataInit %#ok<*DEFNU>
    % Create seed with too many arguments
    assertExceptionThrown(@() RAMONBase(31234,.89,eRAMONAnnoStatus.locked,{'test',23,'dasdf'}), 'RAMONBase:DMDFormatInvalid');
end


function testDefaultPointAnnotation
    % Create default seed
    pa1 = RAMONBase();
    assertEqual(pa1.id,[]);
    assertEqual(pa1.confidence,1);
    assertEqual(pa1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(pa1.dynamicMetadata,containers.Map);
    assertEqual(pa1.author,'unspecified');
end

function testGoodPointAnnotation1
    % Create PointAnnotation that is partially specified
    pa1 = RAMONBase(31234);
    assertEqual(pa1.id,31234);
    assertEqual(pa1.confidence,1);
    assertEqual(pa1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(pa1.dynamicMetadata,containers.Map);
    assertEqual(pa1.author,'unspecified');
end

function testGoodPointAnnotation2
    % Create PointAnnotation that is partially specified
    pa1 = RAMONBase(31234,.89);
    assertEqual(pa1.id,31234);
    assertEqual(pa1.confidence,.89);
    assertEqual(pa1.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(pa1.dynamicMetadata,containers.Map);
    assertEqual(pa1.author,'unspecified');
end

function testGoodPointAnnotation3
    % Create PointAnnotation that is partially specified
    pa1 = RAMONBase(31234,.89,eRAMONAnnoStatus.ignored);
    assertEqual(pa1.id,31234);
    assertEqual(pa1.confidence,.89);
    assertEqual(pa1.status,eRAMONAnnoStatus.ignored);
    assertEqual(pa1.dynamicMetadata,containers.Map);
    assertEqual(pa1.author,'unspecified');
end


function testGoodPointAnnotation4
    % Create PointAnnotation that is partially specified
    pa1 = RAMONBase(31234,.89,eRAMONAnnoStatus.locked,{'test',23});
    assertEqual(pa1.id,31234);
    assertEqual(pa1.confidence,.89);
    assertEqual(pa1.status,eRAMONAnnoStatus.locked);
    assertEqual(pa1.dynamicMetadata('test'),23);
    assertEqual(pa1.getMetadataKeys{:},'test');
    assertEqual(pa1.getMetadataValue('test'),23);
    assertEqual(pa1.author,'unspecified');
end


function testGoodPointAnnotation5
    % Create PointAnnotation that is partially specified
    pa1 = RAMONBase(31234,.89,eRAMONAnnoStatus.locked,{'test',23},'testuser');
    assertEqual(pa1.id,31234);
    assertEqual(pa1.confidence,.89);
    assertEqual(pa1.status,eRAMONAnnoStatus.locked);
    assertEqual(pa1.dynamicMetadata('test'),23);
    assertEqual(pa1.author,'testuser');
end

function testSetDynamicMetadata
    % Create PointAnnotation that is partially specified
    pa1 = RAMONBase(31234,.89,eRAMONAnnoStatus.locked,{'test',23},'testuser');
    assertEqual(pa1.id,31234);
    assertEqual(pa1.confidence,.89);
    assertEqual(pa1.status,eRAMONAnnoStatus.locked);
    assertEqual(pa1.dynamicMetadata('test'),23);
    assertEqual(pa1.author,'testuser');
    
    dmd = containers.Map({'test1'},{23453});
    
    pa1.setDynamicMetadata(dmd);
    assertEqual(pa1.dynamicMetadata('test1'),23453);   
end

function testAnnotationStatusInteger
    % Check different ways of indicating status works
    pa1 = RAMONBase(31234,.89,1,{'test',23});
    assertEqual(pa1.id,31234);
    assertEqual(pa1.confidence,.89);
    assertEqual(pa1.status,eRAMONAnnoStatus.locked);
    assertEqual(pa1.dynamicMetadata('test'),23);
    
    pa1.setStatus(0);
    assertEqual(pa1.status,eRAMONAnnoStatus.unprocessed);
    pa1.setStatus(1);
    assertEqual(pa1.status,eRAMONAnnoStatus.locked);
    pa1.setStatus(2);
    assertEqual(pa1.status,eRAMONAnnoStatus.processed);
    pa1.setStatus(3);
    assertEqual(pa1.status,eRAMONAnnoStatus.ignored);
    
    % Make sure inherent enum bound checking works
    assertExceptionThrown(@()RAMONBase(31234,.89,500,{'test',23}), 'MATLAB:class:InvalidEnum');
end

function testConfidenceBounds
    % Test catching out of bounds confidence values  
    assertExceptionThrown(@() RAMONBase(231,1.1,1,{'test',23}), 'MATLAB:notLessEqual'); 
    assertExceptionThrown(@() RAMONBase(231,-.1,1,{'test',23}), 'MATLAB:notGreaterEqual'); 
end


function testWrongInputTypes
    % Test catching the wrong datatype for each field   
    assertExceptionThrown(@() RAMONBase('sa',.89,1,{'test',23}), 'MATLAB:invalidType'); 
    assertExceptionThrown(@() RAMONBase(1.1,.89,1,{'test',23}), 'MATLAB:expectedInteger'); 
    assertExceptionThrown(@() RAMONBase(231,'1',1,{'test',23}), 'MATLAB:invalidType'); 
    assertExceptionThrown(@() RAMONBase(123,.89,'unprocessed',{'test',23}), 'MATLAB:invalidType'); 
    assertExceptionThrown(@() RAMONBase(123,.89,1,'tester,34'), 'RAMONBase:DMDFormatInvalid'); 
end

function testMetadataOperations
   % Test all metadata operations   
    pa1 = RAMONBase(100,1,0);
    
    % Add a bunch of metadata
    pa1.addDynamicMetadata('key1',1);
    pa1.addDynamicMetadata('key2',2);
    
    % Check listing
    keyList = pa1.getMetadataKeys();
    assertEqual(strcmp(keyList(1),'key1'),true);
    assertEqual(strcmp(keyList(2),'key2'),true);
    
    % Add more
    pa1.addDynamicMetadata('key3',3);
    pa1.addDynamicMetadata('key4','4');

    % Add to an exisiting key error
    assertExceptionThrown(@() pa1.addDynamicMetadata('key3',333), 'RAMONBase:DuplicateKey'); 
    
    % Update key
    pa1.updateDynamicMetadata('key2',100);
    value = pa1.getMetadataValue('key2');
    assertEqual(value,100);
    
    % Error update key that doesn't exist
    pa1.updateDynamicMetadata('key35234',1030);
    value = pa1.getMetadataValue('key35234');
    assertEqual(value,1030);
    
    
    % delete a key
    pa1.removeDynamicMetadata('key1');
    pa1.removeDynamicMetadata('key2');
    keyList = pa1.getMetadataKeys();
    assertEqual(strcmp(keyList(1),'key3'),true);
    assertEqual(strcmp(keyList(3),'key4'),true);
end

function testDeepCopy
    % Create default seed
    s1 = RAMONBase(31234,.89,eRAMONAnnoStatus.locked,{'test',23},'testuser');
    s2 = s1.clone();
    
    assertEqual(s1.id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    assertEqual(s1.dynamicMetadata('test'),s2.dynamicMetadata('test'));
    assertEqual(s1.author, s2.author);
end




