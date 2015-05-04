function ilasik_getImage(server, token, queryFile, fileOut, useSemaphore)
% J. Matelsky - adapted from mananno_getImage.m by W. Gray Roncal

if useSemaphore
    oo = OCP('semaphore');
else
    oo = OCP();
end

% Load query
load(queryFile)

oo.setServerLocation(server);
oo.setImageToken(token);
oo.setDefaultResolution(query.resolution);

im = oo.query(query);
im = permute(rot90(im.data,2),[2,1,3]);
nii = make_nii(im);
save_nii(nii, fileOut);
