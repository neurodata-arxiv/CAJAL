function ilastik_runIlastik(ilastikProjectPath, outputPath, stackPattern)
% J. Matelsky - jordan.matelsky@jhu.edu

% ilastikProjectPath    The path to the Ilastik project that contains the
%                       classifiers you wish to use. (There isn't a prettier
%                       way of handling this, unfortunately. Classifiers are
%                       saved in the project file and nowhere else.)
% outputPath            The path to which to save the output (should LONI
%                       be in play here?)
% stackPattern          The *-matched pattern of files which should be run
%                       through the classifier. e.g. stack*.png


% Usage Example:
%   ilastik_runIlastik('~/ilastik-Linux/', './tmp/results/{nickname}_results.tiff', "stack_name_base*.png")


% TODO: We need to know the path to Ilastik...
%       Presumably this will be set in stone on the server?
ILASTIK_PATH = './';

ilastikOutput = system(strcat(
    ILASTIK_PATH,
    'ilastik --headless --project=',
        project,
    ' --output_format=hdf5 ',
    ' --output_filename_format=',
        outputPath,
    ' "',
    stackPattern % Nest in double-quotes to prevent shell auto-expansion
    '"'
    ));
% TODO: Check for failure in Ilastik's exit-code here,
%       and notify the user accordingly.
%       We'll need to store this output to be sure that
%       we can access the files that have been created
%       successfully.
