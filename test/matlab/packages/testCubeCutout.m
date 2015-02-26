function test_suite= testCubeCutout%#ok<STOUT>
    %testMatlabInit Unit test of the matlabInit wrapper script
    % Init the test suite
    initTestSuite;
    
    
end
function tempdummytest %#ok<*DEFNU>
   assertEqual(1,1);
end

%% Cube Cutout Preprocess Basic tests
function testInputTypesBasic %#ok<*DEFNU>
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,100,200,100,200,10,20,100,100,5,'temp.list','/usr/tmp/',0,1), 'MATLAB:TooManyInputs');
    assertExceptionThrown(@() cubeCutoutPreprocessBasic(1,'kasthuri11cc',1,100,200,100,200,10,20,100,100,5,'temp.list','/usr/tmp/',0), 'MATLAB:invalidType');
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me',1,1,100,200,100,200,10,20,100,100,5,'temp.list','/usr/tmp/',0), 'MATLAB:invalidType');
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',-1,100,200,100,200,10,20,100,100,5,'temp.list','/usr/tmp/',0), 'MATLAB:expectedNonnegative');
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,'a',200,100,200,10,20,100,100,5,'temp.list','/usr/tmp/',0), 'MATLAB:invalidType');
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,100,-21,100,200,10,20,100,100,5,'temp.list','/usr/tmp/',0), 'MATLAB:expectedNonnegative');
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,100,200,'j',200,10,20,100,100,5,'temp.list','/usr/tmp/',0), 'MATLAB:invalidType');
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,100,200,100,'k',10,20,100,100,5,'temp.list','/usr/tmp/',0), 'MATLAB:invalidType');
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,100,200,100,200,'k',20,100,100,5,'temp.list','/usr/tmp/',0), 'MATLAB:invalidType');
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,100,200,100,200,10,'i',100,100,5,'temp.list','/usr/tmp/',0), 'MATLAB:invalidType');
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,100,200,100,200,10,20,-876,100,5,'temp.list','/usr/tmp/',0), 'MATLAB:expectedNonnegative');
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,100,200,100,200,10,20,100,-876,5,'temp.list','/usr/tmp/',0), 'MATLAB:expectedNonnegative');
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,100,200,100,200,10,20,100,100,'fgdh','temp.list','/usr/tmp/',0), 'MATLAB:invalidType');
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,100,200,100,200,10,20,100,100,5,43,'/usr/tmp/',0), 'MATLAB:invalidType');
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,100,200,100,200,10,20,100,100,5,'temp.list',34,0), 'MATLAB:invalidType');
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,100,200,100,200,10,20,100,100,5,'temp.list','/usr/tmp/',3), 'MATLAB:notLessEqual');
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,100,200,100,200,10,20,100,100,5,'temp.list','/usr/tmp/',-1), 'MATLAB:expectedNonnegative');
end

function testOutOfBoundsParamsBasic %#ok<*DEFNU>
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,100,100,100,200,10,20,100,100,5,'temp.list','/usr/tmp/',0), 'cubeCutoutPreprocess:PARAMERROR');
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,100,200,100,200,10,10,100,100,5,'temp.list','/usr/tmp/',0), 'cubeCutoutPreprocess:PARAMERROR');
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,100,200,100,100,10,20,100,100,5,'temp.list','/usr/tmp/',0), 'cubeCutoutPreprocess:PARAMERROR'); 
    
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,100,200,100,200,10,20,1000,100,5,'temp.list','/usr/tmp/',0), 'cubeCutoutPreprocess:NOSOLUTION');
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,100,200,100,200,10,20,100,1000,5,'temp.list','/usr/tmp/',0), 'cubeCutoutPreprocess:NOSOLUTION');
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,100,200,100,200,10,20,100,100,50,'temp.list','/usr/tmp/',0), 'cubeCutoutPreprocess:NOSOLUTION');
    
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,100,200000,100,200,10,20,1000,100,5,'temp.list','/usr/tmp/',0), 'cubeCutoutPreprocess:PARAMERROR');
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,100,200,100,200000,10,20,100,1000,5,'temp.list','/usr/tmp/',0), 'cubeCutoutPreprocess:PARAMERROR');
    assertExceptionThrown(@() cubeCutoutPreprocessBasic('openconnecto.me','kasthuri11cc',1,100,200,100,200,10,200000,100,100,50,'temp.list','/usr/tmp/',0), 'cubeCutoutPreprocess:PARAMERROR');
