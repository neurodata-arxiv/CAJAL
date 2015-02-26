function test_suite = testOCPQuery %#ok<STOUT>
    %% TESTOCP Unit Test suite for the OCP api class
    % Note: When writing unit tests the pwd is set to to path the tests are in
    
    %% Init the test suite
    initTestSuite;
    
end
%% Test field Errors
function testIncorrectFieldErros %#ok<*DEFNU>
    
    assertExceptionThrown(@() OCPQuery(324,234,561), 'MATLAB:maxrhs');
    
    ocp = OCPQuery();
    
    assertExceptionThrown(@() ocp.setCutoutArgs(324), 'OCPQuery:IncorrectNumArgs');
    assertExceptionThrown(@() ocp.setCutoutArgs(324,546,234,45,23,4,34,12345,345), 'OCPQuery:IncorrectNumArgs');
    
    assertExceptionThrown(@() ocp.setSliceArgs(324,546,234,45,23,4,34,12345,345), 'OCPQuery:IncorrectNumArgs');
    
    assertExceptionThrown(@() ocp.setType(), 'OCPQuery:MissingArgs');
    
    assertExceptionThrown(@() ocp.setXRange([2345 12]), 'OCPQuery:BadRange');
    assertExceptionThrown(@() ocp.setYRange([2345 12]), 'OCPQuery:BadRange');
    assertExceptionThrown(@() ocp.setZRange([2345 12]), 'OCPQuery:BadRange');
    assertExceptionThrown(@() ocp.setARange([2345 12]), 'OCPQuery:BadRange');
    assertExceptionThrown(@() ocp.setBRange([2345 12]), 'OCPQuery:BadRange');
    
end

%% Test Setting
function testSetDense %#ok<*DEFNU>
    q = OCPQuery();
    q.setType(eOCPQueryType.annoDense);
    q.setCutoutArgs([1 2],[3 4],[5 6]);
    assertEqual(q.xRange,[1 2]);
    assertEqual(q.yRange,[3 4]);
    assertEqual(q.zRange,[5 6]);
    clear q
    
    
    q = OCPQuery();
    q.setType(eOCPQueryType.annoDense);
    q.setCutoutArgs([1 2],[3 4],[5 6],2);
    assertEqual(q.xRange,[1 2]);
    assertEqual(q.yRange,[3 4]);
    assertEqual(q.zRange,[5 6]);
    assertEqual(q.resolution,2);
    clear q
    
    
    q = OCPQuery();
    q.setType(eOCPQueryType.annoDense);
    q.setCutoutArgs(1, 2,3 ,4,5 ,6);
    assertEqual(q.xRange,[1 2]);
    assertEqual(q.yRange,[3 4]);
    assertEqual(q.zRange,[5 6]);
    clear q
    
    
    q = OCPQuery();
    q.setType(eOCPQueryType.annoDense);
    q.setCutoutArgs(1, 2,3 ,4,5 ,6,2);
    assertEqual(q.xRange,[1 2]);
    assertEqual(q.yRange,[3 4]);
    assertEqual(q.zRange,[5 6]);
    assertEqual(q.resolution,2);
    clear q
    
    q = OCPQuery();
    q.setType(eOCPQueryType.annoDense);
    q.setXRange([2 4]);
    q.setYRange([1 4]);
    q.setZRange([67 854]);
    assertEqual(q.xRange,[2 4]);
    assertEqual(q.yRange,[1 4]);
    assertEqual(q.zRange,[67 854]);
    clear q
    
    
    q = OCPQuery();
    q.setType(eOCPQueryType.imageDense);
    q.setCutoutArgs([1 2],[3 4],[5 6]);
    assertEqual(q.xRange,[1 2]);
    assertEqual(q.yRange,[3 4]);
    assertEqual(q.zRange,[5 6]);
    clear q
    
end


