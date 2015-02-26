function test_suite = testOCP %#ok<STOUT>
    %% TESTOCP Unit Test suite for the OCP api class
    global ocp_force_local
    
    % This variable switches the database tokens to force to local database
    % locations if server mapping is used on default tokens.
    % You should leave this set to false unless you know what you are doing.
    ocp_force_local = false;
    % You should leave this set to false unless you know what you are doing.
    
    %% Init the test suite
    initTestSuite;
    
    % shut of warnings (comment this out to test warning if desired)
    warning('off','OCP:BatchWriteError');
    warning('off','OCP:RAMONResolutionEmpty');
    warning('off','OCP:MissingInitQuery');
    warning('off','OCP:CustomKVPair');
    
    % May need to update class since it looks like global use has
    % changed in new version of matlab...only really need this for unit 
    %testing so low priority right now.
    warning('off','MATLAB:declareGlobalBeforeUse');
    
end

%% Cutout Service - Test Missing Parameters

function testInit %#ok<*DEFNU>
    global oo
    oo = OCP(); %#ok<*NASGU>   
    
    % database bad
    assertExceptionThrown(@() oo.setServerLocation('http://openconnectooo.me'), 'OCP:ServerConnFail'); %#ok<*NODEF>
    
    % database good
    oo.setServerLocation('www.google.com');
    assertEqual(oo.serverLocation,'http://www.google.com/');
    oo.setServerLocation('http://openconnecto.me/') ;    
    %oo.setServerLocation('http://braingraph1dev.cs.jhu.edu') ;
    
    % image token
    assertEqual(isempty(oo.imageInfo),true);
    oo.setImageToken('kasthuri11');
    assertEqual(oo.getImageToken(),'kasthuri11');
    assertEqual(isempty(oo.imageInfo),false);
 
    % test token loading from a file
    oo.setAnnoTokenFile(fullfile(fileparts(which('cajal3d')),'test','matlab','api','data','myToken.token'));
    assertEqual(oo.getAnnoToken(),'apiUnitTestKasthuri');
    assertEqual(isempty(oo.annoInfo),false);    
end


function testNoToken %#ok<*DEFNU>   
    global oo    
    global ocp_force_local
    
    oo = OCP();    
    
    % image token
    oo.setImageToken('kasthuri11');
    
    s1 = RAMONSeed([10000 10000 50],eRAMONCubeOrientation.pos_z,124,14,[],.89,eRAMONAnnoStatus.locked,{'test',23});
    assertExceptionThrown(@() oo.createAnnotation(s1), 'OCP:MissingAnnoToken');
    
    % Anno token
    if ocp_force_local == true
        oo.setAnnoToken('apiUnitTestKasthuriLocal');
    else
        oo.setAnnoToken('apiUnitTestKasthuri');
    end
    
    % Set default resolutino
    oo.setDefaultResolution(1);
end


%% Volume Cutouts Bad Queries

% Bad Query
function testBadVolumeCutout
    global oo
    
    % Build Queries that fail at build time
    for ii = 1:2
        switch ii
            case 1
                q = OCPQuery(eOCPQueryType.imageDense);
            case 2
                q = OCPQuery(eOCPQueryType.annoDense);
        end
        
        assertExceptionThrown(@() q.setCutoutArgs(5000,4500,5000,5500,102,111,0), 'OCPQuery:BadRange');
        assertExceptionThrown(@() q.setCutoutArgs(4000,3500,5000,5500,102,111,0), 'OCPQuery:BadRange');
        assertExceptionThrown(@() q.setCutoutArgs(4000,4500,6000,5500,102,111,0), 'OCPQuery:BadRange');
        assertExceptionThrown(@() q.setCutoutArgs(4000,4500,5000,4500,102,111,0), 'OCPQuery:BadRange');
        assertExceptionThrown(@() q.setCutoutArgs(4000,4500,5000,5500,102,100,0), 'OCPQuery:BadRange');
        assertExceptionThrown(@() q.setCutoutArgs(4000,4500,5000,5500,122,111,0), 'OCPQuery:BadRange');
        
        % Build Queries that fail at query time
        switch ii
            case 1
                q = OCPQuery(eOCPQueryType.imageDense);
            case 2
                q = OCPQuery(eOCPQueryType.annoDense);
        end
        q.setXRange([2 600]);
        warning('off','OCP:QueryResolutionEmpty');
        assertExceptionThrown(@() oo.query(q), 'OCP:BadQuery');
        q.setYRange([2 600]);
        assertExceptionThrown(@() oo.query(q), 'OCP:BadQuery');
        q.setZRange([500 5000]);
        assertExceptionThrown(@() oo.query(q), 'OCP:BadQuery');
        
        % test warns (manual debug)
        %     q.setZRange([500 520]);
        %     q.setARange([12 43]);
        %     q.setBRange([12 43]);
        %     q.setCIndex(34);
        %     q.addIdListPredicate(eOCPPredicate.status,0);
        %     q.setSlicePlane(eOCPSlicePlane.xy);
        %     [tf msg] = q.validate(oo.imageInfo);
        
        q.setCutoutArgs(4000,4500,5000,6456164351,102,111,0);
        assertExceptionThrown(@() oo.query(q), 'OCP:BadQuery');
        q.setCutoutArgs(4000,65456123,5000,5500,102,111,0);
        assertExceptionThrown(@() oo.query(q), 'OCP:BadQuery');
        q.setCutoutArgs(4000,4500,5000,5500,102,54214,0);
        assertExceptionThrown(@() oo.query(q), 'OCP:BadQuery');
    end
end




%% Image Slice Bad Queries
function testBadSliceCutout
    global oo
    
    % Build Queries that fail at build time
    for ii = 1:3
        switch ii
            case 1
                q = OCPQuery(eOCPQueryType.imageSlice);
            case 2
                q = OCPQuery(eOCPQueryType.annoSlice);
            case 3
                q = OCPQuery(eOCPQueryType.overlaySlice);
        end
        
        assertExceptionThrown(@() q.setCutoutArgs(5000,4500,5000,5500,102,0), 'OCPQuery:BadRange');
        assertExceptionThrown(@() q.setCutoutArgs(4000,3500,5000,5500,102,0), 'OCPQuery:BadRange');
        assertExceptionThrown(@() q.setCutoutArgs(4000,4500,6000,5500,102,0), 'OCPQuery:BadRange');
        assertExceptionThrown(@() q.setCutoutArgs(4000,4500,5000,4500,102,0), 'OCPQuery:BadRange');
        
        % Build Queries that fail at query time
        switch ii
            case 1
                q = OCPQuery(eOCPQueryType.imageSlice);
            case 2
                q = OCPQuery(eOCPQueryType.annoSlice);
            case 3
                q = OCPQuery(eOCPQueryType.overlaySlice);
        end
        q.setXRange([2 600]);
        assertExceptionThrown(@() oo.query(q), 'OCP:BadQuery');
        warning('off','OCP:BadQuery');
        q.setYRange([2 600]);
        assertExceptionThrown(@() oo.query(q), 'OCP:BadQuery');
        q.setZRange([500 5000]);
        assertExceptionThrown(@() oo.query(q), 'OCP:BadQuery');
        
        % test warns (manual debug)
        %     q.setZRange([500 520]);
        %     q.setARange([12 43]);
        %     q.setBRange([12 43]);
        %     q.setCIndex(34);
        %     q.addIdListPredicate(eOCPPredicate.status,0);
        %     q.setSlicePlane(eOCPSlicePlane.xy);
        %     [tf msg] = q.validate(oo.imageInfo);
        
        q.setSliceArgs(eOCPSlicePlane.xy,4000,4500,5000,6456164351,102,0);
        assertExceptionThrown(@() oo.query(q), 'OCP:BadQuery');
        q.setSliceArgs(eOCPSlicePlane.xy,4000,65456123,5000,5500,102,0);
        assertExceptionThrown(@() oo.query(q), 'OCP:BadQuery');
        q.setSliceArgs(eOCPSlicePlane.xy,4000,4500,5000,5500,54214,0);
        assertExceptionThrown(@() oo.query(q), 'OCP:BadQuery');
    end
end

%% RAMON - Volume/block style uploads
function testUploadDownloadProbMapCutout %#ok<*DEFNU>
    global ocp_force_local
    
    oo2 = OCP();    
    % image token
    oo2.setImageToken('kasthuri11');    
    
    % Anno token
    if ocp_force_local == true
        oo2.setAnnoToken('apiUnitTestKasthuriProbLocal');
    else
        oo2.setAnnoToken('apiUnitTestKasthuriProb');
    end
    
    % Set default resolutino
    oo2.setDefaultResolution(1);
    
    % upload annotation
    %d = magic(1024)/1024^2;
    %d = repmat(d,[1,1,5]);

    d = magic(1024)/1024^2;
    d = repmat(d,[1,1,48]);
    
    g1 = RAMONVolume;
    g1.setCutout(d);
    g1.setXyzOffset([2560 1000 64]);
    g1.setResolution(1);
    g1.setDataType(eRAMONDataType.prob32);
        
    oo2.createAnnotation(g1);
        
    % download annotation - cutout
    q = OCPQuery(eOCPQueryType.probDense);
    q.setCutoutArgs([2560,2560+1024],[1000, 1000+1024],[64, 64+48],1);
    g2 = oo2.query(q);
    
    % check that are the same    
    assertEqual(class(g2.data),'single');
    inds1 = find(single(g1.data) ~= g2.data, 1);
    assertEqual(isempty(inds1),true);
    assertEqual(g2.xyzOffset,g1.xyzOffset);
    assertEqual(g2.resolution,g1.resolution);
    assertEqual(g2.dataFormat,g1.dataFormat);    
end

function testUploadDownloadAnnoBlockCutout %#ok<*DEFNU>
    global oo
    
    % upload annotation
    d = checkerboard(150)*10;
    d = repmat(d,[1,1,16]);
    
    g1 = RAMONVolume;
    g1.setCutout(d);
    g1.setXyzOffset([2560 1000 128]);
    g1.setResolution(1);
    g1.setDataType(eRAMONDataType.anno32);
    
    oo.createAnnotation(g1);
    
    % download annotation - cutout
    q = OCPQuery(eOCPQueryType.annoDense);
    q.setCutoutArgs([2560,2560+g1.size(1)],[1000, 1000+g1.size(2)],[128, 128+g1.size(3)],1);
    g2 = oo.query(q);
        
    % check that are the same
    assertEqual(class(g2.data),'uint32');
    inds1 = find(uint32(g1.data) ~= g2.data, 1);
    assertEqual(isempty(inds1),true);
    assertEqual(g2.xyzOffset,g1.xyzOffset);
    assertEqual(g2.resolution,g1.resolution);
    assertEqual(g2.dataFormat,g1.dataFormat);  
end