end


function testPreProcessBasic %#ok<*DEFNU>
    
    serverLocation = 'openconnecto.me';
    token = 'kasthuri11cc';
    resolution = 1;
    xStart = 100;
    yStart = 200;
    zStart = 300;
    xStop = 210;
    yStop = 310;
    zStop = 322;
    xSpan = 25;
    ySpan = 50;
    zSpan = 10;
    cubeListFile = [tempname '.list'];
    cubeOutputDir = tempdir;
    print_flag = 0;
    
    cubeCutoutPreprocessBasic(serverLocation, token, resolution, ...
                                    xStart, xStop, yStart, yStop, zStart, zStop,...
                                    xSpan, ySpan, zSpan, ... 
                                    cubeListFile, cubeOutputDir, print_flag);
    
    fid = fopen(cubeListFile);
    C = textscan(fid, '%s');
    C = C{:};
    fclose(fid);
    
    assertEqual(length(C),45);
    
    % begin main block
    cube1 = OCPQuery.open(C{1});    
    assertEqual(cube1.xRange,[xStart xStart+xSpan]);
    assertEqual(cube1.yRange,[yStart yStart+ySpan]);
    assertEqual(cube1.zRange,[zStart zStart+zSpan]);
    
    % end main block
    cube1 = OCPQuery.open(C{16});    
    assertEqual(cube1.xRange,[175 200]);
    assertEqual(cube1.yRange,[250 300]);
    assertEqual(cube1.zRange,[310 320]);
    
    
    % remainder parts
    cube1 = OCPQuery.open(C{17});    
    assertEqual(cube1.xRange,[100 125]);
    assertEqual(cube1.yRange,[300 310]);
    assertEqual(cube1.zRange,[300 310]);
    
    % remainder parts
    cube1 = OCPQuery.open(C{23});    
    assertEqual(cube1.xRange,[150 175]);
    assertEqual(cube1.yRange,[300 310]);
    assertEqual(cube1.zRange,[310 320]);
    
    % remainder parts
    cube1 = OCPQuery.open(C{26});    
    assertEqual(cube1.xRange,[200 210]);
    assertEqual(cube1.yRange,[250 300]);
    assertEqual(cube1.zRange,[300 310]);
    
    % remainder parts
    cube1 = OCPQuery.open(C{33});    
    assertEqual(cube1.xRange,[150 175]);
    assertEqual(cube1.yRange,[200 250]);
    assertEqual(cube1.zRange,[320 322]);    
    
    % remainder parts
    cube1 = OCPQuery.open(C{40});    
    assertEqual(cube1.xRange,[125 150]);
    assertEqual(cube1.yRange,[300 310]);
    assertEqual(cube1.zRange,[320 322]);    
       
    % remainder parts
    cube1 = OCPQuery.open(C{45});    
    assertEqual(cube1.xRange,[200 210]);
    assertEqual(cube1.yRange,[300 310]);
    assertEqual(cube1.zRange,[320 322]);    
end


%% Test Cube Cutout
function testCubeCutoutErrors %#ok<*DEFNU>
    
    q = OCPQuery(eOCPQueryType.imageDense);
    q.setCutoutArgs([1000 1200],[1000 1200],[3000 3005],5);
    tname = tempname;
    q.save(tname);

    assertExceptionThrown(@() cubeCutout('bock11',tname,'/fake/data.mat',0, 2), 'cubeCutout:DATAFORMATERROR');
    assertExceptionThrown(@() cubeCutout(12343, tname,'/fake/data.mat',0, 0), 'MATLAB:invalidType');

end