function testSlice %#ok<*DEFNU>
    q = OCPQuery();
    q.setType(eOCPQueryType.annoSlice);
    q.setSliceArgs(eOCPSlicePlane.xy,[1 2], [3 4],5);
    assertEqual(q.aRange,[1 2]);
    assertEqual(q.bRange,[3 4]);
    assertEqual(q.cIndex,5);
    assertEqual(q.slicePlane,eOCPSlicePlane.xy);
    clear q
    
    q = OCPQuery();
    q.setType(eOCPQueryType.annoSlice);
    q.setSliceArgs(eOCPSlicePlane.xy,[1 2], [3 4],5,1);
    assertEqual(q.aRange,[1 2]);
    assertEqual(q.bRange,[3 4]);
    assertEqual(q.cIndex,5);
    assertEqual(q.slicePlane,eOCPSlicePlane.xy);
    assertEqual(q.resolution,1);
    clear q
    
    q = OCPQuery();
    q.setType(eOCPQueryType.annoSlice);
    q.setSliceArgs(eOCPSlicePlane.xy,1,2,3,4,5);
    assertEqual(q.aRange,[1 2]);
    assertEqual(q.bRange,[3 4]);
    assertEqual(q.cIndex,5);
    assertEqual(q.slicePlane,eOCPSlicePlane.xy);
    clear q
    
    q = OCPQuery();
    q.setType(eOCPQueryType.annoSlice);
    q.setSliceArgs(eOCPSlicePlane.xy,1,2,3,4,5,0);
    assertEqual(q.aRange,[1 2]);
    assertEqual(q.bRange,[3 4]);
    assertEqual(q.cIndex,5);
    assertEqual(q.slicePlane,eOCPSlicePlane.xy);
    assertEqual(q.resolution,0);
    clear q
    
    q = OCPQuery();
    q.setType(eOCPQueryType.annoSlice);
    q.setARange([1 2]);
    q.setBRange([3 4]);
    q.setCIndex(5);
    q.setSlicePlane(eOCPSlicePlane.xy);
    q.setResolution(0);
    assertEqual(q.aRange,[1 2]);
    assertEqual(q.bRange,[3 4]);
    assertEqual(q.cIndex,5);
    assertEqual(q.slicePlane,eOCPSlicePlane.xy);
    assertEqual(q.resolution,0);
    clear q
    
    q = OCPQuery();
    q.setType(eOCPQueryType.imageSlice);
    q.setSliceArgs(eOCPSlicePlane.xy,[1 2], [3 4],5);
    assertEqual(q.aRange,[1 2]);
    assertEqual(q.bRange,[3 4]);
    assertEqual(q.cIndex,5);
    assertEqual(q.slicePlane,eOCPSlicePlane.xy);
    clear q
    
    q = OCPQuery();
    q.setType(eOCPQueryType.overlaySlice);
    q.setSliceArgs(eOCPSlicePlane.xy,[1 2], [3 4],5);
    assertEqual(q.aRange,[1 2]);
    assertEqual(q.bRange,[3 4]);
    assertEqual(q.cIndex,5);
    assertEqual(q.slicePlane,eOCPSlicePlane.xy);
    clear q
end

function testSetIdList
    q = OCPQuery();
    q.setType(eOCPQueryType.RAMONIdList);
    q.addIdListPredicate(eOCPPredicate.status,2);
    assertEqual(q.type,eOCPQueryType.RAMONIdList);
    key = q.idListPredicates.keys;
    assertEqual(double(q.idListPredicates.Count),1);
    assertEqual(q.idListPredicates(key{:}),2);
    clear q
    
    
    q = OCPQuery(eOCPQueryType.RAMONIdList);
    q.addIdListPredicate(eOCPPredicate.status,'tyu');
    q.setIdListLimit(200);
    assertEqual(q.type,eOCPQueryType.RAMONIdList);
    key = q.idListPredicates.keys;
    assertEqual(double(q.idListPredicates.Count),1);
    assertEqual(q.idListPredicates(key{:}),'tyu');
    assertEqual(q.idListLimit,200);
    clear q
end


function testSetRAMON
    q = OCPQuery(eOCPQueryType.RAMONDense);
    q.setId(234);
    assertEqual(q.id,234);