%% RAMON - Generic
function testUploadDownloadDeleteGenericMeta %#ok<*DEFNU>
    global oo
    
    % upload annotation
    g1 = RAMONGeneric();
    g1.setConfidence(.24);
    g1.addDynamicMetadata('test',234);
    
    id = oo.createAnnotation(g1);
    
    % download annotation - metaonly
    q = OCPQuery(eOCPQueryType.RAMONMetaOnly);
    q.setId(id);
    g2 = oo.query(q);
    
    
    assertEqual(g2.id,id);
    assertEqual(g2.confidence,.24);
    assertEqual(g2.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(g2.dynamicMetadata('test'),234);
    assertEqual(g2.author,'unspecified');
    
    assertEqual(g2.data,[]);
    assertEqual(g2.xyzOffset,[]);
    assertEqual(g2.resolution,[]);
    assertEqual(g2.dataFormat,eRAMONDataFormat.dense);
    
    % Delete
    oo.deleteAnnotation(g2.id);
    
    % See if it is gone
    assertExceptionThrown(@() oo.query(q), 'OCPNetwork:InternalServerError');
    
    % Delete should fail now too
    assertExceptionThrown(@()  oo.deleteAnnotation(g2.id), 'OCPNetwork:InternalServerError');
end

function testUploadDownloadDeleteGenericCutout %#ok<*DEFNU>
    global oo
        
    % upload annotation
    d = zeros(100,80,30);
    d(40:60,40:60,1:2) = 1;
    d(50:55,60:70,2:3) = 1;
    g1 = RAMONGeneric();
    g1.setConfidence(.32);
    g1.addDynamicMetadata('test',234);
    g1.setCutout(d);
    g1.setXyzOffset([34 345 64]);
    g1.setResolution(1);
    
    id = oo.createAnnotation(g1);
    
    % download annotation - cutout
    q = OCPQuery(eOCPQueryType.RAMONDense);
    q.setId(id);
    q.setResolution(1);
    g2 = oo.query(q);
    
    
    % check that they match!
    inds1 = find(g1.data>0);
    inds2 = find(g2.data>0);
    
    % make sure every labled pixel in g1 is labled in g2 via db coords
    for ii = 1:length(inds1)
        [y,x,z] = ind2sub(size(g1.data),inds1(ii));
        gg1 = g1.local2Global([x,y,z]);
        l1 = g2.global2Local(gg1);
        assertEqual(g2.data(l1(2),l1(1),l1(3)), g2.id);
    end
    
    % make sure every labled pixel in g2 is labled in g1 via db coords
    for ii = 1:length(inds2)
        [y,x,z] = ind2sub(size(g2.data),inds2(ii));
        gg2 = g2.local2Global([x,y,z]);
        l2 = g1.global2Local(gg2);
        assertEqual(g1.data(l2(2),l2(1),l2(3)),1);
    end
    
    assertEqual(g2.id,id);
    assertEqual(g2.confidence,g1.confidence);
    assertEqual(g2.status,g1.status);
    assertEqual(g2.dynamicMetadata('test'),g1.dynamicMetadata('test'));
    assertEqual(g2.author,g1.author);
    
    assertEqual(g2.resolution,g1.resolution);
    assertEqual(g2.dataFormat,g1.dataFormat);
    
    % Delete
    oo.deleteAnnotation(g2.id);
    
    % See if it is gone
    assertExceptionThrown(@() oo.query(q), 'OCPNetwork:InternalServerError');
end


function testUploadDownloadDeleteGenericVoxelList %#ok<*DEFNU>
    global oo
    
    % upload annotation
    clear d
    d(:,1) = 500:550;
    d(:,2) = 1500:1550;
    d(:,3) = ones(1,51)*50;
    
    g1 = RAMONGeneric();
    g1.setConfidence(.32);
    g1.addDynamicMetadata('test',234);
    g1.setVoxelList(d);
    g1.setResolution(1);
    
    id = oo.createAnnotation(g1);
    
    % download annotation - cutout
    q = OCPQuery(eOCPQueryType.RAMONVoxelList);
    q.setId(id);
    g2 = oo.query(q);
    
    
    % check that they match!
    unionedData = union(g1.data,g2.data,'rows');
    assertEqual(size(unionedData,1), size(g1.data,1));
    assertEqual(size(unionedData,2), size(g1.data,2));
    assertEqual(unionedData, uint32(g1.data));
    
    assertEqual(g2.id,id);
    assertEqual(g2.confidence,g1.confidence);
    assertEqual(g2.status,g1.status);
    assertEqual(g2.dynamicMetadata('test'),g1.dynamicMetadata('test'));
    assertEqual(g2.author,g1.author);
    
    assertEqual(g2.resolution,g1.resolution);
    assertEqual(g2.dataFormat,g1.dataFormat);
    
    
    % Delete
    oo.deleteAnnotation(g2.id);
    
    % See if it is gone
    assertExceptionThrown(@() oo.query(q), 'OCPNetwork:InternalServerError');
end


%% RAMON - Seed
function testUploadDownloadSeed %#ok<*DEFNU>
    global oo
    
    % upload annotation
    s1 = RAMONSeed([10000 10000 50],eRAMONCubeOrientation.pos_z,12,13,[],.70,eRAMONAnnoStatus.locked,{'test',34});
    id = oo.createAnnotation(s1);
    
    % download annotation - metaonly
    q = OCPQuery(eOCPQueryType.RAMONMetaOnly);
    q.setId(id);
    s2 = oo.query(q);
    
    % check that they match!
    assertEqual(s1.position,s2.position);
    assertEqual(s1.cubeOrientation,s2.cubeOrientation);
    assertEqual(s1.parentSeed,s2.parentSeed);
    assertEqual(s1.sourceEntity,s2.sourceEntity);
    assertEqual(id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    keys = s1.dynamicMetadata.keys;
    assertEqual(s1.dynamicMetadata(keys{1}),s2.dynamicMetadata(keys{1}));
    
    % download annotation - voxel list should be the same?
    q.setType(eOCPQueryType.RAMONVoxelList);
    assertExceptionThrown(@() oo.query(q), 'OCPNetwork:InternalServerError');
    
    % download annotation - same with dens
    q.setType(eOCPQueryType.RAMONDense);
    assertExceptionThrown(@() oo.query(q), 'OCPNetwork:InternalServerError');
end

function testUploadNewSeedWithExistingID %#ok<*DEFNU>
    global oo;
    
    % upload annotation
    s1 = RAMONSeed([10000 10000 50],eRAMONCubeOrientation.pos_z,12,13,[],.70,eRAMONAnnoStatus.locked,{'test',34});
    id = oo.createAnnotation(s1);
    
    % upload annotation with manual id
    s1 = RAMONSeed([10000 10000 50],eRAMONCubeOrientation.pos_z,12,13,id+2,.70,eRAMONAnnoStatus.locked,{'test',34});
    id2 = oo.createAnnotation(s1);
    
    % download annotation
    q = OCPQuery(eOCPQueryType.RAMONMetaOnly);
    s2 = oo.query(q.setId(id2));
    
    % check that they match!
    assertEqual(s1.position,s2.position);
    assertEqual(s1.cubeOrientation,s2.cubeOrientation);
    assertEqual(s1.parentSeed,s2.parentSeed);
    assertEqual(s1.sourceEntity,s2.sourceEntity);
    assertEqual(id2,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    keys = s1.dynamicMetadata.keys;
    assertEqual(s1.dynamicMetadata(keys{1}),s2.dynamicMetadata(keys{1}));
end


function testUploadUpdateSeed %#ok<*DEFNU>
    global oo;
    
    % upload annotation
    s1 = RAMONSeed([10000 10000 50],eRAMONCubeOrientation.pos_z,12,13,[],.70,eRAMONAnnoStatus.locked,{'test',34;'test3','tesetasdf'});
    id = oo.createAnnotation(s1);
    
    s1.setId(id);
    s1.setPosition([10002 10052 48]);
    s1.setStatus(eRAMONAnnoStatus.unprocessed);
    s1.setCubeOrientation(eRAMONCubeOrientation.neg_y);
    s1.setConfidence(.23);
    
    % update annotation
    id2 = oo.updateAnnotation(s1);
    
    % download annotation
    q = OCPQuery(eOCPQueryType.RAMONMetaOnly);
    s2 = oo.query(q.setId(id));
    
    % check that they match!
    assertEqual(id,id2);
    assertEqual(s1.position,s2.position);
    assertEqual(s1.cubeOrientation,s2.cubeOrientation);
    assertEqual(s1.parentSeed,s2.parentSeed);
    assertEqual(s1.sourceEntity,s2.sourceEntity);
    assertEqual(s1.id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    keys = s1.dynamicMetadata.keys;
    assertEqual(s1.dynamicMetadata(keys{1}),s2.dynamicMetadata(keys{1}));
    assertEqual(s1.dynamicMetadata(keys{2}),s2.dynamicMetadata(keys{2}));
end

function testUploadUpdateSeedWithNonExistantID %#ok<*DEFNU>
    global oo;
    
    % upload annotation
    s1 = RAMONSeed([10000 10000 50],eRAMONCubeOrientation.pos_z,12,13,233245,.70,eRAMONAnnoStatus.locked,{'test',34});
    
    % update annotation
    assertExceptionThrown(@() oo.updateAnnotation(s1), 'OCPNetwork:InternalServerError');
end

function testDownloadSeedThatDoesntExist %#ok<*DEFNU>
    global oo;
    
    % download annotation
    q = OCPQuery(eOCPQueryType.RAMONMetaOnly);
    q.setId(5646123);
    assertExceptionThrown(@() oo.query(q), 'OCPNetwork:InternalServerError');
    
end

%% RAMON - Synapse
function testUploadDownloadDeleteSynapseMeta %#ok<*DEFNU>
    global oo
    
    % upload annotation
    d = zeros(100,80,30);
    d(40:60,40:60,1:2) = 1;
    d(50:55,60:70,2:3) = 1;
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[1000 1000 100],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[2,34],[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[]},'testuser');
    id = oo.createAnnotation(s1);
    
    % download annotation - metaonly
    q = OCPQuery(eOCPQueryType.RAMONMetaOnly);
    q.setId(id);
    s2 = oo.query(q);
    
    assertEqual(s1.author, s2.author);
    assertEqual(s1.synapseType, s2.synapseType);
    assertEqual(s1.weight, s2.weight);
    keys = s1.segments.keys;
    for ii = 1:length(keys)
        assertEqual(s1.segments(keys{ii}), s2.segments(keys{ii}));
    end
    assertEqual(s1.seeds, s2.seeds);
    assertEqual(id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    keys = s1.dynamicMetadata.keys;
    assertEqual(s1.dynamicMetadata(keys{1}),s2.dynamicMetadata(keys{1}));
    assertEqual(s1.dynamicMetadata(keys{2}),s2.dynamicMetadata(keys{2}));
    
    % Delete
    oo.deleteAnnotation(s2.id);
    
    % See if it is gone
    assertExceptionThrown(@() oo.query(q), 'OCPNetwork:InternalServerError');
end

function testUploadDownloadDeleteSynapseCutout %#ok<*DEFNU>
    global oo
    
    % upload annotation
    d = zeros(100,80,30);
    d(40:60,40:60,1:2) = 1;
    d(50:55,60:70,2:3) = 1;
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[1000 1000 100],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],34,[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser');
    id = oo.createAnnotation(s1);
    
    % download annotation - cutout
    q = OCPQuery(eOCPQueryType.RAMONDense);
    q.setId(id);
    s2 = oo.query(q);
    
    % check that they match!
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
    
    assertEqual(s1.author, s2.author);
    assertEqual(s1.resolution, s2.resolution);
    assertEqual(s1.synapseType, s2.synapseType);
    assertEqual(s1.weight, s2.weight);
    keys = s1.segments.keys;
    for ii = 1:length(keys)
        assertEqual(s1.segments(keys{ii}), s2.segments(keys{ii}));
    end
    assertEqual(s1.seeds, s2.seeds);
    assertEqual(id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    keys = s1.dynamicMetadata.keys;
    assertEqual(s1.dynamicMetadata(keys{1}),s2.dynamicMetadata(keys{1}));
    assertEqual(s1.dynamicMetadata(keys{2}),s2.dynamicMetadata(keys{2}));
    assertEqual(s1.dynamicMetadata(keys{3}),s2.dynamicMetadata(keys{3}));
    
    % Delete
    oo.deleteAnnotation(s2.id);
    
    % See if it is gone
    assertExceptionThrown(@() oo.query(q), 'OCPNetwork:InternalServerError');
end

function testDeleteRemovesVoxels %#ok<*DEFNU>
    global oo
    
    % upload annotation
    d = ones(25,25,4);
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[7000 4000 600],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],34,[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser');
    id = oo.createAnnotation(s1);
    
    
    % download cutout to make sure there's paint
    q_anno = OCPQuery(eOCPQueryType.annoDense);
    q_anno.setCutoutArgs([7000 7025],[4000 4025],[600 604],1);
    anno = oo.query(q_anno);
    
    id_anno = unique(anno.data);    
    
    assertEqual(length(id_anno), 1);
    assertEqual(id_anno, uint32(id));
        
    % Delete
    oo.deleteAnnotation(id); 
    
    % Download and make sure there is no paint    
    anno = oo.query(q_anno);
    
    id_anno = unique(anno.data);    
    
    assertEqual(length(id_anno), 1);
    assertEqual(id_anno, uint32(0));
end


function testUploadDownloadDeleteSynapseVoxelList %#ok<*DEFNU>
    global oo
    
    % upload annotation
    clear d
    d(:,1) = 500:550;
    d(:,2) = 1500:1550;
    d(:,3) = ones(1,51)*50;
    s1 = RAMONSynapse(d,eRAMONDataFormat.voxelList,[],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[2,34],[],.64, eRAMONAnnoStatus.processed);
    id = oo.createAnnotation(s1);
    
    % download annotation - voxels
    q = OCPQuery(eOCPQueryType.RAMONVoxelList);
    q.setId(id);
    s2 = oo.query(q);
    
    % check that they match!
    unionedData = union(s1.data,s2.data,'rows');
    assertEqual(size(unionedData,1), size(s1.data,1));
    assertEqual(size(unionedData,2), size(s1.data,2));
    assertEqual(unionedData, uint32(s1.data));
    
    assertEqual(s1.xyzOffset, s2.xyzOffset);
    assertEqual(s1.author, s2.author);
    assertEqual(s1.resolution, s2.resolution);
    assertEqual(s1.synapseType, s2.synapseType);
    assertEqual(s1.weight, s2.weight);
    
    keys = s1.segments.keys;
    for ii = 1:length(keys)
        assertEqual(s1.segments(keys{ii}), s2.segments(keys{ii}));
    end
    assertEqual(s1.seeds, s2.seeds);
    assertEqual(id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    keys = s1.dynamicMetadata.keys;
    assertEqual(true,isempty(keys));
    
    % Delete
    oo.deleteAnnotation(s2.id);
    
    % See if it is gone
    assertExceptionThrown(@() oo.query(q), 'OCPNetwork:InternalServerError');
end



function testUploadNewSynapseWithExistingID %#ok<*DEFNU>
    global oo;
    
    % upload annotation
    d = zeros(100,80,30);
    d(40:60,40:60,1:2) = 1;
    d(50:55,60:70,2:3) = 1;
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[1000 1000 100],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],34,[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser');
    id = oo.createAnnotation(s1);
    
    % upload annotation with manual id
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[1000 1000 100],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],34,id+2,.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser');
    id2 = oo.createAnnotation(s1);
    
    % download annotation
    q = OCPQuery(eOCPQueryType.RAMONDense);
    s2 = oo.query(q.setId(id2));
    
    % check that they match!
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
    
    assertEqual(s1.id, s2.id);
    assertEqual(s1.author, s2.author);
    assertEqual(s1.resolution, s2.resolution);
    assertEqual(s1.synapseType, s2.synapseType);
    assertEqual(s1.weight, s2.weight);
    keys = s1.segments.keys;
    for ii = 1:length(keys)
        assertEqual(s1.segments(keys{ii}), s2.segments(keys{ii}));
    end
    assertEqual(s1.seeds, s2.seeds);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    keys = s1.dynamicMetadata.keys;
    assertEqual(s1.dynamicMetadata(keys{1}),s2.dynamicMetadata(keys{1}));
    assertEqual(s1.dynamicMetadata(keys{2}),s2.dynamicMetadata(keys{2}));
    assertEqual(s1.dynamicMetadata(keys{3}),s2.dynamicMetadata(keys{3}));
end


function testUploadUpdateSynapse %#ok<*DEFNU>
    global oo;
    
    % upload annotation% upload annotation
    d = zeros(100,80,30);
    d(40:60,40:60,1:2) = 1;
    d(50:55,60:70,2:3) = 1;
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[2,34],[],.64, eRAMONAnnoStatus.processed,{'tester',1212});
    id = oo.createAnnotation(s1);
    
    % update annotation
    s1.setId(id);
    s1.setStatus(eRAMONAnnoStatus.unprocessed);
    s1.setSeeds([1 2 3 4 56 6 42 8]);
    s1.setConfidence(.29);
    
    id2 = oo.updateAnnotation(s1);
    
    % download annotation
    q = OCPQuery(eOCPQueryType.RAMONDense);
    s2 = oo.query(q.setId(id));
    
    % check that they match!
    assertEqual(id,id2);
    
    % check that they match!
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
    
    assertEqual(id, id2);
    assertEqual(s1.author, s2.author);
    assertEqual(s1.resolution, s2.resolution);
    assertEqual(s1.synapseType, s2.synapseType);
    assertEqual(s1.weight, s2.weight);
    
    keys = s1.segments.keys;
    for ii = 1:length(keys)
        assertEqual(s1.segments(keys{ii}), s2.segments(keys{ii}));
    end
    assertEqual(s1.seeds, s2.seeds);
    assertEqual(id2,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    keys = s1.dynamicMetadata.keys;
    assertEqual(s1.dynamicMetadata(keys{1}),s2.dynamicMetadata(keys{1}));
end

function testUploadUpdateSynapseWithNonExistantID %#ok<*DEFNU>
    global oo;
    
    % upload annotation
    d = zeros(100,80,30);
    d(40:60,40:60,1:2) = 1;
    d(50:55,60:70,2:3) = 1;
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[45 54 65],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[2,34],88745,.64, eRAMONAnnoStatus.processed,{'tester',1212});
    
    % update annotation
    assertExceptionThrown(@() oo.updateAnnotation(s1), 'OCPNetwork:InternalServerError');
end

%% RAMON - Segment
function testUploadDownloadDeleteSegmentMeta %#ok<*DEFNU>
    global oo
    
    % upload annotation
    d = zeros(100,80,20);
    d(50:60,20:60,1:10) = 1;
    d(50:55,60:70,2:3) = 1;
    
    s1 = RAMONSegment(d,eRAMONDataFormat.dense, [3000 3000 20], 1, eRAMONSegmentClass.unknown,54,...
        [2 45 67], [234 67], 64, [], .256, eRAMONAnnoStatus.unprocessed,...
        {'tester',1212},'testuser');
    id = oo.createAnnotation(s1);
    
    % download annotation - metaonly
    q = OCPQuery(eOCPQueryType.RAMONMetaOnly);
    q.setId(id);
    s2 = oo.query(q);
    
    
    assertEqual(s1.author, s2.author);
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
    
    % Delete
    oo.deleteAnnotation(s2.id);
    
    % See if it is gone
    assertExceptionThrown(@() oo.query(q), 'OCPNetwork:InternalServerError');
end

function testUploadDownloadDeleteSegmentCutout %#ok<*DEFNU>
    global oo
    
    % upload annotation
    d = zeros(100,80,20);
    d(50:60,20:60,1:10) = 1;
    d(50:55,60:70,2:3) = 1;
    
    s1 = RAMONSegment(d, eRAMONDataFormat.dense,[3000 3000 20], 1, eRAMONSegmentClass.unknown,54,...
        [2 45 67], [234 67], 64, [], .256, eRAMONAnnoStatus.unprocessed,...
        {'tester',1212},'testuser');
    id = oo.createAnnotation(s1);
    
    % download annotation - metaonly
    q = OCPQuery(eOCPQueryType.RAMONDense);
    q.setId(id);
    s2 = oo.query(q);
    
    % check that they match!
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
    
    % Delete
    oo.deleteAnnotation(s2.id);
    
    % See if it is gone
    assertExceptionThrown(@() oo.query(q), 'OCPNetwork:InternalServerError');
end


function testUploadDownloadDeleteSegmentVoxelList %#ok<*DEFNU>
    global oo
    
    % upload annotation
    clear d
    d(:,1) = 500:550;
    d(:,2) = 1500:1550;
    d(:,3) = ones(1,51)*50;
    s1 = RAMONSegment(d,eRAMONDataFormat.voxelList, [3000 3000 20], 1, eRAMONSegmentClass.unknown,54,...
        [2 45 67], [234 67], 64, [], .256, eRAMONAnnoStatus.unprocessed,...
        {'tester',1212},'testuser');
    id = oo.createAnnotation(s1);
    
    % download annotation - voxels
    q = OCPQuery(eOCPQueryType.RAMONVoxelList);
    q.setId(id);
    s2 = oo.query(q);
    
    % check that they match!
    unionedData = union(s1.data,s2.data,'rows');
    assertEqual(size(unionedData,1), size(s1.data,1));
    assertEqual(size(unionedData,2), size(s1.data,2));
    assertEqual(unionedData, uint32(s1.data));
    
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
    assertEqual(s1.organelles, s2.organelles);
end

function testUploadUpdateSegment %#ok<*DEFNU>
    global oo;
    
    % upload annotation
    d = zeros(100,80,20);
    d(50:60,20:60,1:10) = 1;
    d(50:55,60:70,2:3) = 1;
    
    s1 = RAMONSegment(d,eRAMONDataFormat.dense,[3000 3000 20], 1, eRAMONSegmentClass.unknown,54,...
        [2 45 67], [234 67], 64, [], .256, eRAMONAnnoStatus.unprocessed,...
        {'tester',1212},'testuser');
    id = oo.createAnnotation(s1);
    
    % Modify
    s1.setId(id);
    s1.setNeuron(23);
    s1.setOrganelles([457 765 24 56 876 345]);
    s1.setStatus(2);
    
    % Update
    id2 = oo.updateAnnotation(s1);
    assertEqual(id,id2);
    
    % download annotation - metaonly
    q = OCPQuery(eOCPQueryType.RAMONDense);
    q.setId(id);
    s2 = oo.query(q);
    
    % check that they match!
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
    
    assertEqual(s2.neuron,23);
    assertEqual(s2.organelles,[457 765 24 56 876 345]);
    assertEqual(s2.status,eRAMONAnnoStatus(2));
end

%% RAMON - Neuron

function testUploadDownloadNeuron %#ok<*DEFNU>
    global oo;
    
    % upload annotation
    n1 = RAMONNeuron([12 34 56 776 45 34], [], .98, eRAMONAnnoStatus.ignored, {'test',34234});
    id = oo.createAnnotation(n1);
    
    % download annotation
    q = OCPQuery(eOCPQueryType.RAMONMetaOnly);
    q.setId(id);
    n2 = oo.query(q);
    
    % check that they match!
    assertEqual(n1.segments, n2.segments);
    
    assertEqual(n1.author, n2.author);
    assertEqual(id,n2.id);
    assertEqual(n1.confidence,n2.confidence);
    assertEqual(n1.status,n2.status);
    keys = n1.dynamicMetadata.keys;
    assertEqual(n1.dynamicMetadata(keys{1}),n2.dynamicMetadata(keys{1}));
    
    
    % upload annotation
    n1 = RAMONNeuron(12, [], .98, eRAMONAnnoStatus.ignored);
    id = oo.createAnnotation(n1);
    
    % download annotation
    q = OCPQuery(eOCPQueryType.RAMONMetaOnly);
    q.setId(id);
    n2 = oo.query(q);
    
    % check that they match!
    assertEqual(n1.segments, n2.segments);
    
    assertEqual(n1.author, n2.author);
    assertEqual(id,n2.id);
    assertEqual(n1.confidence,n2.confidence);
    assertEqual(n1.status,n2.status);
    keys = n1.dynamicMetadata.keys;
    assertEqual(true,isempty(keys));
end

function testUploadDownloadBlankNeuron %#ok<*DEFNU>
    global oo;
    
    % upload annotation
    n1 = RAMONNeuron();
    id = oo.createAnnotation(n1);
    
    
    % download annotation
    q = OCPQuery(eOCPQueryType.RAMONMetaOnly);
    q.setId(id);
    n2 = oo.query(q);
    
    % check that they match!
    assertEqual(n1.segments, n2.segments);
    
    assertEqual(n1.author, n2.author);
    assertEqual(id,n2.id);
    assertEqual(n1.confidence,n2.confidence);
    assertEqual(n1.status,n2.status);
    assertEqual(n1.dynamicMetadata.Count,n2.dynamicMetadata.Count);
    
    
    % upload annotation
    n1 = RAMONNeuron();
    n1.addDynamicMetadata('test','tester');
    id = oo.createAnnotation(n1);
    
    % download annotation
    q = OCPQuery(eOCPQueryType.RAMONMetaOnly);
    q.setId(id);
    n2 = oo.query(q);
    
    % check that they match!
    assertEqual(n1.segments, n2.segments);
    
    assertEqual(n1.author, n2.author);
    assertEqual(id,n2.id);
    assertEqual(n1.confidence,n2.confidence);
    assertEqual(n1.status,n2.status);
    assertEqual(n1.dynamicMetadata.Count,n2.dynamicMetadata.Count);
end

%% RAMON - Organelle

function testUploadDownloadDeleteOrganelleCutout %#ok<*DEFNU>
    global oo
    
    % upload annotation       
    d = repmat(ones(20),[1 1 20]);
    o1 = RAMONOrganelle(d,eRAMONDataFormat.dense,[4500 5400 650],1,eRAMONOrganelleClass.mitochondria, [123 345 56],...
        3,[],.263, eRAMONAnnoStatus.processed,{'tester',1212},'unit test');
    id = oo.createAnnotation(o1);
    
    % download annotation - Dense
    q = OCPQuery(eOCPQueryType.RAMONDense);
    q.setId(id);
    o2 = oo.query(q);
    
    % check that they match!
    inds1 = find(o1.data>0);
    inds2 = find(o2.data>0);
    
    % make sure every labled pixel in o1 is labled in o2 via db coords
    [y,x,z] = ind2sub(size(o1.data),inds1);
    g1 = o1.local2Global([x,y,z]);
    l1 = o2.global2Local(g1);
    indsCheck = sub2ind(size(o2.data),l1(:,2),l1(:,1),l1(:,3));
    assertEqual(o2.data(indsCheck), repmat(o2.id,length(indsCheck),1));

    % make sure every labled pixel in o2 is labled in o1 via db coords
    [y,x,z] = ind2sub(size(o2.data),inds2);
    g2 = o2.local2Global([x,y,z]);
    l2 = o1.global2Local(g2);
    indsCheck = sub2ind(size(o1.data),l2(:,2),l2(:,1),l2(:,3));
    assertEqual(o1.data(indsCheck), ones(length(indsCheck),1));
    

    assertEqual(o2.resolution, 1);
    assertEqual(o2.class, eRAMONOrganelleClass.mitochondria);    
    assertEqual(o2.seeds, [123 345 56]);    
    assertEqual(o2.parentSeed, 3);    
    assertEqual(o2.id,id);    
    assertEqual(o2.confidence,.263);    
    assertEqual(o2.status,eRAMONAnnoStatus.processed);
    assertEqual(o2.dynamicMetadata('tester'),1212);  
    assertEqual(o2.author, 'unit test');
    
    % Delete
    oo.deleteAnnotation(o2.id);
    
    % See if it is gone
    assertExceptionThrown(@() oo.query(q), 'OCPNetwork:InternalServerError');
end


function testUploadDownloadDeleteOrganelleVoxelList %#ok<*DEFNU>
    global oo
    
    % upload annotation  
    clear d
    d(:,1) = 500:550;
    d(:,2) = 1500:1550;
    d(:,3) = ones(1,51)*50;
    o1 = RAMONOrganelle(d,eRAMONDataFormat.voxelList,[4500 5400 650],1,eRAMONOrganelleClass.mitochondria, [123 345 56],...
        3,[],.263, eRAMONAnnoStatus.processed,{'tester',1212},'unit test');
    id = oo.createAnnotation(o1);
    
    % download annotation - Dense
    q = OCPQuery(eOCPQueryType.RAMONVoxelList);
    q.setId(id);
    o2 = oo.query(q);
    
   % check that they match!
    unionedData = union(o1.data,o2.data,'rows');
    assertEqual(size(unionedData,1), size(o1.data,1));
    assertEqual(size(unionedData,2), size(o1.data,2));
    assertEqual(unionedData, uint32(o1.data));

    assertEqual(o2.resolution, 1);
    assertEqual(o2.class, eRAMONOrganelleClass.mitochondria);    
    assertEqual(o2.seeds, [123 345 56]);    
    assertEqual(o2.parentSeed, 3);    
    assertEqual(o2.id,id);    
    assertEqual(o2.confidence,.263);    
    assertEqual(o2.status,eRAMONAnnoStatus.processed);
    assertEqual(o2.dynamicMetadata('tester'),1212);  
    assertEqual(o2.author, 'unit test');
    
    % Delete
    oo.deleteAnnotation(o2.id);
    
    % See if it is gone
    assertExceptionThrown(@() oo.query(q), 'OCPNetwork:InternalServerError');
end


%% Volume Cutout - Image DB
function testImageVolumeCutout
    global oo
    
    q = OCPQuery(eOCPQueryType.imageDense);
    q.setCutoutArgs(4000,4250,5000,5250,102,106,1);
    cutout = oo.query(q);
    
    load(fullfile(fileparts(which('cajal3d')),'test','matlab','api','data','cubeKasthuri.mat'));
    assertEqual(cutout.data,savedCube.data);
    assertEqual(cutout.resolution,savedCube.resolution);
    assertEqual(cutout.xyzOffset,savedCube.xyzOffset);
end

%% Volume Cutout - Annotation DB
function testAnnotationVolumeCutout
    global oo
    
    q = OCPQuery(eOCPQueryType.annoDense);
    q.setCutoutArgs(800,1400,800,1400,98,105,1);
    cutout = oo.query(q);
    
    load(fullfile(fileparts(which('cajal3d')),'test','matlab','api','data','volume_cutout_anno.mat'));
    cd1 = cutout.data;
    cd2 = cutout.data;
    cd1(cd1 > 0) = 1;
    cd2(cd2 > 0) = 1;
    assertEqual(cd1,cd2);
    assertEqual(cutout.resolution,savedCutout.resolution);
    assertEqual(cutout.xyzOffset,savedCutout.xyzOffset);
end

%% Image Slice - Image DB
function testImageSliceCutout
    global oo
    
    % Failed Next    
    slice = oo.nextSlice();
    assertEqual(slice,[]);
    
    % Slice Query
    q = OCPQuery(eOCPQueryType.imageSlice);
    q.setSliceArgs(eOCPSlicePlane.xy,4000,4250,5000,5250,102,1);
    slice = oo.query(q);
    
    load(fullfile(fileparts(which('cajal3d')),'test','matlab','api','data','cubeKasthuri.mat'));
    assertEqual(slice,savedCube.data(:,:,1));
    
    % Next
    slice = oo.nextSlice();
    assertEqual(slice,savedCube.data(:,:,2));
    slice = oo.nextSlice();
    assertEqual(slice,savedCube.data(:,:,3));
    
    % Previous
    slice = oo.previousSlice();
    assertEqual(slice,savedCube.data(:,:,2));
    slice = oo.previousSlice();
    assertEqual(slice,savedCube.data(:,:,1));
    
    % xz
    q = OCPQuery(eOCPQueryType.imageSlice);
    q.setSliceArgs(eOCPSlicePlane.xz,4000,4250,102,106,5150,1);
    slice = oo.query(q);
    
    % TODO: Server size resize function does not scale in z uniformly. 
    % Temporarily testing against saved snapshot.
    %     % Must scale data in Z to match server behavior for slice rendering
    %     cutout_slice = [];
    %     cutout_size = size(savedCube);
    %     for ii = 1:cutout_size(3)
    %         for jj = 1:oo.imageInfo.DATASET.ZSCALE(1) 
    %             cutout_slice = cat(1,cutout_slice,savedCube.data(150,:,ii));
    %         end
    %     end
     
    load(fullfile(fileparts(which('cajal3d')),'test','matlab','api','data','kasthuri_slice_xz.mat'));
    assertEqual(slice,cutout_slice);      
    
    % yz
    q = OCPQuery(eOCPQueryType.imageSlice);
    q.setSliceArgs(eOCPSlicePlane.yz,5000,5250,102,106,4150,1);
    slice = oo.query(q);    
    load(fullfile(fileparts(which('cajal3d')),'test','matlab','api','data','kasthuri_slice_yz.mat'));
    assertEqual(slice,cutout_slice);
end


%% Annotation Slice Cutouts
function testAnnotationSlice
    global oo
    
    %Use to reset db if needed
%     d = zeros(100,80,30);
%     d(40:60,40:60,1:2) = 1;
%     d(50:55,60:70,2:3) = 1;
%     d(40:70,50:65,2:5) = 1;
% 
%     s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[2200 2200 200],1,eRAMONSynapseType.excitatory, 100,...
%         [1,2;4,0],34,[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser');
%     oo.createAnnotation(s1);
    
    % xy
    q = OCPQuery(eOCPQueryType.annoSlice);
    q.setSliceArgs(eOCPSlicePlane.xy,2200,2400,2200,2400,201,1);
    slice = oo.query(q);
    
    load(fullfile(fileparts(which('cajal3d')),'test','matlab','api','data','slice_anno_xy.mat'));
    
    slice = rgb2gray(slice);
    savedSlice = rgb2gray(savedSlice); 
    inds1 = find(slice~=0);
    inds2 = find(savedSlice~=0);
    
    assertEqual(inds1,inds2);
    
    % xz
    q = OCPQuery(eOCPQueryType.annoSlice);
    q.setSliceArgs(eOCPSlicePlane.yz,2200,2400,180,280,2255,1);
    slice = oo.query(q);
    
    load(fullfile(fileparts(which('cajal3d')),'test','matlab','api','data','slice_anno_xz.mat'));
    slice = rgb2gray(slice);
    savedSlice = rgb2gray(savedSlice); 
    inds1 = find(slice~=0);
    inds2 = find(savedSlice~=0);    
    assertEqual(inds1,inds2);
    
    % yz
    q = OCPQuery(eOCPQueryType.annoSlice);
    q.setSliceArgs(eOCPSlicePlane.yz,2100,2400,180,280,2255,1);
    slice = oo.query(q);
    
    load(fullfile(fileparts(which('cajal3d')),'test','matlab','api','data','slice_anno_yz.mat'));
    slice = rgb2gray(slice);
    savedSlice = rgb2gray(savedSlice); 
    inds1 = find(slice~=0);
    inds2 = find(savedSlice~=0);
    assertEqual(inds1,inds2);
end

%% Overlay Slice Cutouts
function testOverlaySlice
    global oo
    % NOTE THIS IS A BAD UNIT TEST BUT NOT SURE WHAT ELSE TO DO AT THE
    % MOMEMNT.  Basically just checking for runtime errors
    
    d = zeros(100,80,3);
    d(40:60,40:60,1:2) = 1;
    d(50:55,60:70,2:3) = 1;
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[5000 5000 1000],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[2,34],[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[]},'testuser');
    oo.createAnnotation(s1);
    
    % xy
    q = OCPQuery(eOCPQueryType.overlaySlice);
    q.setSliceArgs(eOCPSlicePlane.xy,4800,5400,4800,5400,1001,1);
    slice = oo.query(q);
    %load(fullfile(fileparts(which('cajal3d')),'test','matlab','api','data','slice_overlay_xy.mat'));
    %slice = im2bw(slice,.05);
    %savedSlice = im2bw(savedSlice,.05);
    %assertEqual(slice,savedSlice);
    
    % xz
    q = OCPQuery(eOCPQueryType.overlaySlice);
    q.setSliceArgs(eOCPSlicePlane.xz,4800,5400,995,1010,5050,1);
    slice = oo.query(q);
    
    %load(fullfile(fileparts(which('cajal3d')),'test','matlab','api','data','slice_overlay_xz.mat'));
    %slice = im2bw(slice,.05);
    %savedSlice = im2bw(savedSlice,.05);
    %assertEqual(slice,savedSlice);
    
    
    % yz
    q = OCPQuery(eOCPQueryType.overlaySlice);
    q.setSliceArgs(eOCPSlicePlane.yz,4800,5400,995,1010,5050,1);
    slice = oo.query(q);
    
    %load(fullfile(fileparts(which('cajal3d')),'test','matlab','api','data','slice_overlay_yz.mat'));
    %slice = im2bw(slice,.05);
    %savedSlice = im2bw(savedSlice,.05);
    %assertEqual(slice,savedSlice);
end


%% Overlay Slice with alpha
function testOverlaySliceAlpha
    global oo
    
    d = zeros(100,80,3);
    d(40:60,40:60,1:2) = 1;
    d(50:55,60:70,2:3) = 1;
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[5000 5000 1000],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[2,34],[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[]},'testuser');
    oo.createAnnotation(s1);
    
    % default
    q = OCPQuery(eOCPQueryType.overlaySlice);
    q.setSliceArgs(eOCPSlicePlane.xy,4800,5400,4800,5400,1001,1);
    sliceDefault = oo.query(q);
    
    % 1
    q.setOverlayAlpha(1);
    slice1 = oo.query(q);
    assertEqual(sliceDefault,slice1);
    
    % .5
    q.setOverlayAlpha(.5);
    slice_5 = oo.query(q);
    matches = slice_5==slice1;
    ind = find(matches==0); %#ok<EFIND>
    assertFalse(isempty(ind));
    
    % 0
    q.setOverlayAlpha(0.0);
    slice0 = oo.query(q);
  
    q = OCPQuery(eOCPQueryType.imageSlice);
    q.setSliceArgs(eOCPSlicePlane.xy,4800,5400,4800,5400,1001,1);
    
    slice_img = oo.query(q);    
    assertEqual(slice0,repmat(slice_img,[1,1,3]));    
end

%% Id Predicate Query

function testIDPredicateQuery
    global oo;
    
    % Get existing IDs
    q = OCPQuery(eOCPQueryType.RAMONIdList);
    q.addIdListPredicate(eOCPPredicate.type,eRAMONAnnoType.synapse);
    q.addIdListPredicate(eOCPPredicate.status,eRAMONAnnoStatus.unprocessed);
    
    ids1 = oo.query(q);
    
    % upload annotation
    d = zeros(100,80,30);
    d(40:60,40:60,1:2) = 1;
    d(50:55,60:70,2:3) = 1;
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[1000 1000 100],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[2,34],[],.64, eRAMONAnnoStatus.unprocessed,{'tester',1212},'testuser');
    NewId = oo.createAnnotation(s1);
    
    
    % Get updated IDs
    ids2 = oo.query(q);
    
    assertEqual(length(ids1) + 1, length(ids2));
    assertEqual(uint32(NewId), ids2(end));
    
    % delete and see if its gone
    oo.deleteAnnotation(ids2(end));
    
    % Get updated IDs
    ids3 = oo.query(q);
    
    assertEqual(ismember(ids2(end),ids3), false);
    
    
    % Test greater than confidence
    q.addIdListPredicate(eOCPPredicate.confidence_gt,.9);
    
    ids1 = oo.query(q);
    
    % upload annotation
    d = zeros(100,80,30);
    d(40:60,40:60,1:2) = 1;
    d(50:55,60:70,2:3) = 1;
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[1000 1000 100],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[2,34],[],.95, eRAMONAnnoStatus.unprocessed,{'tester',1212},'testuser');
    NewId = oo.createAnnotation(s1);    
    
    % Get updated IDs
    ids2 = oo.query(q);
    
    assertEqual(length(ids1) + 1, length(ids2));
    assertEqual(uint32(NewId), ids2(end));
    
    % Test less than confidence
    q = OCPQuery(eOCPQueryType.RAMONIdList);
    q.addIdListPredicate(eOCPPredicate.confidence_lt,.05);
    
    ids1 = oo.query(q);
    
    % upload annotation
    d = zeros(100,80,30);
    d(40:60,40:60,1:2) = 1;
    d(50:55,60:70,2:3) = 1;
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[1000 1000 100],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[2,34],[],.01, eRAMONAnnoStatus.unprocessed,{'tester',1212},'testuser');
    NewId = oo.createAnnotation(s1);    
    
    % Get updated IDs
    ids2 = oo.query(q);
    
    assertEqual(length(ids1) + 1, length(ids2));
    assertEqual(uint32(NewId), ids2(end));
    
    
    
    % Query for everything
    q = OCPQuery(eOCPQueryType.RAMONIdList);
    % Get all IDs
    ids4 = oo.query(q);
    
    assertEqual(sum(ismember(ids3,ids4)) == length(ids3), true);
    assertEqual(length(ids3) < length(ids4), true);