function testCubeCutoutVolumeObject %#ok<*DEFNU>
    % make a query
    q = OCPQuery(eOCPQueryType.imageDense);
    q.setCutoutArgs([3000 3200],[3000 3200],[1000 1005],1);
    tname = tempname;
    q.save(tname);   
    
    
    % cutout data
    volFile = [tempname '.mat'];
    cubeCutout('kasthuri11',tname, volFile, 0,0);
    load(volFile);   
    
    load(fullfile(fileparts(which('cajal3d')),'test','matlab','packages','data','cubeCutout1.mat'));
    assertEqual(cube.data,savedCube.data);
    assertEqual(cube.xyzOffset,savedCube.xyzOffset);
    assertEqual(cube.resolution,savedCube.resolution);
end



%% Cube Cutout Preprocess Cuboid tests to clean out eventually
function testPreCalcCuboid_NoPad_Start_CutoutOnly %#ok<*DEFNU> 
    serverLocation = 'http://openconnecto.me/';
    token = 'kasthuri11';
    resolution = 1;
    xStart = 100;
    yStart = 100;
    zStart = 5;
    xStop = 220;
    yStop = 220;
    zStop = 40;
    xSpan = 50;
    ySpan = 50;
    zSpan = 7;
    padX = 0;
    padY = 0;
    padZ = 0;
    computeOptions = 0;
    alignZ = 1;
    shuffleFilesFlag = 0;
    cubeListFile = [tempname '.list'];
    cubeOutputDir = fullfile(tempdir,datestr(now,30));
    mergeListFile = [tempname '.list'];
    pause(2);
    mergeOutputDir = fullfile(tempdir,datestr(now,30));
    
    mkdir(cubeOutputDir);
    mkdir(mergeOutputDir);

    cubeCutoutPreprocessCuboid(serverLocation,token, resolution, ...
                                    xStart, xStop, yStart, yStop, zStart, zStop,...
                                    xSpan, ySpan, zSpan, ...
                                    padX, padY, padZ,...
                                    alignZ, computeOptions,shuffleFilesFlag,...
                                    cubeListFile, cubeOutputDir,...
                                    mergeListFile, mergeOutputDir, 0)
    
    fid = fopen(cubeListFile);
    C = textscan(fid, '%s');
    C = C{:};
    fclose(fid);    
   
    %1 - beginning
    h5file = [tempname '.h5'];
    cubeCutout('kasthuri11', C{1}, h5file, 0, 1)    
    load(C{1});
    
    data = h5read(h5file,'/0/CUTOUT');
    data = double(permute(data,[2 1 3]));
    res = h5read(h5file,'/0/RESOLUTION');
    off = h5read(h5file,'/0/XYZOFFSET');
    off = off';    
   
    assertEqual(sum(data(:)),0);
    assertEqual(size(data),[128 128 16]);
    assertEqual(double(res),double(1));
    assertEqual(double(off),double([0,0,1]));
    
    %4 - xy step
    h5file = [tempname '.h5'];
    cubeCutout('kasthuri11', C{4}, h5file, 0, 1)    
    
    data = h5read(h5file,'/0/CUTOUT');
    data = double(permute(data,[2 1 3]));
    res = h5read(h5file,'/0/RESOLUTION');
    off = h5read(h5file,'/0/XYZOFFSET');
    off = off';    
   
    assertEqual(sum(data(:)),0);
    assertEqual(size(data),[128 128 16]);
    assertEqual(double(res),double(1));
    assertEqual(double(off),double([128,128,1]));
    
    %3 - z step
    h5file = [tempname '.h5'];
    cubeCutout('kasthuri11', C{5}, h5file, 0, 1)    
    
    data = h5read(h5file,'/0/CUTOUT');
    data = double(permute(data,[2 1 3]));
    res = h5read(h5file,'/0/RESOLUTION');
    off = h5read(h5file,'/0/XYZOFFSET');
    off = off';    
   
    assertEqual(sum(data(:)),0);
    assertEqual(size(data),[128 128 16]);
    assertEqual(double(res),double(1));
    assertEqual(double(off),double([0,0,17]));
    
    %12 - end
    h5file = [tempname '.h5'];
    cubeCutout('kasthuri11', C{12}, h5file, 0, 1)    
    
    data = h5read(h5file,'/0/CUTOUT');
    data = double(permute(data,[2 1 3]));
    res = h5read(h5file,'/0/RESOLUTION');
    off = h5read(h5file,'/0/XYZOFFSET');
    off = off';    
   
    assertEqual(sum(data(:)),0);
    assertEqual(size(data),[128 128 16]);
    assertEqual(double(res),double(1));
    assertEqual(double(off),double([128,128,33]));
    