end

%% Test Validation

function testValidateDense %#ok<*DEFNU>
    q = OCPQuery();
    [t m] = q.validate();
    assertEqual(t,false);
    
    q = OCPQuery();
    q.setType(eOCPQueryType.imageDense);
    q.setXRange([1 2]);
    [t m] = q.validate();
    assertEqual(t,false);
    
    q = OCPQuery();
    q.setType(eOCPQueryType.imageDense);
    q.setCutoutArgs([1 2],[3 4],[5 6]);
    [t m] = q.validate();
    assertEqual(t,true);
    
    q = OCPQuery();
    q.setType(eOCPQueryType.annoDense);
    q.setCutoutArgs([1 2],[3 4],[5 6]);
    [t m] = q.validate();
    assertEqual(t,true);
end

function testValidateSlice
    q = OCPQuery();
    q.setType(eOCPQueryType.annoSlice);
    q.setARange([1 2]);
    [t m] = q.validate();
    assertEqual(t,false);
    
    q = OCPQuery();
    q.setType(eOCPQueryType.annoSlice);
    q.setARange([1 2]);
    q.setBRange([1 2]);
    [t m] = q.validate();
    assertEqual(t,false);
    
    q = OCPQuery();
    q.setType(eOCPQueryType.annoSlice);
    q.setSliceArgs(eOCPSlicePlane.xy,1,2,3,4,5,0);
    [t m] = q.validate();
    assertEqual(t,true);
end

function testValidateRamonVoxelDense
    q = OCPQuery();
    q.setType(eOCPQueryType.RAMONDense);
    [t m] = q.validate();
    assertEqual(t,false);
    
    q = OCPQuery();
    q.setType(eOCPQueryType.RAMONDense);
    q.setId(452);
    [t m] = q.validate();
    assertEqual(t,true);
end

function testValidateRamonMeta
    q = OCPQuery();
    q.setType(eOCPQueryType.RAMONMetaOnly);
    [t m] = q.validate();
    assertEqual(t,false);
    
    q = OCPQuery();
    q.setType(eOCPQueryType.RAMONMetaOnly);
    q.setId(35);
    [t m] = q.validate();
    assertEqual(t,true);
    
    q = OCPQuery();
    q.setType(eOCPQueryType.RAMONMetaOnly);
    q.setZRange([1 4]);
    q.setId(35);
    [t m] = q.validate();
    assertEqual(t,true);
    
    q = OCPQuery();
    q.setType(eOCPQueryType.RAMONMetaOnly);
    q.setARange([1 4]);
    q.setId(35);
    [t m] = q.validate();
    assertEqual(t,true);
end

function testValidateBoundingBox
    % TODO
    
    q = OCPQuery();
    q.setType(eOCPQueryType.RAMONBoundingBox);
    [t m] = q.validate();
    assertEqual(t,false);
    
    q.setId(234);
    [t m] = q.validate();
    assertEqual(t,true);
end

function testValidateIdList
    q = OCPQuery();
    q.setType(eOCPQueryType.RAMONIdList);
    [t m] = q.validate();
    assertEqual(t,true);
    
    q = OCPQuery();
    q.setType(eOCPQueryType.RAMONIdList);
    q.addIdListPredicate(eOCPPredicate.status,1);
    [t m] = q.validate();
    assertEqual(t,true);
    
    q = OCPQuery();
    q.setType(eOCPQueryType.RAMONIdList);
    q.addIdListPredicate(eOCPPredicate.status,1);
    q.setCutoutArgs([2 3],[4 5],[6 7]);
    [t m] = q.validate();
    assertEqual(t,true);
    
    q = OCPQuery();
    q.setType(eOCPQueryType.RAMONIdList);
    q.addIdListPredicate(eOCPPredicate.status,1);
    q.setZRange([3 4]);
    [t m] = q.validate();
    assertEqual(t,false);
end


