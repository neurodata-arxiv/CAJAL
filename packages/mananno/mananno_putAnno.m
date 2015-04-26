function mananno_putAnno(server, token, queryFile, fileIn, protoRAMON, doConnComp, useSemaphore)

% Currently only uint8 image data is supported.  Multichannel data may
% produce unexpected results

% W. Gray Roncal

nii = load_nii(fileIn);
anno = nii.img;

anno = permute(rot90(anno,2),[2,1,3]);

if doConnComp
anno = anno > 0;
cc = bwconncomp(anno,26); 
anno = labelmatrix(cc);
end

load(queryFile)

ANNO = RAMONVolume;
ANNO.setCutout(anno);
ANNO.setResolution(query.resolution);
ANNO.setXyzOffset([query.xRange(1),query.yRange(1),query.zRange(1)]);

ocp_upload_dense(server,token,ANNO,protoRAMON,useSemaphore)