end


function testPreCalcCuboid_NoPad_End_CutoutOnly %#ok<*DEFNU> 

    serverLocation = 'openconnecto.me'; 
    token = 'kasthuri11';
    resolution = 1;
    xStart = 10000;
    yStart = 13000;
    zStart = 1800;
    xStop = 10752;
    yStop = 13312;
    zStop = 1850;
    xSpan = 260;
    ySpan = 260;
    zSpan = 15;
    padX = 0;
    padY = 0;
    padZ = 0;
    computeOptions = 0;
    shuffleFilesFlag = 0;
    alignZ = 1;
    cubeListFile = [tempname '.list'];
    cubeOutputDir = fullfile(tempdir,datestr(now,30));
    mergeListFile = [tempname '.list'];
    pause(2);
    mergeOutputDir = fullfile(tempdir,datestr(now,30));
    
    mkdir(cubeOutputDir);
    mkdir(mergeOutputDir);

    cubeCutoutPreprocessCuboid(serverLocation, token, resolution, ...
                                    xStart, xStop, yStart, yStop, zStart, zStop,...
                                    xSpan, ySpan, zSpan, ...
                                    padX, padY, padZ,...
                                    alignZ, computeOptions,shuffleFilesFlag,...
                                    cubeListFile, cubeOutputDir,...
                                    mergeListFile, mergeOutputDir, 0)
    
    fid = fopen(cubeListFile);
    C = textscan(fid, '%s');
    C = C{:};
    fclose(fid);    
    
   
    % end
    h5file = [tempname '.h5'];
    cubeCutout('kasthuri11', C{24}, h5file, 0, 1)    
    load(C{24});
    
    data = h5read(h5file,'/0/CUTOUT');
    data = double(permute(data,[2 1 3]));
    res = h5read(h5file,'/0/RESOLUTION');
    off = h5read(h5file,'/0/XYZOFFSET');
    off = off';    
   
    assertEqual(sum(data(:)),0);
    assertEqual(size(data),[128 256 9]);
    assertEqual(double(res),double(1));
    assertEqual(double(off),double([10496 13184 1841]));
end