%% Test Save/Load Queries
function testSaveLoad
    
    q = OCPQuery();
    q.setType(eOCPQueryType.imageDense);
    q.setCutoutArgs([1 2],[3 4],[5 6],2);
    
    % q.save();
    tfile = [tempname,'.mat'];
    q.save(tfile);
    
    % q = OCPQuery.open();
    q2 = OCPQuery.open(tfile);
    
    
    assertEqual(q.xRange,q2.xRange);
    assertEqual(q.yRange,q2.yRange);
    assertEqual(q.zRange,q2.zRange);
    assertEqual(q.resolution,q2.resolution);
    assertEqual(q.type,q2.type);
    
    
end

%% Test Advanced Checking
function testAdvancedCheckingDense    
    oo = OCP();
    oo.setAnnoToken('apiUnitTestKasthuri');
    
    % Dense
    q = OCPQuery(eOCPQueryType.imageDense);
    q.setCutoutArgs([234 345],[234 456],[234 456]);
    [t,m] = q.validate(oo.annoInfo);
    assertTrue(t);
    
    q.setCutoutArgs([234 23434255645635634523],[234 456],[234 456],0);
    [t,m] = q.validate(oo.annoInfo);
    assertFalse(t);    
   
    q.setCutoutArgs([234 4565],[234 456],[0 5768789789]);
    [t,m] = q.validate(oo.annoInfo);
    assertFalse(t);
    
    q.setCutoutArgs([234 4565],[234 456],[234 543],0);
    q.setId(1234);
    q.setSlicePlane(eOCPSlicePlane.xy);
    q.setARange([3 4]);
    q.setBRange([234 654]);
    q.setCIndex(34);
    q.addIdListPredicate(eOCPPredicate.type,eRAMONAnnoType.generic);
    q.setXyzCoord([23 345 456]);
    [t,m] = q.validate(oo.annoInfo);
    assertTrue(t);
end

% Slice  
function testAdvancedCheckingSlice    
    oo = OCP();
    oo.setAnnoToken('apiUnitTestKasthuri');
      
    q = OCPQuery(eOCPQueryType.imageSlice);

    [t,m] = q.validate(oo.annoInfo);
    assertFalse(t);
    
    q.setSliceArgs(eOCPSlicePlane.xy,[23 234],[23 34],34);
    [t,m] = q.validate(oo.annoInfo);
    assertTrue(t);    
    
    q = OCPQuery(eOCPQueryType.imageSlice);
    q.setSliceArgs(eOCPSlicePlane.xy,[23 234],[23 34],34,0);
    [t,m] = q.validate(oo.annoInfo);
    assertTrue(t);
    
    q = OCPQuery(eOCPQueryType.imageSlice);
    q.setSliceArgs(eOCPSlicePlane.xy,[23 3242453452],[23 34],34,0);
    [t,m] = q.validate(oo.annoInfo);
    assertFalse(t);
    
    q = OCPQuery(eOCPQueryType.imageSlice);
    q.setSliceArgs(eOCPSlicePlane.xy,[23 234],[23 34],oo.annoInfo.DATASET.SLICERANGE(end),0);
    [t,m] = q.validate(oo.annoInfo);
    assertTrue(t);
    q.setCIndex(oo.annoInfo.DATASET.SLICERANGE(end)+2);
    [t,m] = q.validate(oo.annoInfo);
    assertFalse(t);
    
    q = OCPQuery(eOCPQueryType.imageSlice);
    dims = oo.annoInfo.DATASET.IMAGE_SIZE(0);
    q.setSliceArgs(eOCPSlicePlane.yz,[23 234],[23 34],dims(1),0);
    [t,m] = q.validate(oo.annoInfo);
    assertTrue(t);
    q.setCIndex(dims(1)+2);
    [t,m] = q.validate(oo.annoInfo);
    assertFalse(t);
end

