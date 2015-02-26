function test_suite= testMatlabInit%#ok<STOUT>
    %testMatlabInit Unit test of the matlabInit wrapper script
    % NOTE: YOU MUST RUN THIS TEST FROM THE FRAMEWORK ROOT 
    %       (it is recommended to always run from framework root regardless)
    
    % Init the test suite
    global gtestMatlabPath 
    gtestMatlabPath = '/Applications/MATLAB_R2013a.app/bin/matlab';
    
    initTestSuite;       
end


function testGoodCallDebugFlagOff %#ok<*DEFNU>
    global gtestMatlabPath 
          
    cmd = sprintf('%s -nosplash -nodesktop -r "matlabInit(''%s/test/matlab/api/matlabInitTFunction.m'',''-d'',''5.67'',''-s'',''test string'',''-m'',''[1,2;3,4]'',''-l'',''true'',''-b'', ''0'');"',gtestMatlabPath, fileparts(which('cajal3d')));
    [~, result] = system(cmd);
        
    ind = strfind(result, '00001=');    
    assertEqual(str2double(result(ind+6:ind+11)),5.67);
        
    ind = strfind(result, '00002=');    
    assertEqual(result(ind+6:ind+16),'test string');
    
    ind = strfind(result, '00003=');    
    assertEqual(result(ind+6:ind+12),'1 2 3 4');    
    
    ind = strfind(result, '00004=');    
    assertEqual(logical(str2double(result(ind+6:ind+7))),true); 
end

function testGoodCallNoDebugFlag %#ok<*DEFNU>
    global gtestMatlabPath 
          
    cmd = sprintf('%s -nosplash -nodesktop -r "matlabInit(''%s/test/matlab/api/matlabInitTFunction.m'',''-d'',''5.67'',''-s'',''test string'',''-m'',''[1,2;3,4]'',''-l'',''true'');"',gtestMatlabPath, fileparts(which('cajal3d')));
    [~, result] = system(cmd);
        
    ind = strfind(result, '00001=');    
    assertEqual(str2double(result(ind+6:ind+11)),5.67);
        
    ind = strfind(result, '00002=');    
    assertEqual(result(ind+6:ind+16),'test string');
    
    ind = strfind(result, '00003=');    
    assertEqual(result(ind+6:ind+12),'1 2 3 4');    
    
    ind = strfind(result, '00004=');    
    assertEqual(logical(str2double(result(ind+6:ind+7))),true);   
end

function testGoodCallDebugFlagOn
    global gtestMatlabPath 
    cmd = sprintf('%s -nosplash -nodesktop -r "matlabInit(''%s/test/matlab/api/matlabInitTFunction.m'',''-d'',''5.67'',''-s'',''test string'',''-m'',''[1,2;3,4]'',''-l'',''true'',''-b'', ''1'');"',gtestMatlabPath, fileparts(which('cajal3d')));
    [~, result] = system(cmd);
        
    ind = strfind(result, '00001=');    
    assertEqual(str2double(result(ind+6:ind+11)),5.67);
        
    ind = strfind(result, '00002=');    
    assertEqual(result(ind+6:ind+16),'test string');
    
    ind = strfind(result, '00003=');    
    assertEqual(result(ind+6:ind+12),'1 2 3 4');    
    
    ind = strfind(result, '00004=');    
    assertEqual(logical(str2double(result(ind+6:ind+7))),true);   

    button = questdlg('Did debug mode function properly?',...
        'Check Debug Mode','Yes','No','Yes');
    
    assertEqual(button,'Yes');
end

function testBoolTypes
    global gtestMatlabPath 
    cmd = sprintf('%s -nosplash -nodesktop -r "matlabInit(''%s/test/matlab/api/matlabInitTFunction.m'',''-d'',''5.67'',''-s'',''test string'',''-m'',''[1,2;3,4]'',''-l'',''1'',''-b'', ''0'');"',gtestMatlabPath, fileparts(which('cajal3d')));
    [~, result] = system(cmd);
        
    ind = strfind(result, '00001=');    
    assertEqual(str2double(result(ind+6:ind+11)),5.67);
        
    ind = strfind(result, '00002=');    
    assertEqual(result(ind+6:ind+16),'test string');
    
    ind = strfind(result, '00003=');    
    assertEqual(result(ind+6:ind+12),'1 2 3 4');    
    
    ind = strfind(result, '00004=');    
    assertEqual(logical(str2double(result(ind+6:ind+7))),true);   
    
    cmd = sprintf('%s -nosplash -nodesktop -r "matlabInit(''%s/test/matlab/api/matlabInitTFunction.m'',''-d'',''5.67'',''-s'',''test string'',''-m'',''[1,2;3,4]'',''-l'',''false'',''-b'', ''0'');"',gtestMatlabPath, fileparts(which('cajal3d')));
    [~, result] = system(cmd);
        
    ind = strfind(result, '00001=');    
    assertEqual(str2double(result(ind+6:ind+11)),5.67);
        
    ind = strfind(result, '00002=');    
    assertEqual(result(ind+6:ind+16),'test string');
    
    ind = strfind(result, '00003=');    
    assertEqual(result(ind+6:ind+12),'1 2 3 4');    
    
    ind = strfind(result, '00004=');    
    assertEqual(logical(str2double(result(ind+6:ind+7))),false);   
    
    cmd = sprintf('%s -nosplash -nodesktop -r "matlabInit(''%s/test/matlab/api/matlabInitTFunction.m'',''-d'',''5.67'',''-s'',''test string'',''-m'',''[1,2;3,4]'',''-l'',''0'',''-b'', ''0'');"',gtestMatlabPath, fileparts(which('cajal3d')));
    [~, result] = system(cmd);
        
    ind = strfind(result, '00001=');    
    assertEqual(str2double(result(ind+6:ind+11)),5.67);
        
    ind = strfind(result, '00002=');    
    assertEqual(result(ind+6:ind+16),'test string');
    
    ind = strfind(result, '00003=');    
    assertEqual(result(ind+6:ind+12),'1 2 3 4');    
    
    ind = strfind(result, '00004=');    
    assertEqual(logical(str2double(result(ind+6:ind+7))),false);   
