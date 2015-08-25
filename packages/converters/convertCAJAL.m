function convertCAJAL(inFile, outFile, queryFile, inFmt, outFmt, padX, padY, padZ)
% CONVERTCAJAL Anything-to-anything converter for CAJAL.
% Complain to @j6k4m8 when it breaks.

% Supported Formats
%    raw, mat
%    RAMON
%    tiff
%    hdf5

% Just pass it through immediately. No changes necessary.
if inFmt == outFmt
    tmp = load(inFile);
    save(outFile, 'tmp');
    return;
end


tempFile = 'conversion.tmp.m';

% User only specified inFile and outFile.
% Try to guess the rest, warn about queryFile.
if nargins == 2
    warning('No queryfile supplied, assuming defaults.');
    queryFile = 'queryFile.tmp.m';
    query = OCPQuery;
    save(queryFile, 'query');
end


% User only specified inFile, outFile, queryFile.
% Fill in the rest automatically.
if nargins <= 3
    inSplit = strsplit(inFile, '.');
    inFmt = inSplit(end);

    outSplit = strsplit(outFile, '.');
    outFmt = outSplit(end);
end


% Check if padding was supplied. If not, default to 0.
if nargins <= 5
    padX = 0; padY = 0; padZ = 0;
end


switch inFmt
    % Raw
    case {'m', 'raw'}
        tempFile = inFile;
    % TIFF
    case {'tif', 'tiff'}
        TIFFtoRaw(fileIn, tempFile);
    % HDF5
    case {'h5', 'hdf5'}
        HDF5toRaw(fileIn, tempFile);
    otherwise
        warning('Assuming raw input.');
end

% By the time we get here, we have a file at `tempFile` that
% contains raw data.

% Now we can convert it to a target fmt.
switch outFmt
    % Raw
    case {'m', 'raw'}
        outFile = tempFile;
    % TIFF
    case {'tif', 'tiff'}
        RawtoTIFF(tempFile, outFile);
    % HDF5
    case {'h5', 'hdf5'}
        RawtoHDF5(tempFile, outFile);
    % RAMON
    case {'ramon', 'RAMON'}
        RawtoRAMON(tempFile, outFile, queryFile, padX, padY, padZ);
    otherwise
        warning('Returning raw input.');
end

end