% RAMON Objects
function testAdvancedCheckingRAMONDenseVoxelList    
    oo = OCP();
    oo.setAnnoToken('apiUnitTestKasthuri');
     
    q = OCPQuery(eOCPQueryType.RAMONDense);
    [t,m] = q.validate(oo.annoInfo);
    assertFalse(t);
    
    q.setId(233);
    [t,m] = q.validate(oo.annoInfo);
    assertTrue(t);
    
    q.setXRange([123 345]);
    [t,m] = q.validate(oo.annoInfo);
    assertFalse(t);
    
    q.setCutoutArgs([123 345],[234 345],[234 435]);
    [t,m] = q.validate(oo.annoInfo);
    assertTrue(t);
end

% RAMON Bounding box
function testAdvancedCheckingRAMONBoundingBox   
    oo = OCP();
    oo.setAnnoToken('apiUnitTestKasthuri');
     
    q = OCPQuery(eOCPQueryType.RAMONBoundingBox);
    [t,m] = q.validate(oo.annoInfo);
    assertFalse(t);
    
    q.setId(233);
    [t,m] = q.validate(oo.annoInfo);
    assertTrue(t);
    
    q.setXRange([123 345]);
    [t,m] = q.validate(oo.annoInfo);
    assertFalse(t);
    
    q.setCutoutArgs([123 345],[234 345],[234 435]);
    [t,m] = q.validate(oo.annoInfo);
    assertTrue(t);
end

% RAMON Id list
function testAdvancedCheckingIdQuery   
    oo = OCP();
    oo.setAnnoToken('apiUnitTestKasthuri');
     
    q = OCPQuery(eOCPQueryType.RAMONIdList);
    [t,m] = q.validate(oo.annoInfo);
    assertTrue(t);
      
    q.setXRange([123 345]);
    [t,m] = q.validate(oo.annoInfo);
    assertFalse(t);
    
    q = OCPQuery(eOCPQueryType.RAMONIdList);
    q.setCutoutArgs([123 345],[234 234545456],[234 435],0);
    [t,m] = q.validate(oo.annoInfo);
    assertFalse(t);   
end

% RAMON Voxel ID by xyz
function testAdvancedCheckingVoxelXYZ  
    oo = OCP();
    oo.setAnnoToken('apiUnitTestKasthuri');
     
    q = OCPQuery(eOCPQueryType.voxelId);
    [t,m] = q.validate(oo.annoInfo);
    assertFalse(t);
    
    q.setXyzCoord([123 34 456]);    
    [t,m] = q.validate(oo.annoInfo);
    assertTrue(t);
      
    q.setResolution(0);
    q.setXyzCoord([123 345 oo.annoInfo.DATASET.SLICERANGE(2)]);
    [t,m] = q.validate(oo.annoInfo);
    assertTrue(t);
    
    q.setXyzCoord([123 345 oo.annoInfo.DATASET.SLICERANGE(2)+2]);
    [t,m] = q.validate(oo.annoInfo);
    assertFalse(t);   
end

function testAdvancedCheckingDenseMultichannel       
    %TODO: Generalize this test! Data only on dsp061 right now!
    
    oo = OCP();
    oo.setServerLocation('http://openconnecto.me');
    warning('off','OCPHdf:BadFieldChar')
    oo.setImageToken('Ex10R55');
    warning('on','OCPHdf:BadFieldChar')
    
    q = OCPQuery(eOCPQueryType.imageDense);
    q.setCutoutArgs([1000 1200],[1000 1200],[50 60],0);    
    [t,~] = q.validate(oo.imageInfo);
    assertFalse(t);
    
    assertExceptionThrown(@() q.setChannels(213), 'OCPQuery:ChannelType');
    assertExceptionThrown(@() q.setChannels('asdfasd'), 'OCPQuery:ChannelType');
    
    q.setChannels({'DAPI__3','DAPI__4','asdfasd'});
    [t,~] = q.validate(oo.imageInfo);
    assertFalse(t);
    
    q.setChannels({'DAPI__3','vGluT1__3'});
    [t,~] = q.validate(oo.imageInfo);
    assertTrue(t);
    
    q.setChannels({'Synapsin1__2'});
    [t,~] = q.validate(oo.imageInfo);
    assertTrue(t);
end






