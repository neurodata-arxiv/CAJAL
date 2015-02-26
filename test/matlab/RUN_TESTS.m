function RUN_TESTS(varargin)
    %RUN_TESTS Unit Test Driver ***********************************************
    %
    % This function collects and runs all unit tests in the /test/matlab
    % directory.  If no arguments are given it will run all tests.  If you pass
    % a test suite name(s) it will only run that(those) test suite(s).  Pass -l
    % for a listing of all test suites available.
    %
    % Author: Dean Kleissas
    %        dean.kleissas@apljhu.edu
    %        version 0.2
    %        Last updated: 03-13-2012
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Copyright 2015 The Johns Hopkins University / Applied Physics Laboratory 
    % All Rights Reserved. 
    % Contact the JHU/APL Office of Technology Transfer for any additional rights.  
    % www.jhuapl.edu/ott
    %  
    % Licensed under the Apache License, Version 2.0 (the "License");
    % you may not use this file except in compliance with the License.
    % You may obtain a copy of the License at
    %  
    %     http://www.apache.org/licenses/LICENSE-2.0
    %  
    % Unless required by applicable law or agreed to in writing, software
    % distributed under the License is distributed on an "AS IS" BASIS,
    % WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    % See the License for the specific language governing permissions and
    % limitations under the License.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %% MATLAB API Tests
    %runtests(fullfile(pwd,'test','matlab','api'));
    
    requireMatlabConfig = {'testMatlabInit'};
    requireUI = {'testRAMONVolume','testRandomForest'};
    windowsSkip = {'testLocalDatabaseInterface','testMatlabInit'};
    semaphoreSkip = {'testOCPDistributedSemaphore'};
    
    
    %% Parse Input Args
    clc
    
    if nargin > 0
        % Check for list flag
        if strcmp(varargin(1),'-l')
            printTestList(searchTestDir());
            return;
        end
    end
    
    %% Prep Tests
    
    % Search Test Directory for Tests    
    files = rdir(fullfile(fileparts(which('cajal3d')),'test','matlab','**','*.m'));
    allMFiles = reshape({files.name},length(files),1);
    index = strfind(allMFiles,'xunit');
    index = cellfun(@isempty,index);
    index2 = strfind(allMFiles,'RUN_TESTS');
    index2 = cellfun(@isempty,index2);
    index = index - ~index2;
    if sum(index) == 0
        ex = MException('RUN_TESTS:TestsNotFound','No Tests Found in /test/matlab');
        throw(ex);
    end
    files(~index) = [];
    
    foundTests = reshape({files.name},length(files),1);
    for ii = 1:length(foundTests)
        ind1 = strfind(foundTests(ii),filesep);
        ind2 = strfind(foundTests(ii),'.');
        fname = foundTests(ii);
        fname = fname{:};
        ind1 = ind1{:};
        foundTests{ii} = fname(ind1(end)+1:ind2{1}-1);
    end
    
    % Remove any file without "test" in the name
    index3 = strfind(foundTests,'test');
    index3 = cellfun(@isempty,index3);
    foundTests(index3) = [];
    
    % Select only Tests Specified (if needed) and verify they exist
    testMatches = zeros(1,length(foundTests));
    if nargin > 0
        for ii = 1:nargin
            ind = strfind(foundTests,varargin{ii});
            ind = find(cellfun(@isempty,ind) == 0);
            if isempty(ind)
                ex = MException('RUN_TESTS:TestSuiteNotFound',sprintf('The specified test suite ''%s'' was not found.',varargin{ii}));
                throw(ex);
            else
                if length(ind) > 1
                    % try to double check accuracy and then filter
                    remove = [];
                    for jj = 1:length(ind)
                        if ~strcmpi(foundTests(ind(jj)),varargin{ii})
                            remove = cat(1,remove,jj);
                        end
                    end
                    ind(remove) = [];
                    
                    % check again
                    if length(ind) > 1
                        ex = MException('RUN_TESTS:DuplicateTestSuites','Duplicate Test Suites found.  Verify Test Directory.');
                        throw(ex);
                    end
                end
                testMatches(ind) = 1;
            end
        end
        
        % set tests to run
        testsToRun = foundTests;
        testsToRun(~testMatches) = [];
    else
        testsToRun = foundTests;
    end
    
    %% Run Tests
    
    fprintf('## Starting Unit Tests ##\n\n\n');
    
    if ispc
        %% Check for tests that don't work on windows
        winTestsExist = 0;
        winTestInds = [];
        winTests = '';
        for ii = 1:length(windowsSkip)
            index = strfind(testsToRun,windowsSkip{ii});
            index = cellfun(@isempty,index);
            if sum(index) ~= length(index)
                winTestsExist = 1;
                winTests = sprintf('%s%s\n',winTests,requireUI{ii});
                winTestInds = cat(1,winTestInds,find(index==0));
            end
        end
        
        if winTestsExist == 1
            testsToRun(winTestInds) = [];
        end    
    end
    
    
    %% Check for matlab init tests
    uiTestsExist = 0;
    uiTestInds = [];
    uiTests = '';
    for ii = 1:length(requireMatlabConfig)
        index = strfind(testsToRun,requireMatlabConfig{ii});
        index = cellfun(@isempty,index);
        if sum(index) ~= length(index)
            uiTestsExist = 1;
            uiTests = sprintf('%s%s\n',uiTests,requireMatlabConfig{ii});
            uiTestInds = cat(1,uiTestInds,find(index==0));
        end
    end
    
    if uiTestsExist == 1        
        loopflag = 1;
        questStr = sprintf('The following unit test requires testMatlabInit.m to be configured:\n\n%s \n\nDo you still want run this test? (Y or N):',...
            uiTests);
        strResponse = input(questStr, 's');
        
        while loopflag == 1
            
            switch strResponse
                case {'Y','y'}
                    break;
                case {'N','n'}
                    testsToRun(uiTestInds) = [];
                    break;
                otherwise
                    strResponse = input('Please enter either "Y" for yes or "N" for no:', 's');
            end
        end
    end
    fprintf('\n');
    
    %% Check for user interface required unit tests
    uiTestsExist = 0;
    uiTestInds = [];
    uiTests = '';
    for ii = 1:length(requireUI)
        index = strfind(testsToRun,requireUI{ii});
        index = cellfun(@isempty,index);
        if sum(index) ~= length(index)
            uiTestsExist = 1;
            uiTests = sprintf('%s%s\n',uiTests,requireUI{ii});
            uiTestInds = cat(1,uiTestInds,find(index==0));
        end
    end
    
    if uiTestsExist == 1        
        loopflag = 1;
        questStr = sprintf('The following unit test(s) require the GUI and/or user interaction and are currently included:\n\n%s \n\nDo you still want run these tests? (Y or N):',...
            uiTests);
        strResponse = input(questStr, 's');
        
        while loopflag == 1
            
            switch strResponse
                case {'Y','y'}
                    break;
                case {'N','n'}
                    testsToRun(uiTestInds) = [];
                    break;
                otherwise
                    strResponse = input('Please enter either "Y" for yes or "N" for no:', 's');
            end
        end
    end
    
    
    fprintf('\n');
    %% Check for distributed semaphore required unit tests
    dsTestsExist = 0;
    dTestInds = [];
    dTests = '';
    for ii = 1:length(semaphoreSkip)
        index = strfind(testsToRun,semaphoreSkip{ii});
        index = cellfun(@isempty,index);
        if sum(index) ~= length(index)
            dsTestsExist = 1;
            dTests = sprintf('%s%s\n',dTests,semaphoreSkip{ii});
            dTestInds = cat(1,dTestInds,find(index==0));
        end
    end
    
    if dsTestsExist == 1        
        loopflag = 1;
        questStr = sprintf('\nThe following unit test require the distributed semaphore installed and configured in the API:\n\n%s \n\nDo you still want run these test(s)? (Y or N):',...
            dTests);
        strResponse = input(questStr, 's');
        
        while loopflag == 1
            
            switch strResponse
                case {'Y','y'}
                    break;
                case {'N','n'}
                    testsToRun(dTestInds) = [];
                    break;
                otherwise
                    strResponse = input('Please enter either "Y" for yes or "N" for no:', 's');
            end
        end
    end
    
    
    fprintf('%d Test Suites selected out of %d Test Suites discovered\n\n',length(testsToRun),length(foundTests));
    status = zeros(1,length(testsToRun));
    
    for ii = 1:length(testsToRun)
        % Kick off each test Suite individually
        fprintf('<><><><> Running Test Suite %d of %d <><><><><><><><><><>\n',ii,length(testsToRun));
        status(ii) = runtests(testsToRun{ii});
        fprintf('<><><><><><><><><><><><><><><><><><><><><><><><><><><>\n\n');
    end
    
    % Summary
    ind = find(status == 0, 1);
    if isempty(ind)
        fprintf('\n ## ALL TESTS PASS ##\n');
    else
        fprintf('\n ## TEST FAILURES EXIST ##\n');
    end
    