end

function testNoArgsDebugFlagOff
    global gtestMatlabPath 
    cmd = sprintf('%s -nosplash -nodesktop -r "matlabInit(''%s/test/matlab/api/matlabInitTFunctionNoArg.m'',''-b'', ''0'');"',gtestMatlabPath, fileparts(which('cajal3d')));
    [~, result] = system(cmd);
        
    ind = strfind(result, 'IT WORKED!');    
    assertEqual(isempty(ind),false);
end

function testNoArgsNoDebugFlag
    global gtestMatlabPath 
    cmd = sprintf('%s -nosplash -nodesktop -r "matlabInit(''%s/test/matlab/api/matlabInitTFunctionNoArg.m'');"',gtestMatlabPath, fileparts(which('cajal3d')));
    [~, result] = system(cmd);
        
    ind = strfind(result, 'IT WORKED!');    
    assertEqual(isempty(ind),false);
end

function testNoArgsDebugFlagOn
    global gtestMatlabPath 
    cmd = sprintf('%s -nosplash -nodesktop -r "matlabInit(''%s/test/matlab/api/matlabInitTFunctionNoArg.m'',''-b'', ''1'');"',gtestMatlabPath, fileparts(which('cajal3d')));
    [~, result] = system(cmd);
        
    ind = strfind(result, 'IT WORKED!');    
    assertEqual(isempty(ind),false);   
    

    button = questdlg('Did debug mode function properly?',...
        'Check Debug Mode','Yes','No','Yes');
    
    assertEqual(button,'Yes');
end

function testNoFlags
    global gtestMatlabPath 
    cmd = sprintf('%s -nosplash -nodesktop -r "matlabInit(''%s/test/matlab/api/matlabInitTFunction.m'',''5.67'',''test string'',''[1,2;3,4]'',''true'');"',gtestMatlabPath, fileparts(which('cajal3d')));
    [~, result] = system(cmd);
    
    ind = strfind(result, 'MATLABINIT:NOIDENTIFIERS');    
    assertEqual(isempty(ind),false);
end

function testFlagMismatch  
    global gtestMatlabPath 
    cmd = sprintf('%s -nosplash -nodesktop -r "matlabInit(''%s/test/matlab/api/matlabInitTFunction.m'',''-d'',''5.67'',''test string'',''-m'',''[1,2;3,4]'',''-l'',''true'',''-b'', ''1'');"',gtestMatlabPath, fileparts(which('cajal3d')));
    [~, result] = system(cmd);
    
    ind = strfind(result, 'MATLABINIT:IDENTIFIERMISMATCH');    
    assertEqual(isempty(ind),false);
end

function testBadFlag
    global gtestMatlabPath 
    cmd = sprintf('%s -nosplash -nodesktop -r "matlabInit(''%s/test/matlab/api/matlabInitTFunction.m'',''-f'',''5.67'',''-s'',''test string'',''-m'',''[1,2;3,4]'',''-l'',''true'',''-b'', ''1'');"',gtestMatlabPath, fileparts(which('cajal3d')));
    [~, result] = system(cmd);
    
    ind = strfind(result, 'MATLABINIT:BADIDENTIFIER');    
    assertEqual(isempty(ind),false);
end

function testHiddenFunction
    global gtestMatlabPath 
    cmd = sprintf('%s -nosplash -nodesktop -r "matlabInit(''%s/test/matlab/api/strfind.m'',''-d'',''5.67'',''-s'',''test string'',''-m'',''[1,2;3,4]'',''-l'',''true'',''-b'', ''1'');"',gtestMatlabPath, fileparts(which('cajal3d')));
    [~, result] = system(cmd);
    
    ind = strfind(result, 'MatlabInit:FunctionHidden');    
    assertEqual(isempty(ind),false);
end

function testFunctionNotFound
    global gtestMatlabPath 
    cmd = sprintf('%s -nosplash -nodesktop -r "matlabInit(''%s/test/matlab/api/strfinddd.m'',''-d'',''5.67'',''-s'',''test string'',''-m'',''[1,2;3,4]'',''-l'',''true'',''-b'', ''1'');"',gtestMatlabPath, fileparts(which('cajal3d')));
    [~, result] = system(cmd);
    
    ind = strfind(result, 'MatlabInit:FunctionNotFound');    
    assertEqual(isempty(ind),false);
end



