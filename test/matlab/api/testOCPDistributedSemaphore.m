function test_suite = testOCPDistributedSemaphore %#ok<STOUT>
    %% TESTOCP Unit Test suite for the OCP api class
    %Note: Uses redis DB 1
    
    %% Init the test suite
    initTestSuite;
    
    % shut of warnings (comment this out to test warning if desired)
    warning('off','OCP:BatchWriteError');
    warning('off','OCP:RAMONResolutionEmpty');
    warning('off','OCP:MissingInitQuery');
end

%% Test Distributed Semaphore

function testSemaphoreNetworkConfigSemaphore
   oo1 = OCP('semaphore');
   assertEqual((oo1.numReadPermits > 0),true);
   assertEqual((oo1.numWritePermits > 0),true);       
end

function testSemaphorePost %#ok<*DEFNU>
    
    oo1 = OCP('neuron.jhuapl.edu',6379,'readQ',10,0,'writeQ',20,100);
    oo1.setDefaultResolution(1);
    oo1.selectDatabaseIndex(1); % Select non-default db so you don't mess with stuff running
    
    s = SemaphoreTool;
    s.selectDatabaseIndex(1);
    s.resetAll();
        
    oo1.setImageToken('kasthuri11');
    oo1.setAnnoToken('apiUnitTestKasthuri');
    
    % Create annotations
    d = ones(100,100,4);
    s1 = RAMONSegment(d, eRAMONDataFormat.dense,[2200 3200 1200], 1, eRAMONSegmentClass.unknown,54,...
        [2 45], [234 67], 64, [], .65, eRAMONAnnoStatus.unprocessed,...
        {'tester',6565},'testuser');
    
    id = oo1.createAnnotation(s1);
    
    
    % Download annotations
    q = OCPQuery(eOCPQueryType.RAMONDense,id);
    s2 = oo1.query(q);
    
    % Check them
    assertEqual(s1.author, s2.author);
    assertEqual(s1.resolution, s2.resolution);
    assertEqual(id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    keys = s1.dynamicMetadata.keys;
    assertEqual(s1.dynamicMetadata(keys{1}),s2.dynamicMetadata(keys{1}));
    assertEqual(s1.class, s2.class);
    assertEqual(s1.parentSeed, s2.parentSeed);
    assertEqual(s1.synapses, s2.synapses);
    assertEqual(s1.neuron, s2.neuron);
    assertEqual(s1.organelles, s2.organelles);
    
    % check it matches
    inds1 = find(s1.data>0);
    inds2 = find(s2.data>0);
    
    % make sure every labled pixel in s1 is labled in s2 via db coords
    [y,x,z] = ind2sub(size(s1.data),inds1);
    g1 = s1.local2Global([x,y,z]);
    l1 = s2.global2Local(g1);
    indsCheck = sub2ind(size(s2.data),l1(:,2),l1(:,1),l1(:,3));
    assertEqual(s2.data(indsCheck), repmat(s2.id,length(indsCheck),1));
    
    % make sure every labled pixel in s2 is labled in s1 via db coords
    [y,x,z] = ind2sub(size(s2.data),inds2);
    g2 = s2.local2Global([x,y,z]);
    l2 = s1.global2Local(g2);
    indsCheck = sub2ind(size(s1.data),l2(:,2),l2(:,1),l2(:,3));
    assertEqual(s1.data(indsCheck), ones(length(indsCheck),1));
    
end


%% Clean up
function cleanup
    
    % Turn warnings back on.
    warning('on','OCP:BatchWriteError');
    warning('on','OCP:RAMONResolutionEmpty');    
    warning('on','OCP:MissingInitQuery');
end

