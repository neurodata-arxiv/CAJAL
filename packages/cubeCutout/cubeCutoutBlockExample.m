serverLocation = 'openconnecto.me';
token = 'kasthuri11cc';
channel = 'image';
resolution = 1;
xStart = 5000;
xStop = 5500;
yStart = 6000;
yStop = 6500;
zStart = 1100;
zStop = 1105;
xSpan = 255;
ySpan = 250;
zSpan = 4;
padX = 0;
padY = 0;
padZ = 0;
alignXY = 0;
alignZ = 0;
computeOptions = 0;
shuffleFilesFlag = 0;
cubeListFile = 'testcubelist.list';
cubeOutputDir = '.';
mergeListFile = 'testmergelist.list';
mergeOutputDir = '.';
print_flag = 0;
                                
                                
computeBlock(serverLocation, token, channel, resolution, ...
                                    xStart, xStop, yStart, yStop, zStart, zStop,...
                                    xSpan, ySpan, zSpan, ...
                                    padX, padY, padZ,...
                                    alignXY, alignZ, computeOptions, shuffleFilesFlag, ...
                                    cubeListFile, cubeOutputDir,...
                                    mergeListFile, mergeOutputDir, print_flag)