end

function testIDPredicateQueryWithLimit
    global oo;
    
    % Get existing IDs
    q = OCPQuery(eOCPQueryType.RAMONIdList);
    q.addIdListPredicate(eOCPPredicate.type,eRAMONAnnoType.synapse);
    q.addIdListPredicate(eOCPPredicate.status,eRAMONAnnoStatus.unprocessed);
        
    % upload annotation
    d = zeros(100,80,30);
    d(40:60,40:60,1:2) = 1;
    d(50:55,60:70,2:3) = 1;
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[1000 1000 100],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[2,34],[],.64, eRAMONAnnoStatus.unprocessed,{'tester',1212},'testuser');
    oo.createAnnotation(s1);
    
    
    % Get updated IDs
    ids2 = oo.query(q);
    
    % Limit to 20 objects
    assertExceptionThrown(@() q.setIdListLimit(0), 'MATLAB:expectedPositive');
    assertExceptionThrown(@() q.setIdListLimit(1.2), 'MATLAB:expectedInteger');
    q.setIdListLimit(20);
    
    % Get updated limited IDs
    ids3 = oo.query(q);
    
    assertEqual(length(ids3), 20);
    assertEqual(ids2(1:20), ids3);     
end

function testIDqueryFromCutout
    
    global oo;
    
    % Get existing IDs
    q = OCPQuery(eOCPQueryType.RAMONIdList);
    q.addIdListPredicate(eOCPPredicate.type,eRAMONAnnoType.synapse);
    q.addIdListPredicate(eOCPPredicate.status,eRAMONAnnoStatus.unprocessed);
    q.setCutoutArgs([1800 2800],[1800 2800],[400 900],1);
    
    ids = oo.query(q);
    
    % upload annotation
    d = zeros(100,80,30);
    d(40:60,40:60,1:2) = 1;
    d(50:55,60:70,2:3) = 1;
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[2000 2000 600],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[2,34],[],.64, eRAMONAnnoStatus.unprocessed,{'tester',1212},'testuser');
    NewId = oo.createAnnotation(s1);
    
    
    % Get updated IDs
    ids2 = oo.query(q);
    
    assertEqual(uint32(NewId), ids2(end));
    
    
    % Get id in diff region.  NewID should not be in that set
    q.setCutoutArgs([800 1300],[800 1800],[100 200],1);
    ids3 = oo.query(q);
    
    assertEqual(sum(double(ismember(uint32(NewId), ids3))), 0);
    
    % Query for everything
    q = OCPQuery(eOCPQueryType.RAMONIdList);
    q.setCutoutArgs([1800 2800],[1800 2800],[400 900],1);
    % Get all IDs
    ids4 = oo.query(q);
    
    assertEqual(ismember(ids2,ids4), true);
    
    % change status so synapse disappears on re-run of test
    s1.setStatus(eRAMONAnnoStatus.processed);
    s1.setId(NewId);
    oo.updateAnnotation(s1);
    
