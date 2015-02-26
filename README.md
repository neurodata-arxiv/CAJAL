##Overview

This is the CAJAL3D API for MATLAB.  The API provides a simple to use interface with Open Connectome Project servers and provides RAMON Objects, unit tests, configuration scripts, and utilities.  For more information about the Open Connectome Project (OCP), see www.openconnecto.me.

This software was developed at Johns Hopkins University Applied Physics Lab.  For more information about JHUAPL, visit [this site](http://www.jhuapl.edu/ourwork/red/an/default.asp)

##System Requirements 

The API is compatible Windows, Linux, and OSX. It has been extensively tested with MATLAB R2014a, but should work with most versions.

Currently the MATLAB wrapper for LONI Pipline distributed computing requires Linux.

##Installation  

```
*** NOTE: If you have installed a version of the API prior to 1.1, your static classpath
 may have been edited.
 This is no longer needed and should be removed. All required Java classes are 
 now reliably loaded dynamically on most versions of MATLAB.

 You can do this by typing `which classpath.txt` in the command window and editing 
 the indicated file.  Remove lines that reference the old API directory.
```

####Using the API on a single computer (NORMAL USE CASE) 

- Clone API to a local directory.
- Set the MATLAB current folder to the directory where the API is now located
- Run 'cajal3d' in the command window.  This will simply add the API to your MATLAB search path.
- Optionally but recommended, run all unit tests by entering `RUN_TESTS` at the command prompt and pressing enter. Individual tests can be run by using `RUN_TESTS('testXXX')`.
  - When pompted, you can ignore tests that require a GUI if you are running without the MATLAB desktop.  
  - When pompted, you can ignore `testMatlabInit` if you have not configured your matlab exe location. This function is used when running on a cluster and can typically be ignored.
  - When pompted, you can ignore `testOCPDistributedSemaphore` if your Distributed Semaphore has not been configured.  Again, this is only used when operating on a large compute cluster.

####Setting up the API at MATLAB startup
There is a script if you would like to have the API configured automatically when MATLAB starts.  The script edits your startup.m to run "cajal3D" when matlab loads.
  - Set the /tools/matlab_install directory as the current matlab directory
  - Type 'setupEnvironment' in the command window. 
  - Restart MATLAB and you are good to go.

###Using the MATLAB API on a Linux Cluster
Typically you can place the API in a shared directory, so all compute nodes have access. You need to make sure the search path for all instances of MATLAB gets configured properly.

- Required Steps:
    - Add the environment variable `MATLAB_USE_USERPATH=1` to the cluster user .bashrc file or explicitly before running MATLAB.
    - Configure MATLAB search path to include the API on all compute nodes
        - You can do this many different ways:
          - A common startup.m file that runs `cajal3d`
          - Modify matlabrc.m in your MATLAB installation to run `cajal3d`
          - Use the matlab_install script to set things up for you on each node (time consuming for large clusters)
            - Open MATLAB as the user who will be executing the API on each node
            - Navigate to the $API_directory/tools/matlab_install 
            - Enter 'setupEnvironment' at the MATLAB command prompt.
                - Follow the prompts and your MATLAB environment will be ready        
	- Edit /test/matlab/api/testMatlabInit.m
        - Change the global variable 'gtestMatlabPath' to the path to your matlab executable location.
  - Run all unit tests by entering "RUN_TESTS" at the command prompt on a compute node to test install.

- Optional Steps:
  - If you'd like to control where temporary files are written (important if you are managing your temp space) set the environment variable `PIPELINE_TEMP_DIR=/my/location` to your .bashrc file or in the LONI  Pipeline Server Manager if using LONI Pipeline. This can be important because the temporary files created during uploading and downloading can accumulate if nodes are infrequently restarted.
  - Setup the Distributed Semaphore:
    The API supports a distributed semaphore for Open Connectome Project server access.  This can be  important if you have access to A LOT of nodes.  The OCP servers still has capacity limitations and can be overwhelmed or have reduced performance if too many simultanous requests are made.
    - Install an instance of Redis on your network (see www.redis.io)
    - Configure `/api/matlab/ocp/semaphore_settings.mat` to point to your server on the correct port.  semaphore_settings_example.mat can be used as a starting point and renamed. 
    - Open MATLAB, create a SemaphoreTool object, and execute the "configure" method:

    ```matlab
    s = SemaphoreTool;
    s.configure;
    ```
    - Set the desired values (50 read, 50 write is a decent place to start depending on your code)
    - This will then configure the server so any API client that connects will
      get its semaphore configured from the redis server.  To use the semaphore, create an OCP object like this:

      ```
      oo = OCP('semaphore');
      ```
      
      The distributed semaphore will be ignored if you do omit the 'semaphore' tag:

      ```
      oo = OCP()
      ```

  - Configuring LONI Pipeline (loni pipeline url:
        - If you are using LONI Pipeline, you need to add CAJAL3D as a package
        - Set the package location to the root directory of the API
        - Set the package version to *
        - Add the environment variables `PIPELINE_TEMP_DIR=temp_location_if_used` and `MATLAB_EXE_LOCATION=/location/of/matlab`


##Contents 

- **api**
  - **matlab**

    Most functions/classes have comments explaining individual usage.

    - **ocp**

      Contains classes for interfacing with the OCP image and annotation databases.  The OCP class provides methods to upload and download annotation objects, cutouts, and download slices, and overlays.  For more information regarding OCP databases and the associated interfaces see: www.openconnecto.me.  

      eOCP* objects are enumerations to use with the OCP objects.

    - **ramon** 

      Contains all the RAMON annotation objects.  
          
      Classes starting with RAMON* are annotation objects that you can create, manipulate, upload, and download.  
      
      If an object contains image or annotation data, the `image()` method has been overloaded with a simple view.  To use simply pass your RAMON object instance to the method - `h = image(myInstance)`
      
      Objects starting with eRAMON* are enumerations used with RAMON objects.

    - **wrapper** 

      Contains funtions to wrap matlab code for use inside the LONI pipeline framework

- **examples**

    Example scripts showing how to use the API

- **library**

    LONI Pipeline modules for packages used in the JHU/APL connectomics pipeline
    that have been released with the API.

- **packages**

    Software packages that contain algorithms used in the JHU/APL connectomics pipeline
    that have been released with the API. These are mainly utilites to help facilitate image processing at scale.
    
- **test**

  Unit test software

  - **matlab**

    MATLAB unit test scripts accessible through the RUN_TESTS function.
    RUN_TESTS will run all test groups. RUN_TESTS('testname') will run a single group.

- **tools**

    Scripts and tools for API support


##Examples

See /examples directory for an overview of how to use some of the API's basic features


##Notes

Current publicly available image data set tokens are accessible from the OCP class. Just
call the getPublicTokens() method.  

See www.openconnecto.me for dataset citations.

