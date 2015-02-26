function test_suite= testRAMONVolume%#ok<STOUT>
    %TESTSEED Unit test of the seed datatype
    
    %% Init the test suite
    initTestSuite;
    
    
end


function testTooManyArguments %#ok<*DEFNU>
    % Create volumeobject with too many arguments
    d = magic(10);
    assertExceptionThrown(@() RAMONVolume(d,eRAMONDataFormat.dense,[100 123 234],...
        2,23,54), 'RAMONVolume:TooManyArguments');
end

function testCreateGoodObjAndSetProps %#ok<*DEFNU>
    % Create good VolumeObjects
    v = RAMONVolume();
    assertEqual(v.data,[]);
    assertEqual(v.xyzOffset,[]);
    assertEqual(v.resolution,[]);
    assertEqual(v.name,'Volume1');
    assertEqual(v.sliceDisplayIndex,1);
    assertEqual(v.dataFormat,eRAMONDataFormat.dense);
    
    d = magic(10);
    assertExceptionThrown(@() RAMONVolume(d), 'RAMONVolume:MissingDataFormat');
       
    v = RAMONVolume(d,eRAMONDataFormat.dense);
    assertEqual(v.data,d);
    assertEqual(v.xyzOffset,[]);
    assertEqual(v.resolution,[]);
    assertEqual(v.name,'Volume1');
    assertEqual(v.sliceDisplayIndex,1);  
    assertEqual(v.dataFormat,eRAMONDataFormat.dense);
    
    v = RAMONVolume(d,eRAMONDataFormat.dense,[100 123 234]);
    assertEqual(v.data,d);
    assertEqual(v.xyzOffset,[100 123 234]);
    assertEqual(v.resolution,[]);
    assertEqual(v.name,'Volume1');
    assertEqual(v.sliceDisplayIndex,1); 
    assertEqual(v.dataFormat,eRAMONDataFormat.dense);
    
    v = RAMONVolume(d,eRAMONDataFormat.dense,[100 123 234],2);
    assertEqual(v.data,d);
    assertEqual(v.xyzOffset,[100 123 234]);
    assertEqual(v.resolution,2);
    assertEqual(v.name,'Volume1');
    assertEqual(v.sliceDisplayIndex,1);
    assertEqual(v.dataFormat,eRAMONDataFormat.dense);
    
    v = v.setName('MagicVolume');
    assertEqual(v.name,'MagicVolume');
    
    v = v.setXyzOffset([10 10 100]);
    assertEqual(v.xyzOffset,[10 10 100]);
    
    v = v.setResolution(4);
    assertEqual(v.resolution,4);
    v = v.setResolution([]);
    assertEqual(v.resolution,[]);
    
    v = v.setCutout([]);
    assertEqual(v.data,[]);
    
    v = v.setVoxelList([]);
    assertEqual(v.data,[]);
end

function testVoxelList %#ok<*DEFNU>
    d = randi(100,300,3);    
    
    v = RAMONVolume(d,eRAMONDataFormat.voxelList,[100 123 234],0);
    
    assertEqual(v.data,d);
    assertEqual(v.xyzOffset,[100 123 234]);
    assertEqual(v.resolution,0);
    assertEqual(v.name,'Volume1');
    assertEqual(v.sliceDisplayIndex,1);
    assertEqual(v.dataFormat,eRAMONDataFormat.voxelList);
    
    v = RAMONVolume();
    v.setVoxelList(d);
    v.setXyzOffset([100 123 234]);
    
    assertEqual(v.data,d);
    assertEqual(v.xyzOffset,[100 123 234]);
    assertEqual(v.resolution,[]);
    assertEqual(v.name,'Volume1');
    assertEqual(v.sliceDisplayIndex,1);
    assertEqual(v.dataFormat,eRAMONDataFormat.voxelList);
end

function testCoordXForms %#ok<*DEFNU>
%     load(fullfile(fileparts(which('cajal3d')),'test','matlab','api','data','cubeBock.mat'));
%     v = RAMONVolume(savedCube,[1000 2000 100]);
    
    %TODO: add tests
end

function testImageBoxSingleAnnotationCube
    % Create random volume object
    load(fullfile(fileparts(which('cajal3d')),'test','matlab','api','data','cubeBock.mat'));
    load(fullfile(fileparts(which('cajal3d')),'test','matlab','api','data','annotation.mat'));
    vo1 = RAMONVolume(savedCube,eRAMONDataFormat.dense);
    
    h = image(vo1);
    h.associate(anno1,'annotation');
    uiwait(h.hFig);
    clear h
    
    button = questdlg('Did the Volume Image Box function Properly?',...
        'Check Image Box','Yes','No','Yes');
    
    assertEqual(button,'Yes');
end

function testImageBoxMultiAnnotationCube
    % Create random volume object
    load(fullfile(fileparts(which('cajal3d')),'test','matlab','api','data','cubeBock.mat'));
    load(fullfile(fileparts(which('cajal3d')),'test','matlab','api','data','annotation.mat'));
    load(fullfile(fileparts(which('cajal3d')),'test','matlab','api','data','annotation2.mat'));
    vo1 = RAMONVolume(savedCube,eRAMONDataFormat.dense);
    
    h = image(vo1);
    h.associate(anno1,'annotation');
    h.associate(anno2,'annotation2');
    uiwait(h.hFig);
    clear h
    
    button = questdlg('Did the Volume Image Box function Properly?',...
        'Check Image Box','Yes','No','Yes');
    
    assertEqual(button,'Yes');
end