function testPreCalcCuboid_Pad_Start_CutoutOnly %#ok<*DEFNU> 


    serverLocation = 'http://braingraph1dev.cs.jhu.edu/';
    token = 'kasthuri11';
    resolution = 1;
    xStart = 100;
    yStart = 100;
    zStart = 5;
    xStop = 220;
    yStop = 220;
    zStop = 40;
    xSpan = 50;
    ySpan = 50;
    zSpan = 7;
    padX = 50;
    padY = 50;
    padZ = 3;
    computeOptions = 0;
    alignZ = 1;
    shuffleFilesFlag = 0;
    cubeListFile = [tempname '.list'];
    cubeOutputDir = fullfile(tempdir,datestr(now,30));
    mergeListFile = [tempname '.list'];
    pause(2);
    mergeOutputDir = fullfile(tempdir,datestr(now,30));
    
    mkdir(cubeOutputDir);
    mkdir(mergeOutputDir);

    cubeCutoutPreprocessCuboid(serverLocation,token, resolution, ...
                                    xStart, xStop, yStart, yStop, zStart, zStop,...
                                    xSpan, ySpan, zSpan, ...
                                    padX, padY, padZ,...
                                    alignZ, computeOptions,shuffleFilesFlag,...
                                    cubeListFile, cubeOutputDir,...
                                    mergeListFile, mergeOutputDir, 0)
    
    fid = fopen(cubeListFile);
    C = textscan(fid, '%s');
    C = C{:};
    fclose(fid);    
   
    %1 - beginning
    h5file = [tempname '.h5'];
    cubeCutout('kasthuri11', C{1}, h5file, 0, 1)    
    load(C{1});
    
    data = h5read(h5file,'/0/CUTOUT');
    data = double(permute(data,[2 1 3]));
    res = h5read(h5file,'/0/RESOLUTION');
    off = h5read(h5file,'/0/XYZOFFSET');
    off = off';    
   
    assertEqual(sum(data(:)),0);
    assertEqual(size(data),[178 178 19]);
    assertEqual(double(res),double(1));
    assertEqual(double(off),double([0,0,1]));
    
    %4 - xy step
    h5file = [tempname '.h5'];
    cubeCutout('kasthuri11', C{4}, h5file, 0, 1)    
    
    data = h5read(h5file,'/0/CUTOUT');
    data = double(permute(data,[2 1 3]));
    res = h5read(h5file,'/0/RESOLUTION');
    off = h5read(h5file,'/0/XYZOFFSET');
    off = off';    
   
    assertEqual(sum(data(:)),0);
    assertEqual(size(data),[228 228 19]);
    assertEqual(double(res),double(1));
    assertEqual(double(off),double([78,78,1]));
    
    %3 - z step
    h5file = [tempname '.h5'];
    cubeCutout('kasthuri11', C{5}, h5file, 0, 1)    
    
    data = h5read(h5file,'/0/CUTOUT');
    data = double(permute(data,[2 1 3]));
    res = h5read(h5file,'/0/RESOLUTION');
    off = h5read(h5file,'/0/XYZOFFSET');
    off = off';    
   
    assertEqual(sum(data(:)),0);
    assertEqual(size(data),[178 178 22]);
    assertEqual(double(res),double(1));
    assertEqual(double(off),double([0,0,14]));
    
    %12 - end
    h5file = [tempname '.h5'];
    cubeCutout('kasthuri11', C{12}, h5file, 0, 1)    
    
    data = h5read(h5file,'/0/CUTOUT');
    data = double(permute(data,[2 1 3]));
    res = h5read(h5file,'/0/RESOLUTION');
    off = h5read(h5file,'/0/XYZOFFSET');
    off = off';    
   
    assertEqual(sum(data(:)),0);
    assertEqual(size(data),[228 228 22]);
    assertEqual(double(res),double(1));
    assertEqual(double(off),double([78,78,30]));
end

function testPreCalcCuboid_Pad_End_CutoutOnly %#ok<*DEFNU> 

    serverLocation = 'http://braingraph1dev.cs.jhu.edu/'; 
    token = 'kasthuri11';
    resolution = 1;
    xStart = 10000;
    yStart = 13000;
    zStart = 1800;
    xStop = 10752;
    yStop = 13312;
    zStop = 1850;
    xSpan = 260;
    ySpan = 260;
    zSpan = 15;
    padX = 50;
    padY = 50;
    padZ = 3;
    computeOptions = 0;
    shuffleFilesFlag = 0;
    alignZ = 1;
    cubeListFile = [tempname '.list'];
    cubeOutputDir = fullfile(tempdir,datestr(now,30));
    mergeListFile = [tempname '.list'];
    pause(2);
    mergeOutputDir = fullfile(tempdir,datestr(now,30));
    
    mkdir(cubeOutputDir);
    mkdir(mergeOutputDir);

    cubeCutoutPreprocessCuboid(serverLocation, token, resolution, ...
                                    xStart, xStop, yStart, yStop, zStart, zStop,...
                                    xSpan, ySpan, zSpan, ...
                                    padX, padY, padZ,...
                                    alignZ, computeOptions,shuffleFilesFlag,...
                                    cubeListFile, cubeOutputDir,...
                                    mergeListFile, mergeOutputDir, 0)
    
    fid = fopen(cubeListFile);
    C = textscan(fid, '%s');
    C = C{:};
    fclose(fid);    
    
   
    % end
    h5file = [tempname '.h5'];
    cubeCutout('kasthuri11', C{24}, h5file, 0, 1)    
    load(C{24});
    
    data = h5read(h5file,'/0/CUTOUT');
    data = double(permute(data,[2 1 3]));
    res = h5read(h5file,'/0/RESOLUTION');
    off = h5read(h5file,'/0/XYZOFFSET');
    off = off';    
   
    assertEqual(sum(data(:)),0);
    assertEqual(size(data),[178 306 12]);
    assertEqual(double(res),double(1));
    assertEqual(double(off),double([10446 13134 1838]));
