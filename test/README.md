# CAJAL Unit Tests

## Open Connectome (OCP) Unit Tests
OCP unit tests are run using the following procedure. First, navigate to the root directory of your CAJAL installation (for example, `/home/alex/Downloads/CAJAL/`) and run:
```
cajal()
```
To run unit tests, run the following:
```
RUN_TESTS('testOCP')
```

### Single Test Driver
A single test driver is available. The test driver runs two unit tests for initialization. You can add another unit test after the following line:

```%% ###### COPY AND PASTE SINGLE UNIT TESTS BELOW ######```

You can of course add additional unit tests. Note that some unit tests may depend on earlier tests for setting tokens, channels, etc. The following command runs the single test driver:
```
RUN_TESTS('testOCPsingle')
```

### Initializing OCP for CAJAL Unit Testing
CAJAL's unit tests rely on projects specifically created for testing. The utility script `cajalProjects.m` (in the `util` folder in the Open Connectome package, see https://github.com/openconnectome/open-connectome) will create all the projects, tokens, and channels neccessary. The `kasthuri11` dataset must exist before this script is run.

The annotation databases must be initialized. To do so, run the unit tests after uncommenting the following lines in `testAnnotationSlice`:

```
    %Use to reset db if needed
    %     d = zeros(100,80,30);
    %     d(40:60,40:60,1:2) = 1;
    %     d(50:55,60:70,2:3) = 1;
    %     d(40:70,50:65,2:5) = 1;
    % 
    %     s1 = RAMONSynapse(d,eRAMONDataFormat.dense,[2200 2200 200],1,eRAMONSynapseType.excitatory, 100,...
    %         [1,2;4,0],34,[],.64, eRAMONAnnoStatus.processed,{'tester',1212;'test2',[];'test','sets'},'testuser');
    %     oo.createAnnotation(s1);
```
(to uncomment a line in Matlab, remove the `%` character from the start of the line. Note that the code editor in the Matlab UI has an uncomment button)

Running the unit tests for the first time will also initialize the image database. It is normal to see errors on the first unit test run. Errors on subsequent runs indicate problems, either with your OCP installation or your CAJAL files.