end

%% Bounding Box Query

function testBoundingBoxQuery %#ok<*DEFNU>
    global oo
    
    % upload annotation
    d = ones(100,80,25);
    s1 = RAMONSegment(d, eRAMONDataFormat.dense,[3000 3000 60], 1, eRAMONSegmentClass.unknown,54,...
        [2 45 67], [234 67], 64, [], .256, eRAMONAnnoStatus.unprocessed,...
        {'tester',1212},'testuser');
    id = oo.createAnnotation(s1);
    
    % download annotation with bounding box
    q = OCPQuery(eOCPQueryType.RAMONBoundingBox);
    q.setId(id);
    s2 = oo.query(q);
    
    
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
    
    assertEqual(s2.dataFormat,eRAMONDataFormat.boundingBox);
    assertTrue(s2.xyzOffset(1) < s1.xyzOffset(1));
    assertTrue(s2.xyzOffset(2) < s1.xyzOffset(2));
    assertTrue(s2.xyzOffset(3) < s1.xyzOffset(3));
    assertTrue(s2.xyzOffset(1) + s2.data(1) > s1.xyzOffset(1) + 100);
    assertTrue(s2.xyzOffset(2) + s2.data(2) > s1.xyzOffset(2) + 80);
    assertTrue(s2.xyzOffset(3) + s2.data(3) > s1.xyzOffset(3) + 25);
end

%% Test cutout to make sure it is the only thing in the volume returned
function testCutoutReturnsOneThingProperly %#ok<*DEFNU>
    global oo
    
    % upload annotation
    d = zeros(100,80,20);
    d(50:60,20:60,1:10) = 1;
    d(50:55,60:70,2:3) = 1;
    
    s1 = RAMONSegment(d, eRAMONDataFormat.dense,[3000 3000 1200], 1, eRAMONSegmentClass.unknown,54,...
        [2 45 67], [234 67], 64, [], .256, eRAMONAnnoStatus.unprocessed,...
        {'tester',1212},'testuser');
    id1 = oo.createAnnotation(s1);
    
    s2 = RAMONSegment(d, eRAMONDataFormat.dense,[3025 3025 1200], 1, eRAMONSegmentClass.unknown,54,...
        [2 45 67], [234 67], 64, [], .256, eRAMONAnnoStatus.unprocessed,...
        {'tester',1212},'testuser');
    id2 = oo.createAnnotation(s2);
    
    % Get cutout with both
    q = OCPQuery(eOCPQueryType.annoDense);
    q.setCutoutArgs([2950 3150], [2950 3150], [1199 1225],1);
    cutout = oo.query(q);
    
    inds = unique(cutout.data);
    assertEqual(inds(2), uint32(id1));
    assertEqual(inds(3), uint32(id2));
    
    % download annotation - should only be 1 thing now
    q = OCPQuery(eOCPQueryType.RAMONDense);
    q.setId(id1);
    s3 = oo.query(q);
    
    inds = unique(s3.data);
    assertEqual(length(inds), 2);
    assertEqual(inds(2), id1);
    
    
    q = OCPQuery(eOCPQueryType.RAMONDense);
    q.setId(id2);
    s4 = oo.query(q);
    
    inds = unique(s4.data);
    assertEqual(length(inds), 2);
    assertEqual(inds(2), id2);
    
    
    % Delete
    oo.deleteAnnotation(id1);
    oo.deleteAnnotation(id2);
end