end


function testPreCalcCuboid_NoPad_Start_CutoutMerge %#ok<*DEFNU> 
    serverLocation = 'http://braingraph1dev.cs.jhu.edu/';
    token = 'kasthuri11';
    resolution = 1;
    xStart = 100;
    yStart = 100;
    zStart = 5;
    xStop = 6000;
    yStop = 6000;
    zStop = 600;
    xSpan = 1024;
    ySpan = 1024;
    zSpan = 48;
    padX = 0;
    padY = 0;
    padZ = 0;
    computeOptions = 2;
    alignZ = 1;
    shuffleFilesFlag = 0;
    cubeListFile = [tempname '.list'];
    cubeOutputDir = fullfile(tempdir,datestr(now,30));
    mergeListFile = [tempname '.list'];
    pause(2);
    mergeOutputDir = fullfile(tempdir,datestr(now,30));
    
    mkdir(cubeOutputDir);
    mkdir(mergeOutputDir);

    cubeCutoutPreprocessCuboid(serverLocation,token, resolution, ...
                                    xStart, xStop, yStart, yStop, zStart, zStop,...
                                    xSpan, ySpan, zSpan, ...
                                    padX, padY, padZ,...
                                    alignZ, computeOptions,shuffleFilesFlag,...
                                    cubeListFile, cubeOutputDir,...
                                    mergeListFile, mergeOutputDir, 0)
    
    fid = fopen(mergeListFile);
    C = textscan(fid, '%s');
    C = C{:};
    fclose(fid);    
   
    %Z - beginning
    h5file = [tempname '.h5'];
    cubeCutout('kasthuri11', C{1}, h5file, 0, 1)    
    load(C{1});
    
    data = h5read(h5file,'/0/CUTOUT');
    data = double(permute(data,[2 1 3]));
    res = h5read(h5file,'/0/RESOLUTION');
    off = h5read(h5file,'/0/XYZOFFSET');
    off = off';    
   
    assertEqual(size(data),[2048 2048 2]);
    assertEqual(double(res),double(1));
    assertEqual(double(off),double([0,0,48]));
    
    %Z - y rem 
    h5file = [tempname '.h5'];
    cubeCutout('kasthuri11', C{2}, h5file, 0, 1)    
    
    data = h5read(h5file,'/0/CUTOUT');
    data = double(permute(data,[2 1 3]));
    res = h5read(h5file,'/0/RESOLUTION');
    off = h5read(h5file,'/0/XYZOFFSET');
    off = off';    
   
    assertEqual(size(data),[1920 2048 2]);
    assertEqual(double(res),double(1));
    assertEqual(double(off),double([0,4096,48]));
    
    %Z - x step 
    h5file = [tempname '.h5'];
    cubeCutout('kasthuri11', C{3}, h5file, 0, 1)    
    
    data = h5read(h5file,'/0/CUTOUT');
    data = double(permute(data,[2 1 3]));
    res = h5read(h5file,'/0/RESOLUTION');
    off = h5read(h5file,'/0/XYZOFFSET');
    off = off';    
   
    assertEqual(size(data),[2048 2048 2]);
    assertEqual(double(res),double(1));
    assertEqual(double(off),double([2048,0,48]));
    
    %Z - x rem 
    h5file = [tempname '.h5'];
    cubeCutout('kasthuri11', C{5}, h5file, 0, 1)    
    
    data = h5read(h5file,'/0/CUTOUT');
    data = double(permute(data,[2 1 3]));
    res = h5read(h5file,'/0/RESOLUTION');
    off = h5read(h5file,'/0/XYZOFFSET');
    off = off';    
   
    assertEqual(size(data),[2048 1920 2]);
    assertEqual(double(res),double(1));
    assertEqual(double(off),double([4096,0,48]));
    
    %Z - y step 
    h5file = [tempname '.h5'];
    cubeCutout('kasthuri11', C{6}, h5file, 0, 1)    
    
    data = h5read(h5file,'/0/CUTOUT');
    data = double(permute(data,[2 1 3]));
    res = h5read(h5file,'/0/RESOLUTION');
    off = h5read(h5file,'/0/XYZOFFSET');
    off = off';    
   
    assertEqual(size(data),[2048 2048 2]);
    assertEqual(double(res),double(1));
    assertEqual(double(off),double([0,2048,48]));
    
    %X - y step 
    h5file = [tempname '.h5'];
    cubeCutout('kasthuri11', C{134}, h5file, 0, 1)    
    
    data = h5read(h5file,'/0/CUTOUT');
    data = double(permute(data,[2 1 3]));
    res = h5read(h5file,'/0/RESOLUTION');
    off = h5read(h5file,'/0/XYZOFFSET');
    off = off';    
   
    assertEqual(size(data),[1920 2 96]);
    assertEqual(double(res),double(1));
    assertEqual(double(off),double([1023,4096,1]));
    
    %X - y rem 
    h5file = [tempname '.h5'];
    cubeCutout('kasthuri11', C{263}, h5file, 0, 1)    
    
    data = h5read(h5file,'/0/CUTOUT');
    data = double(permute(data,[2 1 3]));
    res = h5read(h5file,'/0/RESOLUTION');
    off = h5read(h5file,'/0/XYZOFFSET');
    off = off';    
   
    assertEqual(size(data),[1920 2 96]);
    assertEqual(double(res),double(1));
    assertEqual(double(off),double([5119,4096,385]));
    
