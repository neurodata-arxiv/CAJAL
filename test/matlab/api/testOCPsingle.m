function test_suite = testOCP %#ok<STOUT>
    %% TESTOCP Unit Test suite for the OCP api class
    global ocp_force_local
    
    % This variable switches the database tokens to force to local database
    % locations if server mapping is used on default tokens.
    % You should leave this set to false unless you know what you are doing.
    ocp_force_local = false;
    % You should leave this set to false unless you know what you are doing.
    
    global target_server
    
    % Holds the server location target for the test suite. 
    % Default is 'http://openconnecto.me' 
    %target_server = 'http://brainviz1.cs.jhu.edu';
    target_server = 'http://localhost:8000';
    
    %% Init the test suite
    initTestSuite;
    
    % shut of warnings (comment this out to test warning if desired)
    warning('off','OCP:BatchWriteError');
    warning('off','OCP:RAMONResolutionEmpty');
    warning('off','OCP:MissingInitQuery');
    warning('off','OCP:CustomKVPair');
    warning('off','OCP:DefaultImageChannel');
    warning('off','OCP:NoDefaultImageChannel');
    warning('off','OCP:DefaultAnnoChannel');
    warning('off','OCP:NoDefaultAnnoChannel');
    
    % May need to update class since it looks like global use has
    % changed in new version of matlab...only really need this for unit 
    %testing so low priority right now.
    warning('off','MATLAB:declareGlobalBeforeUse');
    
end

%% Set Initial Server / Token

function testInit %#ok<*DEFNU>
    global oo
    oo = OCP(); %#ok<*NASGU>   
    
    % database bad
    assertExceptionThrown(@() oo.setServerLocation('http://openconnectooo.me'), 'OCP:ServerConnFail'); %#ok<*NODEF>
    
    % database good    
    oo.setServerLocation('openconnecto.me/') ;  
    assertEqual(oo.serverLocation,'http://openconnecto.me');

    % set server location 
    global target_server 
    oo.setServerLocation(target_server) ;
    
    % image token
    assertEqual(isempty(oo.imageInfo),true);
    oo.setImageToken('kasthuri11');
    assertEqual(oo.getImageToken(),'kasthuri11');
    assertEqual(isempty(oo.imageInfo),false);
 
    % test token loading from a file
    oo.setAnnoTokenFile(fullfile(fileparts(which('cajal3d')),'test','matlab','api','data','myToken.token'));
    assertEqual(oo.getAnnoToken(),'apiUnitTests');
    % TODO test channel 
    assertEqual(isempty(oo.annoInfo),false);    
end


function testNoToken %#ok<*DEFNU>   
    global oo    
    global ocp_force_local
    global target_server
    
    oo = OCP();    
    oo.setServerLocation(target_server);
    
    % image token
    oo.setImageToken('kasthuri11');
    
    s1 = RAMONSeed([10000 10000 50],eRAMONCubeOrientation.pos_z,124,14,[],.89,eRAMONAnnoStatus.locked,{'test',23});
    assertExceptionThrown(@() oo.createAnnotation(s1), 'OCP:MissingAnnoToken');
    
    % Anno token
    if ocp_force_local == true
        oo.setAnnoToken('apiUnitTestKasthuriLocal');
    else
        oo.setAnnoToken('apiUnitTests');
        oo.setAnnoChannel('apiUnitTestKasthuri');
    end
    
    % Set default resolutino
    oo.setDefaultResolution(1);
end

%% ###### COPY AND PASTE SINGLE UNIT TESTS BELOW ######



%% Clean up
function cleanup
    
    % Turn warnings back on.
    warning('on','OCP:BatchWriteError');
    warning('on','OCP:RAMONResolutionEmpty');    
    warning('on','OCP:MissingInitQuery');
    warning('on','OCP:CustomKVPair');
    warning('on','OCP:DefaultImageChannel');
    warning('on','OCP:NoDefaultImageChannel');
    warning('on','OCP:DefaultAnnoChannel');
    warning('on','OCP:NoDefaultAnnoChannel');
end