%% Test to make sure voxellist can't be restricted to cutout
function testVoxelListNoCutoutRestriction %#ok<*DEFNU>
    global oo
    
    % upload annotation
    d = zeros(100,80,20);
    d(50:60,20:60,1:10) = 1;
    d(50:55,60:70,2:3) = 1;
    
    s1 = RAMONSegment(d, eRAMONDataFormat.dense,[3000 3000 1350], 1, eRAMONSegmentClass.unknown,54,...
        [2 45 67], [234 67], 64, [], .256, eRAMONAnnoStatus.unprocessed,...
        {'tester',1212},'testuser');
    id1 = oo.createAnnotation(s1);
    
    % Get cutout with both
    q = OCPQuery(eOCPQueryType.RAMONVoxelList,id1);
    q.setCutoutArgs([2950 3150], [2950 3150], [1199 1225],1);
    cutout = oo.query(q);
    
    assertTrue(length(cutout.data) > 100);
    assertEqual(cutout.dataFormat, eRAMONDataFormat.voxelList);
    
    % Delete
    oo.deleteAnnotation(id1);
end

%% Test object query restricted to a cutout
function testCutoutRestriction %#ok<*DEFNU>
    global oo
    
    % upload annotation
    d = zeros(100,80,20);
    d(50:60,20:60,1:10) = 1;
    d(50:55,60:70,2:3) = 1;
    
    s1 = RAMONSegment(d, eRAMONDataFormat.dense,[3000 3000 1350], 1, eRAMONSegmentClass.unknown,54,...
        [2 45 67], [234 67], 64, [], .256, eRAMONAnnoStatus.unprocessed,...
        {'tester',1212},'testuser');
    id1 = oo.createAnnotation(s1);
    
    % Get obj without cutout restriction
    q = OCPQuery(eOCPQueryType.RAMONDense,id1);
    cutout = oo.query(q);
    
    assertTrue(length(cutout.data(cutout.data > 0)) > 100);
    assertEqual(cutout.dataFormat, eRAMONDataFormat.dense);
    
    % Cutout restriction
    q.setCutoutArgs([2950 3150], [2950 3150], [1199 1225],1);
    cutout = oo.query(q);
    assertTrue(isempty(cutout.data(cutout.data > 0)));
    assertEqual(cutout.dataFormat, eRAMONDataFormat.dense);
    
    % Delete
    oo.deleteAnnotation(id1);
end
%% Test to make sure dense cutout and RAMON dense return the same thing
function testCutoutvsDense %#ok<*DEFNU>
    global oo
    
    % upload annotation
    d = zeros(100,80,20);
    d(50:60,20:60,1:10) = 1;
    d(50:55,60:70,2:3) = 1;
    
    s1 = RAMONSegment(d, eRAMONDataFormat.dense,[3000 3000 1380], 1, eRAMONSegmentClass.unknown,54,...
        [2 45 67], [234 67], 64, [], .256, eRAMONAnnoStatus.unprocessed,...
        {'tester',1212},'testuser');
    id1 = oo.createAnnotation(s1);
    
    % Get obj without cutout restriction
    q = OCPQuery(eOCPQueryType.RAMONDense,id1);
    denseNoRestrict = oo.query(q);
    
    % check it matches
    inds1 = find(s1.data>0);
    inds2 = find(denseNoRestrict.data>0);
    
    % make sure every labled pixel in s1 is labled in denseNoRestrict via db coords
    for ii = 1:length(inds1)
        [y,x,z] = ind2sub(size(s1.data),inds1(ii));
        g1 = s1.local2Global([x,y,z]);
        l1 = denseNoRestrict.global2Local(g1);
        assertEqual(denseNoRestrict.data(l1(2),l1(1),l1(3)), denseNoRestrict.id);
    end
    
    % make sure every labled pixel in denseNoRestrict is labled in s1 via db coords
    for ii = 1:length(inds2)
        [y,x,z] = ind2sub(size(denseNoRestrict.data),inds2(ii));
        g2 = denseNoRestrict.local2Global([x,y,z]);
        l2 = s1.global2Local(g2);
        assertEqual(s1.data(l2(2),l2(1),l2(3)),1);
    end
    
    
    % Get obj with cutout restriction
    q.setCutoutArgs([3000 3100],[3000 3100],[1380 1410],1);
    denseRestrict = oo.query(q);
    
    % check it matches
    inds1 = find(s1.data>0);
    inds2 = find(denseRestrict.data>0);
    
    % make sure every labled pixel in s1 is labled in denseRestrict via db coords
    for ii = 1:length(inds1)
        [y,x,z] = ind2sub(size(s1.data),inds1(ii));
        g1 = s1.local2Global([x,y,z]);
        l1 = denseRestrict.global2Local(g1);
        assertEqual(denseRestrict.data(l1(2),l1(1),l1(3)), denseRestrict.id);
    end
    
    % make sure every labled pixel in denseRestrict is labled in s1 via db coords
    for ii = 1:length(inds2)
        [y,x,z] = ind2sub(size(denseRestrict.data),inds2(ii));
        g2 = denseRestrict.local2Global([x,y,z]);
        l2 = s1.global2Local(g2);
        assertEqual(s1.data(l2(2),l2(1),l2(3)),1);
    end
    
    % Straight annodb cutout
    q = OCPQuery(eOCPQueryType.annoDense);
    q.setCutoutArgs([3000 3100],[3000 3100],[1380 1410],1);
    annoCutout = oo.query(q);
    
    % check it matches
    inds1 = find(s1.data>0);
    inds2 = find(annoCutout.data>0);
    
    % make sure every labled pixel in s1 is labled in annoCutout via db coords
    for ii = 1:length(inds1)
        [y,x,z] = ind2sub(size(s1.data),inds1(ii));
        g1 = s1.local2Global([x,y,z]);
        l1 = annoCutout.global2Local(g1);
        assertEqual(annoCutout.data(l1(2),l1(1),l1(3)), uint32(denseRestrict.id));
    end
    
    % make sure every labled pixel in annoCutout is labled in s1 via db coords
    for ii = 1:length(inds2)
        [y,x,z] = ind2sub(size(annoCutout.data),inds2(ii));
        g2 = annoCutout.local2Global([x,y,z]);
        l2 = s1.global2Local(g2);
        assertEqual(s1.data(l2(2),l2(1),l2(3)),1);
    end
end


%% Test to make sure dense cutout and RAMON dense return the same thing with a single slice anno
function testCutoutvsDenseSingleSlice %#ok<*DEFNU>
    global oo
    
    % upload annotation
    d = zeros(100,80);
    d(50:60,20:60) = 1;
    
    s1 = RAMONSegment(d, eRAMONDataFormat.dense,[4000 4000 1420], 1, eRAMONSegmentClass.unknown,54,...
        [2 45 67], [234 67], 64, [], .256, eRAMONAnnoStatus.unprocessed,...
        {'tester',1212},'testuser');
    id1 = oo.createAnnotation(s1);
    
    % Get obj without cutout restriction
    q = OCPQuery(eOCPQueryType.RAMONDense,id1);
    denseNoRestrict = oo.query(q);
    
    % check it matches
    inds1 = find(s1.data>0);
    inds2 = find(denseNoRestrict.data>0);
    
    % make sure every labled pixel in s1 is labled in denseNoRestrict via db coords
    for ii = 1:length(inds1)
        [y,x,z] = ind2sub(size(s1.data),inds1(ii));
        g1 = s1.local2Global([x,y,z]);
        l1 = denseNoRestrict.global2Local(g1);
        assertEqual(denseNoRestrict.data(l1(2),l1(1),l1(3)), denseNoRestrict.id);
    end
    
    % make sure every labled pixel in denseNoRestrict is labled in s1 via db coords
    for ii = 1:length(inds2)
        [y,x,z] = ind2sub(size(denseNoRestrict.data),inds2(ii));
        g2 = denseNoRestrict.local2Global([x,y,z]);
        l2 = s1.global2Local(g2);
        assertEqual(s1.data(l2(2),l2(1),l2(3)),1);
    end
    
    
    % Get obj with cutout restriction
    q.setCutoutArgs([4000 4100],[4000 4100],[1420 1460],1);
    denseRestrict = oo.query(q);
    
    % check it matches
    inds1 = find(s1.data>0);
    inds2 = find(denseRestrict.data>0);
    
    % make sure every labled pixel in s1 is labled in denseRestrict via db coords
    for ii = 1:length(inds1)
        [y,x,z] = ind2sub(size(s1.data),inds1(ii));
        g1 = s1.local2Global([x,y,z]);
        l1 = denseRestrict.global2Local(g1);
        assertEqual(denseRestrict.data(l1(2),l1(1),l1(3)), denseRestrict.id);
    end
    
    % make sure every labled pixel in denseRestrict is labled in s1 via db coords
    for ii = 1:length(inds2)
        [y,x,z] = ind2sub(size(denseRestrict.data),inds2(ii));
        g2 = denseRestrict.local2Global([x,y,z]);
        l2 = s1.global2Local(g2);
        assertEqual(s1.data(l2(2),l2(1),l2(3)),1);
    end
    
    % Straight annodb cutout
    q = OCPQuery(eOCPQueryType.annoDense);
    q.setCutoutArgs([4000 4100],[4000 4100],[1420 1460],1);
    annoCutout = oo.query(q);
    
    % check it matches
    inds1 = find(s1.data>0);
    inds2 = find(annoCutout.data>0);
    
    % make sure every labled pixel in s1 is labled in annoCutout via db coords
    for ii = 1:length(inds1)
        [y,x,z] = ind2sub(size(s1.data),inds1(ii));
        g1 = s1.local2Global([x,y,z]);
        l1 = annoCutout.global2Local(g1);
        assertEqual(annoCutout.data(l1(2),l1(1),l1(3)), uint32(denseRestrict.id));
    end
    
    % make sure every labled pixel in annoCutout is labled in s1 via db coords
    for ii = 1:length(inds2)
        [y,x,z] = ind2sub(size(annoCutout.data),inds2(ii));
        g2 = annoCutout.local2Global([x,y,z]);
        l2 = s1.global2Local(g2);
        assertEqual(s1.data(l2(2),l2(1),l2(3)),1);
    end
end

%% Id XYZ Query

function testIDByXYZQuery %#ok<*DEFNU>
    global oo
    
    % upload annotation
    d = ones(100,80,25);
    s1 = RAMONSegment(d, eRAMONDataFormat.dense,[3000 3000 150], 1, eRAMONSegmentClass.unknown,54,...
        [2 45 67], [234 67], 64, [], .256, eRAMONAnnoStatus.unprocessed,...
        {'tester',1212},'testuser');
    id = oo.createAnnotation(s1);
    
    % find ID
    q = OCPQuery(eOCPQueryType.voxelId);
    q.setXyzCoord([3010 3010 155]);
    id2 = oo.query(q);
    
    assertEqual(id,id2);
    
end


%% Test Conflict Options
function testConflictWriteOptions %#ok<*DEFNU>
    global oo
    
    % Get initial ID
    qId = OCPQuery(eOCPQueryType.voxelId);
    qId.setXyzCoord([4010 4010 1450]);
    idOrig = oo.query(qId);
    
    
    % upload annotation
    d = ones(100,100);
    
    s1 = RAMONSegment(d, eRAMONDataFormat.dense,[4000 4000 1450], 1, eRAMONSegmentClass.unknown,54,...
        [2 45 67], [234 67], 64, [], .256, eRAMONAnnoStatus.unprocessed,...
        {'tester',1212},'testuser');
    idDefault = oo.createAnnotation(s1);
    
    % make sure new ID
    idDefaultQuery = oo.query(qId);
    assertFalse(idOrig == idDefaultQuery);
    assertEqual(idDefault,idDefaultQuery);
    
    
    % upload bigger anno with perserve
    d = ones(150,150);
    s1 = RAMONSegment(d, eRAMONDataFormat.dense,[4000 4000 1450], 1, eRAMONSegmentClass.unknown,54,...
        [2 45 67], [234 67], 64, [], .256, eRAMONAnnoStatus.unprocessed,...
        {'tester',1212},'testuser');
    idPreserve = oo.createAnnotation(s1,eOCPConflictOption.preserve);

    
    qIdOutside = OCPQuery(eOCPQueryType.voxelId);
    qIdOutside.setXyzCoord([4115 4115 1450]);
    idPreserveQueryOutside = oo.query(qIdOutside);
    
    % make sure it didn't over write
    idPreserveQueryMiddle = oo.query(qId);
    assertEqual(idPreserveQueryMiddle,idDefaultQuery);
    assertEqual(idPreserveQueryOutside,idPreserve);
    
    
    % test exception
    d = ones(100,100);
    s1 = RAMONSegment(d, eRAMONDataFormat.dense,[4000 4000 1450], 1, eRAMONSegmentClass.unknown,54,...
        [2 45 67], [234 67], 64, [], .256, eRAMONAnnoStatus.unprocessed,...
        {'tester',1212},'testuser');
    idException = oo.createAnnotation(s1,eOCPConflictOption.exception);
    
    % make sure it didn't over write
    idExceptionQuery = oo.query(qId);
    assertEqual(idExceptionQuery,idDefaultQuery);
    
    % get object and make sure they match
    q = OCPQuery(eOCPQueryType.RAMONDense,idException);
    exceptionObj = oo.query(q);
    
    % check it matches
    inds1 = find(s1.data>0);
    inds2 = find(exceptionObj.data>0);
    
    % make sure every labled pixel in s1 is labled in denseRestrict via db coords
    for ii = 1:length(inds1)
        [y,x,z] = ind2sub(size(s1.data),inds1(ii));
        g1 = s1.local2Global([x,y,z]);
        l1 = exceptionObj.global2Local(g1);
        assertEqual(exceptionObj.data(l1(2),l1(1),l1(3)), exceptionObj.id);
    end
    
    % make sure every labled pixel in exceptionObj is labled in s1 via db coords
    for ii = 1:length(inds2)
        [y,x,z] = ind2sub(size(exceptionObj.data),inds2(ii));
        g2 = exceptionObj.local2Global([x,y,z]);
        l2 = s1.global2Local(g2);
        assertEqual(s1.data(l2(2),l2(1),l2(3)),1);
    end
    
    
    % test explicit overwrite
    d = ones(100,100);
    s1 = RAMONSegment(d, eRAMONDataFormat.dense,[4000 4000 1450], 1, eRAMONSegmentClass.unknown,54,...
        [2 45 67], [234 67], 64, [], .256, eRAMONAnnoStatus.unprocessed,...
        {'tester',1212},'testuser');
    idOverwrite = oo.createAnnotation(s1,eOCPConflictOption.overwrite);
    
    % make sure new ID
    idOverwriteQuery = oo.query(qId);
    assertFalse(idExceptionQuery == idOverwrite);
    assertEqual(idOverwrite,idOverwriteQuery);
    
    % clear out anno
    oo.deleteAnnotation(idDefault);
    oo.deleteAnnotation(idPreserve);
    oo.deleteAnnotation(idException);
    oo.deleteAnnotation(idOverwrite);
end