function testDeepCopyDense
    % Create default seed
    d = magic(10);
    s1 = RAMONVolume(d,eRAMONDataFormat.dense,[100 123 234],2);   
    s2 = s1.clone();
    
    assertEqual(s1.data, s2.data);
    assertEqual(s1.xyzOffset, s2.xyzOffset);
    assertEqual(s1.resolution, s2.resolution);
    assertEqual(s1.dataFormat, s2.dataFormat);
    assertEqual(s1.id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    assertEqual(s1.author, s2.author);
end

function testDeepCopyNoVoxels
    % Create default seed
    d = magic(10);
    s1 = RAMONVolume(d,eRAMONDataFormat.dense,[100 123 234],2);   
    s2 = s1.clone('novoxels');
    
    assertEqual([], s2.data);
    assertEqual([], s2.xyzOffset);
    assertEqual(s1.resolution, s2.resolution);
    assertEqual(eRAMONDataFormat.dense, s2.dataFormat);
    assertEqual(s1.id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    assertEqual(s1.author, s2.author);
end



function testDeepCopyVoxel
    % Create default seed
    d = randi(100,300,3);    
    s1 = RAMONVolume(d,eRAMONDataFormat.voxelList,[100 123 234],2);   
    s2 = s1.clone();
    
    assertEqual(s1.data, s2.data);
    assertEqual(s1.xyzOffset, s2.xyzOffset);
    assertEqual(s1.resolution, s2.resolution);
    assertEqual(s1.dataFormat, s2.dataFormat);
    assertEqual(s1.id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    assertEqual(s1.author, s2.author);
end


function testDeepCopyBB  
    s1 = RAMONVolume([12 324 45],eRAMONDataFormat.boundingBox,[100 123 234],2);   
    s2 = s1.clone();
    
    assertEqual(s1.data, s2.data);
    assertEqual(s1.xyzOffset, s2.xyzOffset);
    assertEqual(s1.resolution, s2.resolution);
    assertEqual(s1.dataFormat, s2.dataFormat);
    assertEqual(s1.id,s2.id);
    assertEqual(s1.confidence,s2.confidence);
    assertEqual(s1.status,s2.status);
    assertEqual(s1.author, s2.author);
end


function testVoxelCount
    
    d = repmat(magic(10),[1,1,20]);
    v1 = RAMONVolume(d,eRAMONDataFormat.dense,[100 123 234],2); 
    assertEqual(v1.voxelCount, 2000);
    
    d = randi(100,326,3);        
    v2 = RAMONVolume(d,eRAMONDataFormat.voxelList,[100 123 234],0); 
    assertEqual(v2.voxelCount, 326);
    
end

function testToVoxelList
    clear d
    d(:,:,1) = [1,1,1;0,0,1;0,0,1;0,0,0];    
    d(:,:,2) = [1,1,1;1,1,1;1,1,1;0,0,0];
    d(:,:,3) = [1,0,0;1,0,0;1,1,1;0,1,1];
    
    v1 = RAMONVolume(d,eRAMONDataFormat.dense,[1 1 1],0); 
    v1.toVoxelList();
        
    load(fullfile(fileparts(which('cajal3d')),'test','matlab','api','data','tovoxellist.mat'));
    
    assertEqual(v1.data,voxellist);
    
    v1 = RAMONVolume(d,eRAMONDataFormat.dense,[100 250 25],0); 
    v1.toVoxelList();
        
    load(fullfile(fileparts(which('cajal3d')),'test','matlab','api','data','tovoxellist2.mat'));
    
    assertEqual(v1.data,voxellist);
end

function testToCutout
    clear d
    d(1,:) = [1 1 1];    
    d(2,:) = [2 2 2];    
    d(3,:) = [3 3 3];   
    d(4,:) = [1 4 3]; 
    d(5,:) = [2 4 3]; 
    d(6,:) = [3 4 3];
    
    v1 = RAMONVolume(d,eRAMONDataFormat.voxelList,[],0); 
    v1.toCutout();
    
    load(fullfile(fileparts(which('cajal3d')),'test','matlab','api','data','tocutout.mat'));    
    assertEqual(v1.data,cutout);
end


function testlocal2Global
    
    clear d
    d(:,:,1) = [1,1,1;0,0,1;0,0,1;0,0,0];    
    d(:,:,2) = [1,1,1;1,1,1;1,1,1;0,0,0];
    d(:,:,3) = [1,0,0;1,0,0;1,1,1;0,1,1];
    
    v1 = RAMONVolume(d,eRAMONDataFormat.dense,[100 25 350],0); 
    
    points = [1,1,1;1 2 3];
    
    globalPts = v1.local2Global(points);
    assertEqual(globalPts(1,:),[100,25,350]);
    assertEqual(globalPts(2,:),[100,26,352]);    
end


function testglobal2Local
    
    clear d
    d(:,:,1) = [1,1,1;0,0,1;0,0,1;0,0,0];    
    d(:,:,2) = [1,1,1;1,1,1;1,1,1;0,0,0];
    d(:,:,3) = [1,0,0;1,0,0;1,1,1;0,1,1];
    
    v1 = RAMONVolume(d,eRAMONDataFormat.dense,[100 25 350],0); 
    
    points = [101,25,351;100 26 352];
    
    localPts = v1.global2Local(points);
    assertEqual(localPts(1,:),[2,1,2]);
    assertEqual(localPts(2,:),[1,2,3]); 
    
    
%     points = [1010,25,351;100 26 352];    
%     localPts = v1.global2Local(points);
end