end


%% Cube Cutout Preprocess Advanced Tests

% function testPreCalcAdvanced_NoPad_Start_CutoutMerge %#ok<*DEFNU> 
%     serverLocation = 'http://braingraph1dev.cs.jhu.edu/';
%     token = 'kasthuri11cc';
%     resolution = 1;
%     xStart = 100;
%     yStart = 100;
%     zStart = 5;
%     xStop = 6000;
%     yStop = 6000;
%     zStop = 600;
%     xSpan = 1000;
%     ySpan = 1000;
%     zSpan = 40;
%     padX = 0;
%     padY = 0;
%     padZ = 0;
%     alignXY = 1;
%     alignZ = 1;
%     computeOptions = 1;
%     shuffleCutoutFilesFlag = 0;
%     shuffleMergeFilesFlag = 0;
%     cubeListFile = [tempname '.list'];
%     cubeOutputDir = tempdir;
%     mergeListFile = [tempname '.txt'];
%     pause(2);
%     mergeOutputDir = tempdir;
%     
%     cubeCutoutPreprocessAdvanced(serverLocation, token, resolution, ...
%                                     xStart, xStop, yStart, yStop, zStart, zStop,...
%                                     xSpan, ySpan, zSpan, ...
%                                     padX, padY, padZ,...
%                                     alignXY, alignZ,...
%                                     computeOptions, shuffleCutoutFilesFlag, shuffleMergeFilesFlag, ......
%                                     cubeListFile, cubeOutputDir,...
%                                     mergeListFile, mergeOutputDir, 0)
%     
%     fid = fopen(mergeListFile);
%     C = textscan(fid, '%s');
%     C = C{:};
%     fclose(fid);    
%    
%     %Z - beginning
%     h5file = [tempname '.h5'];
%     cubeCutout('kasthuri11', C{1}, h5file, 0, 1)    
%     load(C{1});
%     
%     data = h5read(h5file,'/0/CUTOUT');
%     data = double(permute(data,[2 1 3]));
%     res = h5read(h5file,'/0/RESOLUTION');
%     off = h5read(h5file,'/0/XYZOFFSET');
%     off = off';    
%    
%     assertEqual(size(data),[2560 2560 2]);
%     assertEqual(double(res),double(1));
%     assertEqual(double(off),double([0,0,48]));
%     
%     %Z - y rem 
%     h5file = [tempname '.h5'];
%     cubeCutout('kasthuri11', C{2}, h5file, 0, 1)    
%     
%     data = h5read(h5file,'/0/CUTOUT');
%     data = double(permute(data,[2 1 3]));
%     res = h5read(h5file,'/0/RESOLUTION');
%     off = h5read(h5file,'/0/XYZOFFSET');
%     off = off';    
%    
%     assertEqual(size(data),[896 2560 2]);
%     assertEqual(double(res),double(1));
%     assertEqual(double(off),double([0,5120,48]));
%     
%     %Z - x step 
%     h5file = [tempname '.h5'];
%     cubeCutout('kasthuri11', C{3}, h5file, 0, 1)    
%     
%     data = h5read(h5file,'/0/CUTOUT');
%     data = double(permute(data,[2 1 3]));
%     res = h5read(h5file,'/0/RESOLUTION');
%     off = h5read(h5file,'/0/XYZOFFSET');
%     off = off';    
%    
%     assertEqual(size(data),[2560 2560 2]);
%     assertEqual(double(res),double(1));
%     assertEqual(double(off),double([2560,0,48]));
%     
%     %Z - x rem 
%     h5file = [tempname '.h5'];
%     cubeCutout('kasthuri11', C{5}, h5file, 0, 1)    
%     
%     data = h5read(h5file,'/0/CUTOUT');
%     data = double(permute(data,[2 1 3]));
%     res = h5read(h5file,'/0/RESOLUTION');
%     off = h5read(h5file,'/0/XYZOFFSET');
%     off = off';    
%    
%     assertEqual(size(data),[2560 896 2]);
%     assertEqual(double(res),double(1));
%     assertEqual(double(off),double([5120,0,48]));
%     
%     %Z - y step 
%     h5file = [tempname '.h5'];
%     cubeCutout('kasthuri11', C{6}, h5file, 0, 1)    
%     
%     data = h5read(h5file,'/0/CUTOUT');
%     data = double(permute(data,[2 1 3]));
%     res = h5read(h5file,'/0/RESOLUTION');
%     off = h5read(h5file,'/0/XYZOFFSET');
%     off = off';    
%    
%     assertEqual(size(data),[2560 2560 2]);
%     assertEqual(double(res),double(1));
%     assertEqual(double(off),double([0,2560,48]));
%     
%     %X - y step 
%     h5file = [tempname '.h5'];
%     cubeCutout('kasthuri11', C{134}, h5file, 0, 1)    
%     
%     data = h5read(h5file,'/0/CUTOUT');
%     data = double(permute(data,[2 1 3]));
%     res = h5read(h5file,'/0/RESOLUTION');
%     off = h5read(h5file,'/0/XYZOFFSET');
%     off = off';    
%    
%     assertEqual(size(data),[2560 2 608]);
%     assertEqual(double(res),double(1));
%     assertEqual(double(off),double([1023,2560,1]));
%     
%     %X - y rem 
%     h5file = [tempname '.h5'];
%     cubeCutout('kasthuri11', C{135}, h5file, 0, 1)    
%     
%     data = h5read(h5file,'/0/CUTOUT');
%     data = double(permute(data,[2 1 3]));
%     res = h5read(h5file,'/0/RESOLUTION');
%     off = h5read(h5file,'/0/XYZOFFSET');
%     off = off';    
%    
%     assertEqual(size(data),[896 2 608]);
%     assertEqual(double(res),double(1));
%     assertEqual(double(off),double([1023,5120,1]));
%     
%     %Y - x rem
%     h5file = [tempname '.h5'];
%     cubeCutout('kasthuri11', C{150}, h5file, 0, 1)    
%     
%     data = h5read(h5file,'/0/CUTOUT');
%     data = double(permute(data,[2 1 3]));
%     res = h5read(h5file,'/0/RESOLUTION');
%     off = h5read(h5file,'/0/XYZOFFSET');
%     off = off';    
%    
%     assertEqual(size(data),[2 896 608]);
%     assertEqual(double(res),double(1));
%     assertEqual(double(off),double([5120,1023,1]));
%     
%     %Y - x step 
%     h5file = [tempname '.h5'];
%     cubeCutout('kasthuri11', C{149}, h5file, 0, 1)    
%     
%     data = h5read(h5file,'/0/CUTOUT');
%     data = double(permute(data,[2 1 3]));
%     res = h5read(h5file,'/0/RESOLUTION');
%     off = h5read(h5file,'/0/XYZOFFSET');
%     off = off';    
%    
%     assertEqual(size(data),[2 2560 608]);
%     assertEqual(double(res),double(1));
%     assertEqual(double(off),double([2560,1023,1]));
%    
%     
% end
% 
% 