%% Test Batch upload and downloads
function testBatchMode %#ok<*DEFNU>
    global oo
    
    % Build complex batch containing cutouts, voxel lists, and things that
    % should be chunked.
    
    % Set params for test
    orig_max_anno_size = oo.maxAnnoSize;
    oo.setMaxAnnoSize(20000); 
    orig_batch_size = oo.batchSize;
    oo.setBatchSize(5);
    
    % cutouts
    d = ones(20,20,4);
    for ii = 1:10
        sa{ii} = RAMONSynapse(d,eRAMONDataFormat.dense,[1000 1000 300+ii*5],1,eRAMONSynapseType.excitatory, 100,...
            [1,2;4,0],ii,[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser'); %#ok<AGROW>
    end
    
    % voxel list
    clear d
    d(:,1) = 20:50;
    d(:,2) = 30:60;
    d(:,3) = ones(1,31)*50;
    for ii = 11:20        
        d(:,3) = ones(1,31)*50+ii;
        sa{ii} = RAMONSynapse(d,eRAMONDataFormat.voxelList,[],1,eRAMONSynapseType.excitatory, 100,...
            [1,2;4,0],34,[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser'); %#ok<AGROW>
    end
    
    % BIG voxel list
    clear d
    d = ones(100,100,6);
    stemp = RAMONSynapse(d,eRAMONDataFormat.dense,[500 1000 200],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],34,[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser');
    stemp.toVoxelList;
    sa{21} = stemp;
    
    clear d
    d = ones(20,20,4);
    for ii = 22:30
        sa{ii} = RAMONSynapse(d,eRAMONDataFormat.dense,[1000 1000 300+ii*5],1,eRAMONSynapseType.excitatory, 100,...
            [1,2;4,0],34,[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser'); %#ok<AGROW>
    end
    
    % BIG cutout
    clear d
    d = ones(100,100,6);
    stemp = RAMONSynapse(d,eRAMONDataFormat.dense,[500 1000 130],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],34,[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser');
    sa{31} = stemp;
    
    
    ids = oo.createAnnotation(sa);
    
    % Check cutouts
    indToCheck = [1:10 22:31];
    q = OCPQuery(eOCPQueryType.RAMONDense,ids(indToCheck));
    sb = oo.query(q);
    
    for jj = 1:length(indToCheck)
        s1 = sa{indToCheck(jj)};
        s2 = sb{jj};
        % check that they match!
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
        
        assertEqual(s1.author, s2.author);
        assertEqual(s1.resolution, s2.resolution);
        assertEqual(s1.synapseType, s2.synapseType);
        assertEqual(s1.weight, s2.weight);
        keys = s1.segments.keys;
        for ii = 1:length(keys)
            assertEqual(s1.segments(keys{ii}), s2.segments(keys{ii}));
        end
        assertEqual(s1.seeds, s2.seeds);
        assertEqual(ids(indToCheck(jj)),s2.id);
        assertEqual(s1.confidence,s2.confidence);
        assertEqual(s1.status,s2.status);
        keys = s1.dynamicMetadata.keys;
        assertEqual(s1.dynamicMetadata(keys{1}),s2.dynamicMetadata(keys{1}));
        assertEqual(s1.dynamicMetadata(keys{2}),s2.dynamicMetadata(keys{2}));
        assertEqual(s1.dynamicMetadata(keys{3}),s2.dynamicMetadata(keys{3}));
    end
    
    % Check voxel lists
    indToCheck = 11:21;
    q = OCPQuery(eOCPQueryType.RAMONVoxelList,ids(indToCheck));
    sb = oo.query(q);
    
    for jj = 1:length(indToCheck)
        s1 = sa{indToCheck(jj)};
        s2 = sb{jj};
        
        % check that they match!
        unionedData = union(s1.data,s2.data,'rows');
        unionedData = sortrows(unionedData,3);
        assertEqual(size(unionedData,1), size(s1.data,1));
        assertEqual(size(unionedData,2), size(s1.data,2));
        assertEqual(unionedData, uint32(s1.data));
        
        assertEqual(s1.author, s2.author);
        assertEqual(s1.resolution, s2.resolution);
        assertEqual(s1.synapseType, s2.synapseType);
        assertEqual(s1.weight, s2.weight);
        keys = s1.segments.keys;
        for ii = 1:length(keys)
            assertEqual(s1.segments(keys{ii}), s2.segments(keys{ii}));
        end
        assertEqual(s1.seeds, s2.seeds);
        assertEqual(ids(indToCheck(jj)),s2.id);
        assertEqual(s1.confidence,s2.confidence);
        assertEqual(s1.status,s2.status);
        keys = s1.dynamicMetadata.keys;
        assertEqual(s1.dynamicMetadata(keys{1}),s2.dynamicMetadata(keys{1}));
        assertEqual(s1.dynamicMetadata(keys{2}),s2.dynamicMetadata(keys{2}));
        assertEqual(s1.dynamicMetadata(keys{3}),s2.dynamicMetadata(keys{3}));
    end
    
     % Set it back
    oo.setMaxAnnoSize(orig_max_anno_size);     
    oo.setBatchSize(orig_batch_size);
end


%% Test Delete batch mode
function TestDeleteBatchMode
    global oo
    % cutouts
    d = ones(20,20,4);
    for ii = 1:5
        sa{ii} = RAMONSynapse(d,eRAMONDataFormat.dense,[1000 1000 300+ii*5],1,eRAMONSynapseType.excitatory, 100,...
            [1,2;4,0],ii,[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser'); %#ok<AGROW>
    end
    
    ids = oo.createAnnotation(sa);
    
    % Check cutouts
    q = OCPQuery(eOCPQueryType.RAMONDense,ids);
    sb = oo.query(q);
    
    for jj = 1:length(ids)
        s1 = sa{jj};
        s2 = sb{jj};
        % check that they match!
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
        
        assertEqual(s1.author, s2.author);
        assertEqual(s1.resolution, s2.resolution);
        assertEqual(s1.synapseType, s2.synapseType);
        assertEqual(s1.weight, s2.weight);
        keys = s1.segments.keys;
        for ii = 1:length(keys)
            assertEqual(s1.segments(keys{ii}), s2.segments(keys{ii}));
        end
        assertEqual(s1.seeds, s2.seeds);
        assertEqual(ids(jj),s2.id);
        assertEqual(s1.confidence,s2.confidence);
        assertEqual(s1.status,s2.status);
        keys = s1.dynamicMetadata.keys;
        assertEqual(s1.dynamicMetadata(keys{1}),s2.dynamicMetadata(keys{1}));
        assertEqual(s1.dynamicMetadata(keys{2}),s2.dynamicMetadata(keys{2}));
        assertEqual(s1.dynamicMetadata(keys{3}),s2.dynamicMetadata(keys{3}));
    end
    
    % Delete
    oo.deleteAnnotation(ids);
        
    % Annos should be gone
    assertExceptionThrown(@()  oo.query(q), 'OCPNetwork:InternalServerError');
    q = OCPQuery(eOCPQueryType.RAMONDense,ids(1));
    assertExceptionThrown(@()  oo.query(q), 'OCPNetwork:InternalServerError');
    q = OCPQuery(eOCPQueryType.RAMONDense,ids(end));
    assertExceptionThrown(@()  oo.query(q), 'OCPNetwork:InternalServerError');
    
end

%% Test Single Annotation Chunking
function testSingleCutoutChunking %#ok<*DEFNU>
    global oo
    
    % Set max annosize small so it is easier to test
    orig_max_anno_size = oo.maxAnnoSize;
    oo.setMaxAnnoSize(20000);
    
    % BIG cutout
    clear d
    d = ones(100,100,5);
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[500 1000 430],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],34,[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser');
    
    id = oo.createAnnotation(s1);
    
    % Check cutouts
    q = OCPQuery(eOCPQueryType.RAMONDense,id);
    s2 = oo.query(q);
    
    % check that they match!
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
    
    assertEqual(s1.author, s2.author);
    assertEqual(s1.resolution, s2.resolution);
    assertEqual(s1.synapseType, s2.synapseType);
    assertEqual(s1.weight, s2.weight);
    keys = s1.segments.keys;
    for ii = 1:length(keys)
        assertEqual(s1.segments(keys{ii}), s2.segments(keys{ii}));
    end
    assertEqual(s1.seeds, s2.seeds);
    assertEqual(id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    keys = s1.dynamicMetadata.keys;
    assertEqual(s1.dynamicMetadata(keys{1}),s2.dynamicMetadata(keys{1}));
    assertEqual(s1.dynamicMetadata(keys{2}),s2.dynamicMetadata(keys{2}));
    assertEqual(s1.dynamicMetadata(keys{3}),s2.dynamicMetadata(keys{3}));
    
    % Set it back
    oo.setMaxAnnoSize(orig_max_anno_size);
end

function testSingleVoxelListChunking %#ok<*DEFNU>% BIG voxel list
    global oo
    
    % Set max annosize small so it is easier to test
    orig_max_anno_size = oo.maxAnnoSize;
    oo.setMaxAnnoSize(20000);
    
    clear d
    d = ones(100,100,5);
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[500 1000 200],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],34,[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser');
    s1.toVoxelList;    
    
    id = oo.createAnnotation(s1);    
    
    % Check cutouts    
    q = OCPQuery(eOCPQueryType.RAMONVoxelList,id);
    s2 = oo.query(q);    
    
    
    % check that they match!
    unionedData = union(s1.data,s2.data,'rows');
    unionedData = sortrows(unionedData,3);
    assertEqual(size(unionedData,1), size(s1.data,1));
    assertEqual(size(unionedData,2), size(s1.data,2));
    assertEqual(unionedData, uint32(s1.data));
    
    assertEqual(s1.author, s2.author);
    assertEqual(s1.resolution, s2.resolution);
    assertEqual(s1.synapseType, s2.synapseType);
    assertEqual(s1.weight, s2.weight);
    keys = s1.segments.keys;
    for ii = 1:length(keys)
        assertEqual(s1.segments(keys{ii}), s2.segments(keys{ii}));
    end
    assertEqual(s1.seeds, s2.seeds);
    assertEqual(id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    keys = s1.dynamicMetadata.keys;
    assertEqual(s1.dynamicMetadata(keys{1}),s2.dynamicMetadata(keys{1}));
    assertEqual(s1.dynamicMetadata(keys{2}),s2.dynamicMetadata(keys{2}));
    assertEqual(s1.dynamicMetadata(keys{3}),s2.dynamicMetadata(keys{3}));
    
     % Set it back
    oo.setMaxAnnoSize(orig_max_anno_size);
end

%% Test Get Fields

function testGenericGetFields
    global oo
    d = zeros(100,80,30);
    d(40:60,40:60,1:2) = 1;
    d(50:55,60:70,2:3) = 1;
    g1 = RAMONGeneric();
    g1.setConfidence(.32);
    g1.addDynamicMetadata('test',234);
    g1.setCutout(d);
    g1.setXyzOffset([34 345 64]);
    g1.setResolution(1);
    
    id = oo.createAnnotation(g1);
    
    f = OCPFields();
    assertEqual(oo.getField(id,f.generic.author),'unspecified');
    assertEqual(oo.getField(id,f.generic.confidence),.32);
    assertEqual(oo.getField(id,f.generic.status),eRAMONAnnoStatus.unprocessed);
end

function testSeedGetFields
    global oo
    
    % upload annotation
    s1 = RAMONSeed([10000 10000 50],eRAMONCubeOrientation.pos_z,12,13,[],.70,eRAMONAnnoStatus.locked,{'test',34});
    id = oo.createAnnotation(s1);
    
    f = OCPFields();
    assertEqual(oo.getField(id,f.synapse.author),'unspecified');
    assertEqual(oo.getField(id,f.synapse.confidence),.70);
    assertEqual(oo.getField(id,f.synapse.status),eRAMONAnnoStatus.locked);
    assertEqual(oo.getField(id,f.seed.position),[10000 10000 50]);
    assertEqual(oo.getField(id,f.seed.cubeOrientation),eRAMONCubeOrientation.pos_z);
    assertEqual(oo.getField(id,f.seed.sourceEntity),13);
    assertEqual(oo.getField(id,f.seed.parentSeed),12);
end

function testSynapseGetFields
    global oo
    
    % upload annotation
    d = zeros(100,80,30);
    d(40:60,40:60,1:2) = 1;
    d(50:55,60:70,2:3) = 1;
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[1000 1000 100],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[34,45],[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser');
    id = oo.createAnnotation(s1);
    
    f = OCPFields();
    assertEqual(oo.getField(id,f.synapse.author),'testuser');
    assertEqual(oo.getField(id,f.synapse.confidence),.64);
    assertEqual(oo.getField(id,f.synapse.status),eRAMONAnnoStatus.processed);
    assertEqual(oo.getField(id,f.synapse.synapseType),eRAMONSynapseType.excitatory);
    assertEqual(oo.getField(id,f.synapse.weight),100);
    assertEqual(oo.getField(id,f.synapse.segments),[1,2;4,0]);
    assertEqual(oo.getField(id,f.synapse.seeds),[34,45]);
end


function testSegmentGetFields
    global oo
    % upload annotation
    d = zeros(100,80,20);
    d(50:60,20:60,1:10) = 1;
    d(50:55,60:70,2:3) = 1;
    
    s1 = RAMONSegment(d, eRAMONDataFormat.dense,[3000 3000 20], 1, eRAMONSegmentClass.unknown,54,...
        [2 45 67], [234 67], 64, [], .256, eRAMONAnnoStatus.unprocessed,...
        {'tester',1212},'testuser');
    id = oo.createAnnotation(s1);
    
    f = OCPFields();
    assertEqual(oo.getField(id,f.segment.author),'testuser');
    assertEqual(oo.getField(id,f.segment.confidence),.256);
    assertEqual(oo.getField(id,f.segment.status),eRAMONAnnoStatus.unprocessed);
    assertEqual(oo.getField(id,f.segment.class),eRAMONSegmentClass.unknown);
    assertEqual(oo.getField(id,f.segment.neuron),54);
    assertEqual(oo.getField(id,f.segment.synapses),[2 45 67]);
    assertEqual(oo.getField(id,f.segment.organelles),[234 67]);
    assertEqual(oo.getField(id,f.segment.parentSeed),64);
end

function testNeuronGetFields
    global oo
    % upload annotation
    n1 = RAMONNeuron([12 34 56 776 45 34], [], .98, eRAMONAnnoStatus.ignored, {'test',34234});
    id = oo.createAnnotation(n1);
    
    f = OCPFields();
    assertEqual(oo.getField(id,f.neuron.author),'unspecified');
    assertEqual(oo.getField(id,f.neuron.confidence),.98);
    assertEqual(oo.getField(id,f.neuron.status),eRAMONAnnoStatus.ignored);
    assertEqual(oo.getField(id,f.neuron.segments),[12 34 56 776 45 34]);
end

function testOrganelleGetFields
    global oo
    % upload annotation
    d = repmat(ones(20),[1 1 20]);
    o1 = RAMONOrganelle(d,eRAMONDataFormat.dense,[4500 5400 650],1,eRAMONOrganelleClass.mitochondria, [123 345 56],...
        3,[],.263, eRAMONAnnoStatus.processed,{'tester',1212},'unit test');
    id = oo.createAnnotation(o1);
    
    f = OCPFields();
    assertEqual(oo.getField(id,f.organelle.author),'unit test');
    assertEqual(oo.getField(id,f.organelle.confidence),.263);
    assertEqual(oo.getField(id,f.organelle.status),eRAMONAnnoStatus.processed);
    assertEqual(oo.getField(id,f.organelle.class),eRAMONOrganelleClass.mitochondria);
    assertEqual(oo.getField(id,f.organelle.parentSeed),3);
    assertEqual(oo.getField(id,f.organelle.seeds), [123 345 56]);
end

%% Test Set Fields

function testGenericSetFields
    global oo
    d = zeros(100,80,30);
    d(40:60,40:60,1:2) = 1;
    d(50:55,60:70,2:3) = 1;
    g1 = RAMONGeneric();
    g1.setConfidence(.32);
    g1.addDynamicMetadata('test',234);
    g1.setCutout(d);
    g1.setXyzOffset([34 345 64]);
    g1.setResolution(1);
    
    id = oo.createAnnotation(g1);
    
    f = OCPFields();
    assertEqual(oo.getField(id,f.generic.author),'unspecified');
    oo.setField(id,f.generic.author,'test_user1');
    assertEqual(oo.getField(id,f.generic.author),'test_user1');
    
    assertEqual(oo.getField(id,f.generic.confidence),.32);
    oo.setField(id,f.generic.confidence,.647);
    assertEqual(oo.getField(id,f.generic.confidence),.647);
    
    assertEqual(oo.getField(id,f.generic.status),eRAMONAnnoStatus.unprocessed);
    oo.setField(id,f.generic.status,eRAMONAnnoStatus.locked);
    assertEqual(oo.getField(id,f.generic.status),eRAMONAnnoStatus.locked);
    
    
    % Make sure nothing was put into metadata
    q = OCPQuery(eOCPQueryType.RAMONMetaOnly,id);
    anno = oo.query(q);
    assertEqual(length(anno.dynamicMetadata.keys),1);
end

function testSynapseSetFields
    global oo
    
    % upload annotation
    d = zeros(100,80,30);
    d(40:60,40:60,1:2) = 1;
    d(50:55,60:70,2:3) = 1;
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[1000 1000 100],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[34,45],[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser');
    id = oo.createAnnotation(s1);
    
    f = OCPFields();
    assertEqual(oo.getField(id,f.synapse.author),'testuser');
    oo.setField(id,f.synapse.author,'test_user1');
    assertEqual(oo.getField(id,f.synapse.author),'test_user1');
    
    assertEqual(oo.getField(id,f.synapse.confidence),.64);
    oo.setField(id,f.synapse.confidence,.423);
    assertEqual(oo.getField(id,f.synapse.confidence),.423);
    
    assertEqual(oo.getField(id,f.synapse.status),eRAMONAnnoStatus.processed);
    oo.setField(id,f.synapse.status,eRAMONAnnoStatus.locked);
    assertEqual(oo.getField(id,f.synapse.status),eRAMONAnnoStatus.locked);
    
    assertEqual(oo.getField(id,f.synapse.synapseType),eRAMONSynapseType.excitatory);
    oo.setField(id,f.synapse.synapseType,eRAMONSynapseType.inhibitory);
    assertEqual(oo.getField(id,f.synapse.synapseType),eRAMONSynapseType.inhibitory);
    
    assertEqual(oo.getField(id,f.synapse.weight),100);
    oo.setField(id,f.synapse.weight,50);
    assertEqual(oo.getField(id,f.synapse.weight),50);
    
    assertEqual(oo.getField(id,f.synapse.seeds),[34,45]);
    oo.setField(id,f.synapse.seeds,[6,7,8]);
    assertEqual(oo.getField(id,f.synapse.seeds),[6,7,8]);
    
    
    % Make sure nothing was put into metadata
    q = OCPQuery(eOCPQueryType.RAMONMetaOnly,id);
    anno = oo.query(q);
    assertEqual(length(anno.dynamicMetadata.keys),3);
end


function testSegmentSetFields
    global oo
    
    % upload annotation
    d = zeros(100,80,20);
    d(50:60,20:60,1:10) = 1;
    d(50:55,60:70,2:3) = 1;
    
    s1 = RAMONSegment(d, eRAMONDataFormat.dense,[3000 3000 20], 1, eRAMONSegmentClass.unknown,54,...
        [2 45 67], [234 67], 64, [], .256, eRAMONAnnoStatus.unprocessed,...
        {'tester',1212},'testuser');
    id = oo.createAnnotation(s1);
    
    f = OCPFields();
    assertEqual(oo.getField(id,f.segment.author),'testuser');
    oo.setField(id,f.segment.author,'test_user1');
    assertEqual(oo.getField(id,f.segment.author),'test_user1');
    
    assertEqual(oo.getField(id,f.segment.confidence),.256);
    oo.setField(id,f.segment.confidence,.4233);
    assertEqual(oo.getField(id,f.segment.confidence),.4233);
    
    assertEqual(oo.getField(id,f.segment.status),eRAMONAnnoStatus.unprocessed);
    oo.setField(id,f.segment.status,eRAMONAnnoStatus.processed);
    assertEqual(oo.getField(id,f.segment.status),eRAMONAnnoStatus.processed);
    
    assertEqual(oo.getField(id,f.segment.class),eRAMONSegmentClass.unknown);
    oo.setField(id,f.segment.class,eRAMONSegmentClass.dendrite);
    assertEqual(oo.getField(id,f.segment.class),eRAMONSegmentClass.dendrite);
    
    assertEqual(oo.getField(id,f.segment.neuron),54);
    oo.setField(id,f.segment.neuron,36);
    assertEqual(oo.getField(id,f.segment.neuron),36);
    
    assertEqual(oo.getField(id,f.segment.parentSeed),64);
    oo.setField(id,f.segment.parentSeed,15);
    assertEqual(oo.getField(id,f.segment.parentSeed),15);
    
    assertEqual(oo.getField(id,f.segment.synapses),[2 45 67]);
    oo.setField(id,f.segment.synapses,[6,7,8]);
    assertEqual(oo.getField(id,f.segment.synapses),[6,7,8]);
    
    assertEqual(oo.getField(id,f.segment.organelles),[234 67]);
    oo.setField(id,f.segment.organelles,[56,245]);
    assertEqual(oo.getField(id,f.segment.organelles),[56,245]);
    
    % Make sure nothing was put into metadata
    q = OCPQuery(eOCPQueryType.RAMONMetaOnly,id);
    anno = oo.query(q);
    assertEqual(length(anno.dynamicMetadata.keys),1);
    
end

function testNeuronSetFields
    global oo
    
    % upload annotation
    n1 = RAMONNeuron([12 34 56 776 45 34], [], .98, eRAMONAnnoStatus.ignored, {'test',34234});
    id = oo.createAnnotation(n1);
    
    f = OCPFields();
    assertEqual(oo.getField(id,f.neuron.author),'unspecified');
    oo.setField(id,f.segment.author,'test_user1');
    assertEqual(oo.getField(id,f.neuron.author),'test_user1');
    
    assertEqual(oo.getField(id,f.neuron.confidence),.98);
    oo.setField(id,f.neuron.confidence,.234);
    assertEqual(oo.getField(id,f.neuron.confidence),.234);
    
    assertEqual(oo.getField(id,f.neuron.status),eRAMONAnnoStatus.ignored);
    oo.setField(id,f.neuron.status,eRAMONAnnoStatus.processed);
    assertEqual(oo.getField(id,f.neuron.status),eRAMONAnnoStatus.processed);    
    
    assertEqual(oo.getField(id,f.neuron.segments),[12 34 56 776 45 34]);
    oo.setField(id,f.neuron.segments,[12 34 56 776 45 34 54 615]);
    assertEqual(oo.getField(id,f.neuron.segments),[12 34 56 776 45 34 54 615]);    
    
    % Make sure nothing was put into metadata
    q = OCPQuery(eOCPQueryType.RAMONMetaOnly,id);
    anno = oo.query(q);
    assertEqual(length(anno.dynamicMetadata.keys),1);    
end


function testSeedSetFields
    global oo
    
    % upload annotation
    s1 = RAMONSeed([1056 1340 526],eRAMONCubeOrientation.pos_z,12,13,[],.70,eRAMONAnnoStatus.locked,{'test',34});
    id = oo.createAnnotation(s1);
        
    f = OCPFields();
    assertEqual(oo.getField(id,f.seed.author),'unspecified');
    oo.setField(id,f.seed.author,'test_user1');
    assertEqual(oo.getField(id,f.seed.author),'test_user1');
    
    assertEqual(oo.getField(id,f.seed.confidence),.70);
    oo.setField(id,f.seed.confidence,.234);
    assertEqual(oo.getField(id,f.seed.confidence),.234);
    
    assertEqual(oo.getField(id,f.seed.status),eRAMONAnnoStatus.locked);
    oo.setField(id,f.seed.status,eRAMONAnnoStatus.processed);
    assertEqual(oo.getField(id,f.seed.status),eRAMONAnnoStatus.processed);    
    
    assertEqual(oo.getField(id,f.seed.position),[1056 1340 526]);
    oo.setField(id,f.seed.position,[345 5678 34]);
    assertEqual(oo.getField(id,f.seed.position),[345 5678 34]); 
    
    assertEqual(oo.getField(id,f.seed.cubeOrientation),eRAMONCubeOrientation.pos_z);
    oo.setField(id,f.seed.cubeOrientation,eRAMONCubeOrientation.neg_y);
    assertEqual(oo.getField(id,f.seed.cubeOrientation),eRAMONCubeOrientation.neg_y);
        
    assertEqual(oo.getField(id,f.seed.sourceEntity),13);
    oo.setField(id,f.seed.sourceEntity,4356);
    assertEqual(oo.getField(id,f.seed.sourceEntity),4356);    
    
    assertEqual(oo.getField(id,f.seed.parentSeed),12);
    oo.setField(id,f.seed.parentSeed,345);
    assertEqual(oo.getField(id,f.seed.parentSeed),345);    
    
    % Make sure nothing was put into metadata
    q = OCPQuery(eOCPQueryType.RAMONMetaOnly,id);
    anno = oo.query(q);
    assertEqual(length(anno.dynamicMetadata.keys),1);    
end

function testOrganelleSetFields
    global oo
    
    % upload annotation
    d = repmat(ones(20),[1 1 20]);
    o1 = RAMONOrganelle(d,eRAMONDataFormat.dense,[4500 5400 650],1,eRAMONOrganelleClass.mitochondria, [123 345 56],...
        3,[],.263, eRAMONAnnoStatus.processed,{'tester',1212},'unit test');
    id = oo.createAnnotation(o1);
    
    f = OCPFields();
    assertEqual(oo.getField(id,f.organelle.seeds), [123 345 56]);
    
    
    f = OCPFields();
    assertEqual(oo.getField(id,f.organelle.author),'unit test');
    oo.setField(id,f.organelle.author,'test_user1');
    assertEqual(oo.getField(id,f.organelle.author),'test_user1');
    
    assertEqual(oo.getField(id,f.organelle.confidence),.263);
    oo.setField(id,f.organelle.confidence,.234);
    assertEqual(oo.getField(id,f.organelle.confidence),.234);
    
    assertEqual(oo.getField(id,f.organelle.status),eRAMONAnnoStatus.processed);
    oo.setField(id,f.organelle.status,eRAMONAnnoStatus.unprocessed);
    assertEqual(oo.getField(id,f.organelle.status),eRAMONAnnoStatus.unprocessed);    
        
    assertEqual(oo.getField(id,f.organelle.class),eRAMONOrganelleClass.mitochondria);
    oo.setField(id,f.organelle.class,eRAMONOrganelleClass.vesicle);
    assertEqual(oo.getField(id,f.organelle.class),eRAMONOrganelleClass.vesicle);
    
    assertEqual(oo.getField(id,f.organelle.seeds),[123 345 56]);
    oo.setField(id,f.organelle.seeds,[345 5678 34]);
    assertEqual(oo.getField(id,f.organelle.seeds),[345 5678 34]);         
    
    assertEqual(oo.getField(id,f.organelle.parentSeed),3);
    oo.setField(id,f.organelle.parentSeed,345);
    assertEqual(oo.getField(id,f.organelle.parentSeed),345);    
    
    % Make sure nothing was put into metadata
    q = OCPQuery(eOCPQueryType.RAMONMetaOnly,id);
    anno = oo.query(q);
    assertEqual(length(anno.dynamicMetadata.keys),1);    
end


%% Test Custom KV Pairs

function testSynapseCustomKV
    global oo
    
    % upload annotation
    d = zeros(100,80,30);
    d(40:60,40:60,1:2) = 1;
    d(50:55,60:70,2:3) = 1;
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[1000 1000 100],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[34,45],[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser');
    id = oo.createAnnotation(s1);
    
     % Make sure nothing was put into metadata
    q = OCPQuery(eOCPQueryType.RAMONMetaOnly,id);
    anno = oo.query(q);
    assertEqual(length(anno.dynamicMetadata.keys),3);    
    
    keys = anno.dynamicMetadata.keys;
    assertEqual(anno.dynamicMetadata(keys{1}),'sets');
    assertEqual(anno.dynamicMetadata(keys{2}),[]);
    assertEqual(anno.dynamicMetadata(keys{3}),1212);
    
    % key error
    assertExceptionThrown(@() oo.setField(id,343,45), 'OCP:InvalidCustomKey');
    assertExceptionThrown(@() oo.getField(id,'rando!'), 'OCPNetwork:InternalServerError');
    
    % Set custom string
    oo.setField(id,'string_field_single','test')
    assertEqual(oo.getField(id,'string_field_single'),'test');  
    
    % Set custom string
    oo.setField(id,'string_field','This is a test string')
    assertEqual(oo.getField(id,'string_field'),'This_is_a_test_string');   
    
    % set custom float
    oo.setField(id,'float_field',6.32)
    assertEqual(oo.getField(id,'float_field'),6.32);   
    
    % set custom int
    oo.setField(id,'int_field',3454)
    assertEqual(oo.getField(id,'int_field'),3454);  
    
    % set custom matrix ----- Currently not supported
%     a = magic(3);
%     oo.setField(id,'mat_field',a)
%     assertEqual(oo.getField(id,'mat_field'),a);     
    
end

%% Test Filter

function testIDFilterCutoutDense
    global oo
    
    % upload annotation
    d = ones(25,25,10);
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[1234 2315 556],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[34,45],[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser');
    s2 = RAMONSynapse(d,eRAMONDataFormat.dense,[1334 2315 556],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[34,45],[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser');
    s3 = RAMONSynapse(d,eRAMONDataFormat.dense,[1334 2415 556],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[34,45],[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser');
    
    id1 = oo.createAnnotation(s1);
    id2 = oo.createAnnotation(s2);
    id3 = oo.createAnnotation(s3);
    
    % Query without filter
    q1 = OCPQuery(eOCPQueryType.annoDense);
    q1.setCutoutArgs([1200 1400],[2300 2500],[555 558],1);
    
    data = oo.query(q1);
    assertEqual(double(unique(data.data))',[0, id1, id2, id3]); 
    
    % Query with filter
    q1.setFilterIds([id1 id2]);
    data1 = oo.query(q1);
    assertEqual(double(unique(data1.data))',[0, id1, id2]);  
    
    % Query with filter
    q1.setFilterIds(id3);
    data1 = oo.query(q1);

    assertEqual(double(unique(data1.data))',[0,id3]);  
    
end


function testIDFilterSlice
    global oo
    
    % upload annotation
    d = ones(25,25,10);
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[1234 2315 556],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[34,45],[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser');
    s2 = RAMONSynapse(d,eRAMONDataFormat.dense,[1334 2315 556],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[34,45],[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser');
    s3 = RAMONSynapse(d,eRAMONDataFormat.dense,[1334 2415 556],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],[34,45],[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser');
    
    id1 = oo.createAnnotation(s1);
    id2 = oo.createAnnotation(s2);
    id3 = oo.createAnnotation(s3);
    
    % Query without filter
    q1 = OCPQuery(eOCPQueryType.annoSlice);
    q1.setSliceArgs(eOCPSlicePlane.xy, [1200 1400],[2300 2500],557,1);
    
    data = oo.query(q1);
    
    data_gray = rgb2gray(data);
    
    idsInData = unique(data_gray);
    idsInData(1) = [];
    assertEqual(length(idsInData),3);  
    
    % Query with filter
    q1.setFilterIds([id1 id2]);
    data1 = oo.query(q1);
    data1_gray = rgb2gray(data1);
    
    idsInData = unique(data1_gray);
    idsInData(1) = [];
    assertEqual(length(idsInData),2);  
    
    % Query with filter
    q1.setFilterIds(id3);
    data1 = oo.query(q1);
    data1_gray = rgb2gray(data1);
    
    idsInData = unique(data1_gray);
    idsInData(1) = [];
    assertEqual(length(idsInData),1);     
end


%% Test ID Reservation
function testIDReservation
    global oo
    
    id_list1 = oo.reserve_ids(3);    
    assertEqual(length(id_list1),3); 
    
    id_list2 = oo.reserve_ids(5);  
    assertEqual(length(id_list2),5);  
    assertEqual(id_list1(end), id_list2(1) - 1);  
    
    id_list3 = oo.reserve_ids(2);
    assertEqual(length(id_list3),2);  
    assertEqual(id_list2(end), id_list3(1) - 1);  
    
    d = zeros(100,80,30);
    d(40:60,40:60,1:2) = 1;
    d(50:55,60:70,2:3) = 1;
    s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[1000 1000 100],1,eRAMONSynapseType.excitatory, 100,...
        [1,2;4,0],34,[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser');
    id = oo.createAnnotation(s1);    
    
    assertEqual(id_list3(end), id - 1);  
    
end

%% Test merge
function testMerge %#ok<*DEFNU>
    global oo
    
    % upload annotation
    d = ones(50,50,10);
    
    s1 = RAMONSegment(d, eRAMONDataFormat.dense,[5000 5000 235], 1, eRAMONSegmentClass.unknown,54,...
        [2 45 67], [234 67], 64, [], .256, eRAMONAnnoStatus.unprocessed,...
        {'tester',1212},'testuser');
    id1 = oo.createAnnotation(s1);
    
    s2 = RAMONSegment(d, eRAMONDataFormat.dense,[5000 5000 255], 1, eRAMONSegmentClass.unknown,54,...
        [2 45 67], [234 67], 64, [], .256, eRAMONAnnoStatus.unprocessed,...
        {'tester',1212},'testuser');
    id2 = oo.createAnnotation(s2);
    
    % download annotation and check ids
    q = OCPQuery(eOCPQueryType.annoDense);
    q.setCutoutArgs([5000,5050],[5000,5050],[235,265],1);
    data = oo.query(q);    
   
    assertEqual(double(data.data(20,20,5)), id1);
    assertEqual(double(data.data(20,20,25)), id2);
    
    % merge
    oo.mergeAnnotation(id1,id2);
    
     % download annotation and check ids
    q = OCPQuery(eOCPQueryType.annoDense);
    q.setCutoutArgs([5000,5050],[5000,5050],[235,265],1);
    data = oo.query(q);    
   
    assertEqual(double(data.data(20,20,5)), id1);
    assertEqual(double(data.data(20,20,25)), id1); 
    
    % Delete
    oo.deleteAnnotation(id1);
    
    assertExceptionThrown(@() oo.deleteAnnotation(id2), 'OCPNetwork:InternalServerError');

end


%% Test rgba32 data reads
function testCutoutRGBA %#ok<*DEFNU>
    global oo
 
    % Setup OCP object
    oo.setImageToken('mitra14N777');

    % Build query
    q = OCPQuery();
    q.setType(eOCPQueryType.imageDense);
    q.setCutoutArgs([10000,10250],[10000,10250],[150,155],0);
    
    % Cutout Data
    img = oo.query(q);
    
    % Load saved file
    load(fullfile(cajal3d.getRootDir,'test','matlab','api','data','rgba.mat'));
    
    assertEqual(img.data,saved_img.data);  
    assertEqual(img.xyzOffset,saved_img.xyzOffset); 
    assertEqual(img.resolution,saved_img.resolution);  
    assertEqual(img.dataType,saved_img.dataType);  
    
    % Reset image token
    oo.setImageToken('kasthuri11');
end


%% Test mutlichannel data reads
function testCutoutMultichannel %#ok<*DEFNU>
    global oo
    
    % check not multi channel
    oo.setImageToken('kasthuri11');
    assertEqual(oo.getChannelList,[]); 
    % Check multi channel channel list
    warning('off','OCPHdf:BadFieldChar')
    oo.setImageToken('Ex10R55');
    warning('on','OCPHdf:BadFieldChar')

    % Build query
    q = OCPQuery(eOCPQueryType.imageDense);
    q.setCutoutArgs([1000 1200],[1000 1200],[50 60],0);  
    q.setChannels({'Synapsin1__2'});    
    
    % Get 1 channel 
    img = oo.query(q);
    img = img{:};
    
    % Load saved file
    load(fullfile(cajal3d.getRootDir,'test','matlab','api','data','multich1.mat'));
    
    assertEqual(img.data,savedImg.data);   %#ok<USENS>
    assertEqual(img.xyzOffset,savedImg.xyzOffset); 
    assertEqual(img.resolution,savedImg.resolution);  
    assertEqual(img.dataType,savedImg.dataType);  
    assertEqual(img.name,savedImg.name); 
    
      
    % Get Multiple channels     
    q.setChannels({'DAPI__3','Synapsin1__2'});
    img = oo.query(q);    
   
    % Load saved file
    load(fullfile(cajal3d.getRootDir,'test','matlab','api','data','multich2.mat'));
    
    assertEqual(img{1}.data,savedImg{1}.data);  
    assertEqual(img{1}.xyzOffset,savedImg{1}.xyzOffset); 
    assertEqual(img{1}.resolution,savedImg{1}.resolution);  
    assertEqual(img{1}.dataType,savedImg{1}.dataType);  
    assertEqual(img{1}.name,savedImg{1}.name);     
    
    assertEqual(img{2}.data,savedImg{2}.data);  
    assertEqual(img{2}.xyzOffset,savedImg{2}.xyzOffset); 
    assertEqual(img{2}.resolution,savedImg{2}.resolution);  
    assertEqual(img{2}.dataType,savedImg{2}.dataType);  
    assertEqual(img{2}.name,savedImg{2}.name); 
    
    % Reset image token
    oo.setImageToken('kasthuri11');
end

function testSliceMultichannel %#ok<*DEFNU>  
    global oo
    
    % Check multi channel channel list
    warning('off','OCPHdf:BadFieldChar')
    oo.setImageToken('Ex10R55');
    warning('on','OCPHdf:BadFieldChar')

    % Build query
    q = OCPQuery(eOCPQueryType.imageSlice);
    q.setARange([1000,1500]);
    q.setBRange([1000,1500]);
    q.setCIndex(55);
    q.setSlicePlane(eOCPSlicePlane.xy);
    q.setResolution(0);
    q.setChannels({'Synapsin1__2','GluR4__8','vGAT__6'});    
    
    % Get 1 channel 
    img = oo.query(q);
        
    load(fullfile(cajal3d.getRootDir,'test','matlab','api','data','multislice1.mat'));    
    assertEqual(img,savedImg); 
    
     % Reset image token
    oo.setImageToken('kasthuri11');
end

function testImageDataUpload %#ok<*DEFNU> 
    global oo;
    oo2 = OCP();
    oo2.setImageToken('apiUnitTestImageUpload');
    
    % Check db is empty
    q = OCPQuery(eOCPQueryType.imageDense);
    q.setCutoutArgs([3000,3250],[4000,4250],[500,505]);
    q.setResolution(1);
    
    % Cutout some kasthuri11 data
    k_data = oo.query(q);
    d = ones(size(k_data.data));
    sum_total = sum(d(:));
    
    % Make sure the image upload DB is empty to start
    start_data = oo2.query(q);
    assertEqual(sum_total,sum(start_data.data(:)));
    
    % Upload data
    oo2.uploadImageData(k_data);
    
    % Cutout newly uploaded data
    new_data = oo2.query(q);
    
    % Check that it matches
    % TODO: They don't straight match for some reason. Need to figure
    % out why this is happening.
    assertEqual(k_data.xyzOffset,new_data.xyzOffset);
    assertEqual(k_data.resolution,new_data.resolution);
    assertEqual(sum(k_data.data(:) - new_data.data(:)),0);

    % Clear out newly uploaded data
    blank_data = new_data.clone;
    blank_data.setCutout(d);
    oo2.uploadImageData(blank_data);
    
    % Check it's empty
    cleared_data = oo2.query(q);
    assertEqual(sum_total,sum(cleared_data.data(:)));
end

function testPropagate %#ok<*DEFNU>   
    oo2 = OCP();
    oo2.setImageToken('kasthuri11');
    oo2.setAnnoToken('apiUnitTestPropagate');
    oo2.makeAnnoWritable();
    
    % Check db is clean
    q = OCPQuery(eOCPQueryType.annoDense);
    q.setCutoutArgs([0,250],[0,250],[0,20],1);
    cutout_clean = oo2.query(q);
    assertEqual(sum(sum(sum(cutout_clean.data))),0);
    
    % Make sure you start writable
    assertEqual(oo2.getAnnoPropagateStatus(),eOCPPropagateStatus.inconsistent);
    
    % Upload annotations
    a = round(checkerboard(20));
    a = repmat(a,1,1,5);
    s = RAMONSynapse();
    s.setCutout(a);
    s.setXyzOffset([50,50,4]);
    s.setResolution(1);
    id1 = oo2.createAnnotation(s);
    
    % Check 1
    cutout1 = oo2.query(q);
    assertEqual(sum(a(:)),sum(cutout1.data(:)/max(cutout1.data(:))));
    
    % Check 2 (zoom out service)
    q2 = OCPQuery(eOCPQueryType.annoDense);
    q2.setCutoutArgs([0,125],[0,125],[0,20],2);
    cutout2 = oo2.query(q2);
    assertEqual(sum(a(:))/4,sum(cutout2.data(:)/max(cutout2.data(:))));
    
    % Propagate
    fprintf('Testing DB Propagation\n');
    oo2.propagateAnnoDB();
    
    % Check 0
    cnt = 0;
    while (oo2.getAnnoPropagateStatus() == eOCPPropagateStatus.propagating)
        if cnt > 6*2
            error('testOCP:testPropagate','Propagate Timeout. Check OCP services');
        end
        pause(10);
        fprintf('waiting for propagation to complete\n');
        cnt = cnt + 1;
    end
    assertEqual(oo2.getAnnoPropagateStatus(), eOCPPropagateStatus.consistent);
    
    % Check 1
    cutout1b = oo2.query(q);
    assertEqual(cutout1.data, cutout1b.data);
    
    % Check 2
    cutout2b = oo2.query(q2);
    assertEqual(cutout2.data, cutout2b.data);
    
    % Make sure you can't write
    assertExceptionThrown(@() oo2.createAnnotation(s), 'OCP:DbLocked');
    
    % Make writable again
    oo2.makeAnnoWritable();
    assertEqual(oo2.getAnnoPropagateStatus(), eOCPPropagateStatus.inconsistent);

    
    % Clear out all annotations
    oo2.deleteAnnotation(id1);
    
    % Check db is clean
    q = OCPQuery(eOCPQueryType.annoDense);
    q.setCutoutArgs([0,250],[0,250],[0,20],1);
    cutout_clean = oo2.query(q);
    assertEqual(sum(sum(sum(cutout_clean.data))),0);
end

%% TODO: Test neariso interface

%% TODO: Test zip interface

%% TODO: Test public token interface
function testPublicTokens%#ok<*DEFNU>
    oo = OCP();
    oo.setServerLocation('openconnecto.me');
    tokens = oo.getPublicTokens;
    assertEqual(sum(cellfun(@any,strfind(tokens,'bock11'))),1);
    assertEqual(sum(cellfun(@any,strfind(tokens,'Ex13R51'))),1);
    assertEqual(sum(cellfun(@any,strfind(tokens,'Ex14R58'))),1);
    assertEqual(sum(cellfun(@any,strfind(tokens,'Ex2R18C2'))),1);
    assertEqual(sum(cellfun(@any,strfind(tokens,'Ex3R43C3'))),1);
    assertEqual(sum(cellfun(@any,strfind(tokens,'kasthuri11'))),1);
end

%% Clean up
function cleanup
    
    % Turn warnings back on.
    warning('on','OCP:BatchWriteError');
    warning('on','OCP:RAMONResolutionEmpty');    
    warning('on','OCP:MissingInitQuery');
    warning('on','OCP:CustomKVPair');
end

