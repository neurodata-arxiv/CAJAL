classdef VolumeImageBox < handle
    % An VolumeImageBox is a display window that provides an image display and preview
    % box with ability to select portion of image to view and resize (zoom) on the
    % area of interest.
    %
    % Keys Overriden:
    % =================
    %   =/-   zoom in and out by a factor of 2
    %
    % Mouse events overriden:
    % ======================
    %  scroll wheel zooms in and out by 5%
    %
    %
    % obj = ImageBox(img, pos)
    % obj = ImageBox(img, pos, title)
    %
    % Creates an ImageBox object do display the provided image.
    %
    % img = NxM or NxMx3  (Grayscale or RGB) image to display.
    % pos = position of lower-left corner of window.
    % win_title = Title of window (default 'Image')
    %
    % Added new modes to (S) save all slices and (M) to make a movie
    % Sped up overlay rendering for simple use cases.
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
    
    properties
        hFig = [];      % Contains handle to figure
        hAx = [];       % Contains handle to axes
        hImg = [];      % Contains handle to image
        hScroll = [];   % Contains handle to a scrollpane
        hPlotAx = [];  % Contains handle to last plot figure
        
        zoom_box = [];  % Contains ZoomBox object
        
        img_dims = [];  % Contains dimension of image
        
        img_data = [];  % Contains a uint8 version of the image
        
        dataCube = [];  % Conatins the data cube loaded to be displayed
        datatype = [];  % Contains the eRAMONDataType enumeration of data stored
        dataOffset = []; % Contains the xyzOffset of the data cube
        sliceIndex = []; % Contains the index of the slice currently displayed
        
        associated_cube = {}; % Contains cell array of cubes associated with this Image (e.g. spectra)
        associated_key  = {}; % List of keys specifying data
        
        roi_list = {};  % List of ROI's created
        invert_mode = 0;  % State of invert mode (0 = off, 1 = on)
        overlayMode = 0;  % State of annotation overlay mode (0 = off, 1 = on)
        overlayColors = [1,255,0,0; 2,0,255,0;3,0, 0, 255; 4,255, 0, 255; 5, 0, 255, 255]; % Array containing color info (id,r,g,b)
        overlayMethod = 1; %set to 1 to use fast render mode for simple cases
        nColors = 16; %number of overlay colors
    end
    
    events
        WindowClosed    % Event that is triggered when Image window closed
        KeyPressed      % Event that is triggered when key is pressed.
        UpdateTitle     % Event that is triggered to update the title
    end
    
    methods
        
        function this = update_image(this, data)
            % obj = update_image(obj, data)
            %
            % Internal helper function to aide in interfacing various GUI. This
            % function updates the internal image data to the provided data.
            %
            if 0% TODO this.channelType == eRAMONChannelType.image && this.channelDataType == eRAMONChannelDataType.uint32 %RGBA32
                % save 3 channels
                img = squeeze(data(:,:,this.sliceIndex,1:3));
                
                if (this.invert_mode == 1)
                   img(:,:,1) = max(max(img(:,:,1))) - img(:,:,1);
                   img(:,:,2) = max(max(img(:,:,2))) - img(:,:,2);
                   img(:,:,3) = max(max(img(:,:,3))) - img(:,:,3);
                end
            else
                % Save single slice and manipulate to force proper scaling
                img = data(:,:,this.sliceIndex);
                
                % Rescale image:
                mmin = min(img(:));
                mmax = max(img(:));

                if (mmax-mmin) == 0,
                    mmin = 0;
                end

                img = uint8(double(img - mmin) / double(mmax-mmin)*255.0);

                if (this.invert_mode == 1)
                    img = max(img(:)) - img;
                end
            end
            
            if (this.overlayMode == 1)
                % Update image to have annotation overlays
                
                if length(this.associated_cube) == 1
                    % if 1 annotation cube randomize colors
                    % TODO: Change to color palette instead of random
                    % colors
                    
                    if size(img,3) == 1,
                        img = cat(3, img,img,img);
                    end
                    
                    anno = this.associated_cube{1};
                    
                    % If associated cube is a different size you need to
                    % use coords to pop it into place
                    xForm = 0;
                    if ndims(anno.data) ~= ndims(this.dataCube)
                        if 0%TODOthis.channelType == eRAMONChannelType.image && this.channelDataType == eRAMONChannelDataType.uint32 %RGBA32
                            xForm = 0;
                          
                        elseif size(anno.data) ~= size(this.dataCube)
                            xForm = 1;
                        end
                    elseif size(anno.data) ~= size(this.dataCube)
                        xForm = 1;
                    end
                    
                    if xForm == 0
                        annoSlice = anno.data(:,:,this.sliceIndex);
                    else
                        % find overlay data
                        dataInd = double(this.dataOffset(3)) + this.sliceIndex - 1;
                        sliceInds = 1:size(anno,3);
                        if ~isempty(anno.xyzOffset)
                            sliceInds = double(anno.xyzOffset(3)) + sliceInds - 1;
                        end
                        indToOverlay = find(dataInd == sliceInds);
                        
                        if isempty(indToOverlay)
                            % not on a slice with overlay
                            annoSlice = zeros(size(this.dataCube(:,:,1)));
                        else
                            labledInds = find(anno.data(:,:,indToOverlay) > 0);
                            [row,col] = ind2sub(size(anno.data),labledInds);
                            rowDiff = double(anno.xyzOffset(1) - this.dataOffset(1));
                            colDiff = double(anno.xyzOffset(2) - this.dataOffset(2));
                            
                            if rowDiff < 0 || colDiff < 0
                                % annotation outside cube
                                annoSlice = zeros(size(this.dataCube(:,:,1)));
                            else
                                annoSlice = zeros(size(this.dataCube(:,:,1)));
                                row = row + rowDiff;
                                col = col + colDiff;
                                lableInds = sub2ind(size(this.dataCube(:,:,1)),row,col);
                                annoSlice(lableInds) = 1;
                                annoSlice = annoSlice(1:size(this.dataCube(:,:,1),1),...
                                    1:size(this.dataCube(:,:,1),2));
                            end
                            
                        end
                    end
                    
                    if this.overlayMethod == 1
                        % inputs are annoSlice and img
                        
                        %if  length(unique(annoSlice))  > 5 %TODO
                            this.overlayColors = round(255*brewermap(this.nColors,'Spectral'));% Array containing color info (id,r,g,b)
                       % else
                            this.overlayColors(1:5,:) = 255*[1 1 0; 0 1 0; 0 0 1; 1 0 0; 1 1 0];
                       % end
                        this.overlayColors(end+1,:) = [0,0,0]; %for BG
                        
                        colorIdx = mod(annoSlice,this.nColors - 1) + 1;
                        colorIdx(annoSlice == 0) = size(this.overlayColors,1);
                        annoOut(:,:,1)  = reshape(this.overlayColors(colorIdx,1),size(annoSlice,1),size(annoSlice,2));
                        annoOut(:,:,2)  = reshape(this.overlayColors(colorIdx,2),size(annoSlice,1),size(annoSlice,2));
                        annoOut(:,:,3)  = reshape(this.overlayColors(colorIdx,3),size(annoSlice,1),size(annoSlice,2));
                        
                        overlayImgLayer = uint8(annoOut);
                        overlayAlphaLayer = uint8(sum(overlayImgLayer,3));
                        overlayAlphaLayer(overlayAlphaLayer > 0) = 100;
                        
                        % Merge Images
                        overlayAlphaLayer = repmat(overlayAlphaLayer,[1 1 3]);
                        
                        overlayAlphaLayer = double(overlayAlphaLayer);
                        img = double(img);
                        overlayImgLayer = double(overlayImgLayer);
                        img = (img .* (255 - overlayAlphaLayer)./255) + (overlayImgLayer .* (overlayAlphaLayer./255));
                        
                        img = uint8(img);
                        
                        
                    else
                        ids = unique(annoSlice);
                        r = zeros(size(annoSlice));
                        g = r;
                        b = r;
                        
                        for cc = 1:length(ids)
                            if ids(cc) == 0
                                % Don't label background
                                continue
                            end
                            
                            % get color
                            this.overlayColors = brewermap(16,'Spectral');% Array containing color info (id,r,g,b)
                            
                            colors = round(this.overlayColors(mod(ids(cc),15)+1,1:3)*255);
                            
                            % Label pixels
                            r(annoSlice == ids(cc)) = colors(1);
                            g(annoSlice == ids(cc)) = colors(2);
                            b(annoSlice == ids(cc)) = colors(3);
                        end
                        
                        overlayImgLayer = uint8(cat(3,r,g,b));
                        
                        overlayAlphaLayer = uint8(sum(overlayImgLayer,3));
                        overlayAlphaLayer(overlayAlphaLayer > 0) = 100;
                        
                        % Merge Images
                        overlayAlphaLayer = repmat(overlayAlphaLayer,[1 1 3]);
                        
                        overlayAlphaLayer = double(overlayAlphaLayer);
                        img = double(img);
                        overlayImgLayer = double(overlayImgLayer);
                        img = (img .* (255 - overlayAlphaLayer)./255) + (overlayImgLayer .* (overlayAlphaLayer./255));
                        img = uint8(img);
                    end
                else
                    % If 2+ annotation cubes group colors by cube
                    if size(img,3) == 1,
                        img = cat(3, img,img,img);
                    end
                    
                    rOverlay = zeros(size(img(:,:,1)));
                    gOverlay = rOverlay;
                    bOverlay = rOverlay;
                    
                    for ss = 1:length(this.associated_cube)
                        
                        anno = this.associated_cube{ss};
                        
                        % If associated cube is a different size you need to
                        % use coords to pop it into place
                        xForm = 0;
                        if ndims(anno.data) ~= ndims(this.dataCube)
                            xForm = 1;
                        elseif size(anno.data) ~= size(this.dataCube)
                            xForm = 1;
                        end
                        
                        if xForm == 0
                            annoSlice = anno.data(:,:,this.sliceIndex);
                        else
                            % find overlay data
                            dataInd = double(this.dataOffset(3)) + this.sliceIndex - 1;
                            sliceInds = 1:size(anno,3);
                            sliceInds = double(anno.xyzOffset(3)) + sliceInds - 1;
                            indToOverlay = find(dataInd == sliceInds);
                            
                            if isempty(indToOverlay)
                                % not on a slice with overlay
                                annoSlice = zeros(size(this.dataCube(:,:,1)));
                            else
                                labledInds = find(anno.data(:,:,indToOverlay) > 0);
                                [row,col] = ind2sub(size(anno.data),labledInds);
                                rowDiff = double(anno.xyzOffset(1) - this.dataOffset(1));
                                colDiff = double(anno.xyzOffset(2) - this.dataOffset(2));
                                
                                if rowDiff < 0 || colDiff < 0
                                    % annotation outside cube
                                    annoSlice = zeros(size(this.dataCube(:,:,1)));
                                else
                                    annoSlice = zeros(size(this.dataCube(:,:,1)));
                                    row = row + rowDiff;
                                    col = col + colDiff;
                                    annoSlice(row,col) = 1;
                                    annoSlice = annoSlice(1:size(this.dataCube(:,:,1),1),...
                                        1:size(this.dataCube(:,:,1),2));
                                end
                                
                            end
                        end
                        
                        r = zeros(size(img(:,:,1)));
                        g = r;
                        b = r;
                        
                        ids = unique(annoSlice);
                        if length(ids) == 1
                            % Don't label background
                            continue
                        end
                        
                        % get color
                        if isempty(this.overlayColors)
                            % gen color
                            colors = floor(rand(1,3)*255);
                            this.overlayColors = [ss colors];
                        else
                            % check color list
                            ind = find(this.overlayColors(:,1)==ss, 1);
                            if isempty(ind)
                                %gen color
                                colors = floor(rand(1,3)*255);
                                this.overlayColors(end+1,:) = [ss colors];
                            else
                                % reuse color
                                colors = this.overlayColors(ind,2:4);
                            end
                        end
                        
                        % Label pixels
                        r(annoSlice > 0) = colors(1);
                        g(annoSlice > 0) = colors(2);
                        b(annoSlice > 0) = colors(3);
                        
                        rOverlay = rOverlay + r;
                        gOverlay = gOverlay + g;
                        bOverlay = bOverlay + b;
                    end
                    
                    overlayImgLayer = uint8(cat(3,rOverlay,gOverlay,bOverlay));
                    overlayAlphaLayer = uint8(sum(overlayImgLayer,3));
                    overlayAlphaLayer(overlayAlphaLayer > 0) = 85;
                    
                    % Merge Images
                    overlayAlphaLayer = double(repmat(overlayAlphaLayer,[1 1 3]));
                    overlayImgLayer = double(overlayImgLayer);
                    img = double(img);
                    img = (img .* (255 - overlayAlphaLayer)./255) + (overlayImgLayer .* (overlayAlphaLayer./255));
                    img = uint8(img);
                end
            end
            
            set(this.hImg, 'CData', img);
            this.img_data = img;
            
            
            img = imresize(img, this.zoom_box.img_dims);
            this.zoom_box.update_image(img);
        end
        
        function this = VolumeImageBox(cube, xyzOffset, slice, pos, win_title, datatype)
            % obj = VolumeImageBox(cube)
            % obj = VolumeImageBox(cube, slice)
            % obj = VolumeImageBox(cube, slice, pos)
            % obj = VolumeImageBox(cube, slice, pos, win_title)
            %
            % Creates an VolumeImageBox object do display the provided cube/img
            %
            % cube = NxM or NxMxZ  (Grayscale or RGB) image or cube to display.
            % slice = index in Z of image to display.  If img and not a cube
            % set to 1
            % pos = position of lower-left corner of window.
            % win_title = Title of window (default 'Image')
            %
            
            if nargin < 2,
                xyzOffset = [1 1 1];
            end
            
            if nargin < 3,
                slice = [];
            end
            
            if nargin < 4,
                pos = [];
            end
            
            if nargin < 5,
                win_title = [];
            end
            
            if isempty(slice),
                this.sliceIndex = 1;
            else
                this.sliceIndex = slice;
            end
            
            if isempty(win_title),
                win_title = 'Image';
            end
            
            this.dataCube = cube;
            this.datatype = datatype;
            if isempty(xyzOffset)
                this.dataOffset = [1 1 1];
            else
                this.dataOffset = xyzOffset;
            end
            clear cube % clear up dup memory
            
            screen_dims = get(0, 'ScreenSize');
            screen_size = screen_dims(end-1:end);
            screen_x = screen_size(1);
            screen_y = screen_size(2);
            
            img_dims_val = size(this.dataCube(:,:,this.sliceIndex));
            img_dims_val = img_dims_val(1:2);
            
            this.img_dims = img_dims_val;
            
            if (img_dims_val(1) > screen_x) || (img_dims_val(2) > screen_y)
                win_dims = floor(0.75 * [screen_x, screen_y]);
                if win_dims(1) == 0 || win_dims(2) == 0
                    win_dims = this.img_dims;
                end
            else
                win_dims =  this.img_dims;
            end
            
            prev_dims = floor(0.2 * this.img_dims);
            if prev_dims(1) == 0 || prev_dims(2) == 0
                prev_dims = this.img_dims;
            end
            
            min_preview_size = 100;
            min_window_size = 250;
            
            if max(prev_dims) <= min_window_size
                prev_dims = prev_dims * (min_window_size/max(prev_dims));
            end
            
            if min(prev_dims) < min_preview_size,
                prev_dims = floor((min_preview_size/min(prev_dims)) * prev_dims);
            end
            
            if min(win_dims) < min_window_size,
                win_dims = floor((min_window_size/min(win_dims)) * win_dims);
            end
            
            % Automatically set window position
            if isempty(pos),
                pos = [screen_x/2, screen_y/2] - [win_dims(2), win_dims(1)];
            end
            
            
            % It's possible above operations made width of an image too small.
            % In this case, we will just scale in a non-uniform manner:
            %prev_dims(prev_dims < min_dim_size) = min_dim_size;
            
            if 0% TODO this.channelType == eRAMONChannelType.image && this.channelDataType == eRAMONChannelDataType.uint32 %RGBA32
                % save 3 channels
                img = squeeze(this.dataCube(:,:,this.sliceIndex,1:3));
            else
                % Save single slice and manipulate to force proper scaling
                img = this.dataCube(:,:,this.sliceIndex);

                mmin = min(img(:));
                mmax = max(img(:));

                if (mmax-mmin) == 0,
                    mmin = 0;
                end

                img = uint8(double(img - mmin) / double(mmax-mmin) * 255.0);
            end
            
            this.hFig = figure('Toolbar', 'none', ...
                'MenuBar', 'none', ...
                'Units', 'pixels', ...
                'Position', [pos, win_dims(2), win_dims(1)], ...
                'NumberTitle', 'off', ...
                'Name', win_title, ...
                'Resize', 'on', ...
                'CloseRequestFcn', @CloseFcn, ...
                'KeyPressFcn', @KeyPressFcn, ...
                'WindowScrollWheelFcn', @WindowScrollWheelFcn );
            
            this.img_data = img;
            this.hAx = axes('parent', this.hFig, ...
                'position', [0,0,1,1]);
            
            this.hImg = imagesc(img, 'parent', this.hAx);
            
            set(this.hAx, 'ytick', [], 'xtick', []);
            
            if size(img,3) == 1,
                colormap(this.hAx, gray);
            end
            
            prev_xpos = pos(1) + 10 + this.img_dims(2);
            prev_ypos = pos(2); % Stays the same
            prev_width = prev_dims(2);
            prev_height = prev_dims(1);
            
            if prev_xpos + prev_width > screen_x,
                prev_xpos = pos(1) - 10 - this.img_dims(2);
            end
            
            prev_pos = [prev_xpos, prev_ypos];
            preview_img = imresize(img, [prev_height, prev_width]);
            prev_pos(prev_pos < 0) = 0;
            
            this.zoom_box = ZoomBox(preview_img, prev_pos);
            
            addlistener(this.zoom_box, 'StateChange', @UpdateAxisFcn);
            addlistener(this.zoom_box, 'WindowClosed', @ClosedZoom);
            
            addlistener(this, 'UpdateTitle', @UpdateAxisFcn);
            
            set(this.zoom_box.hFig, 'KeyPressFcn', @KeyPressFcn, ...
                'WindowScrollWheelFcn', @WindowScrollWheelFcn );
            
            set(this.hFig, 'ResizeFcn', @ResizeConstraintFcn);
            base_title = get(this.hFig, 'Name');
            notify(this, 'UpdateTitle');
            
            function ResizeConstraintFcn(~, ~)
                % Update magnification level of scroll panel while
                % resizing:
                
                %api = iptgetapi(this.hScroll);
                %screen_dims = get(0, 'ScreenSize');
                %screen_size = screen_dims(end-1:end);
                %screen_x = screen_size(1);
                %screen_y = screen_size(2);
                
                %position = get(this.hFig, 'Position');
                %mag = max(position(3) / this.img_dims(2), ...
                %          position(4) / this.img_dims(1));
                %api.setMagnification(mag);
            end
            
            function ResetAxisProportionFcn(~, ~)
                % Reset the axis to the correct dimension if the box has
                % been resized wierd
                
                position = get(this.hFig, 'Position');
                c1 = position(3);
                r1 = position(4);
                [r2 c2] = size(this.dataCube(:,:,this.sliceIndex));
                
                if r1/c1 == r2/c2
                    return
                end
                
                if r1 > c1
                    newC1 = c1* ((r1 * c2) / (r2 * c1));
                    set(this.hFig, 'Position',[position(1) position(2) newC1 r1]);
                else
                    newR1 = r1* ((r2 * c1) / (r1 * c2));
                    set(this.hFig, 'Position',[position(1) position(2) c1 newR1]);
                end
            end
            
            function UpdateAxisFcn(~, ~)
                pos = this.zoom_box.getPosition(this.img_dims);
                newaxis = [pos(1), pos(1) + pos(3), pos(2), pos(2)+pos(4)];
                axis(this.hAx, newaxis);
                if this.overlayMode == 1
                    annoMode = 'ON';
                else
                    annoMode = 'OFF';
                end
                set(this.hFig, 'Name', sprintf('%s X: [%d, %d]  Y: [%d, %d]  Z: %d Anno: %s', ...
                    base_title, round(newaxis(1)), round(newaxis(2)), ...
                    round(newaxis(3)), round(newaxis(4)),this.sliceIndex,annoMode));
                zw = pos(3);
                zh = pos(4);
                
                figpos = get(this.hFig, 'Position');
                ul = figpos(1:2) + figpos(3:4);
                
                screen_dims = get(0, 'ScreenSize');
                screen_width = screen_dims(end-1);
                screen_height = screen_dims(end);
                
                new_w = (zw / zh) * figpos(4);
                new_h = (zh / zw) * figpos(3);
                
                if screen_height < screen_width,
                    figpos(4) = new_h;
                else
                    figpos(3) = new_w;
                end
                
                figpos(1:2) = ul - figpos(3:4);
                
                
                if min(figpos) < -100,
                    figpos(figpos < -100) = -100;
                end
                set(this.hFig, 'Position', figpos);
                
            end
            
            function KeyPressFcn(src, event)
                %                 windims = get(this.hFig, 'Position');
                %                 windims = windims(3:4);
                %
                %                 screendims = get(0, 'ScreenSize');
                %                 screendims = screendims(end-1:end);
                %maxfactor = max(windims ./ screendims);
                %minfactor = min(windims ./ screendims);
                
                switch (event.Character)
                    case {'?','/'},
                        fprintf(1, '====[ VolumeImageBox Keys ] =====\n');
                        fprintf(1, '?        - Display help on available shortcut keys\n');
                        fprintf(1, ' space   - resize image window to be proportional\n');
                        fprintf(1, ' +,=     - Zoom into region\n');
                        fprintf(1, ' -       - Zoom out of region\n');
                        fprintf(1, ' s       - Save current figure\n');
                        fprintf(1, ' c       - Copy current figure to clipboard\n');
                        fprintf(1, ' i       - Invert image by subtracting from maximum value.\n');
                        fprintf(1, ' a       - Overlay annotations. You must associate an annotation volume object first.\n');
                        fprintf(1, ' S       - Save all slices.\n');
                        fprintf(1, ' M       - Make a movie of all slices.\n');
                        fprintf(1, ' uparrow - Increment Slice.\n');
                        fprintf(1, ' dnarrow - Decrement Slice.\n');
                        
                        % Dispatch this key so that other handlers can
                        % display proper message:
                        notify(this, 'KeyPressed', KeyPressEvent(event.Character));
                        
                    case {' '},
                        ResetAxisProportionFcn(src, event);
                        
                    case {'+', '='},
                        % Allow change?
                        this.zoom_box.zoom(0.5);
                        
                    case {'-'}
                        this.zoom_box.zoom(2);
                        
                    case {'s'}
                        [filename, pathname] = uiputfile({'*.fig', 'MATLAB Figure'; '*.png', 'Image File' }, 'Save Figure As');
                        if isequal(filename, 0)
                            return;
                        end
                        oldfcn = get(this.hFig,'CloseRequestFcn');
                        set(this.hFig,'CloseRequestFcn', 'closereq');
                        saveas(this.hFig, fullfile(pathname, filename));
                        set(this.hFig,'CloseRequestFcn', oldfcn);
                        
                    case {'S'}
                        %save all
                        
                        folder_name = uigetdir;
                        disp('saving all slices beginning at slice 1...may be slow...')
                        disp('first reset to slice 1')
                        this.sliceIndex = 1;
                        this = this.update_image(this.dataCube);
                        notify(this, 'UpdateTitle');
                        %this = update_image(this, img);
                        drawnow
                        disp('then iterate over all slices')
                        for iii = this.sliceIndex:size(this.dataCube,3)
                            ee.Key = 'uparrow';
                            ee.Character = 'uparrow';
                            KeyPressFcn(src, ee)
                            drawnow
                            fprintf('Saving slice %d of %d...\n', iii, size(this.dataCube,3))
                            imwrite(this.img_data, fullfile(folder_name,['Slice_',num2str(iii),'.png']));
                        end
                        
                    case {'M'}
                        if isunix && ~ismac
                            [filename, pathname] = uiputfile({'*.mp4', 'MATLAB Movie'}, 'Save Movie As');                        disp('saving all slices beginning at slice 1...may be slow...')
                        else
                            [filename, pathname] = uiputfile({'MATLAB Movie'}, 'Save Movie As');                        disp('saving all slices beginning at slice 1...may be slow...')
                        end
                        disp('first reset to slice 1')
                        this.sliceIndex = 1;
                        this = this.update_image(this.dataCube);
                        notify(this, 'UpdateTitle');
                        %this = update_image(this, img);
                        drawnow
                        disp('then iterate over all slices')
                        
                        if isunix && ~ismac %linux
                            
                            writerObj = VideoWriter(fullfile(pathname,filename));
                        else %windows, mac
                            writerObj = VideoWriter(fullfile(pathname,filename),'MPEG-4');
                            
                        end
                        writerObj.FrameRate = 2;
                        writerObj.Quality = 100;
                        open(writerObj);
                        
                        for iii = this.sliceIndex:size(this.dataCube,3)
                            ee.Key = 'uparrow';
                            ee.Character = 'uparrow';
                            KeyPressFcn(src, ee)
                            drawnow
                            
                            frame = getframe(this.hFig);
                            writeVideo(writerObj,frame);
                            
                            
                            
                            fprintf('Saving slice %d of %d...\n', iii, size(this.dataCube,3))
                            
                        end
                        
                        close(writerObj);
                        
                        
                        
                    case {'c'}
                        imclipboard('copy', this.img_data);
                        fprintf('Image copied to clipboard.\n');
                        
                    case {'i'}
                        % Invert image
                        this.img_data = max(this.img_data(:)) - this.img_data;
                        set(this.hImg, 'CData', this.img_data);
                        this.invert_mode = ~this.invert_mode;
                    case {'a'}
                        % overlay annotations
                        if ~isempty(this.associated_cube)
                            this.overlayMode = ~this.overlayMode;
                            this = this.update_image(this.dataCube);
                        else
                            fprintf('You must associate annotation data contained in a VolumeObject via the "associate" method.  It must be the same size as the image data\n');
                        end
                        
                    otherwise,
                        switch (event.Key)
                            case {'uparrow'}
                                
                                if this.sliceIndex + 1 <= size(this.dataCube,3)
                                    this.sliceIndex = this.sliceIndex + 1;
                                    this = this.update_image(this.dataCube);
                                end
                                
                                notify(this, 'UpdateTitle');
                                
                            case {'downarrow'}
                                
                                if this.sliceIndex - 1 > 0
                                    this.sliceIndex = this.sliceIndex - 1;
                                    this = this.update_image(this.dataCube);
                                end
                                
                                notify(this, 'UpdateTitle');
                                
                            otherwise
                                notify(this, 'KeyPressed', KeyPressEvent(event.Character));
                        end
                        
                end
            end
            
            function WindowScrollWheelFcn(~, event)
                
                %windims = get(this.hFig, 'Position');
                %windims = windims(3:4);
                
                %screendims = get(0, 'ScreenSize');
                %screendims = screendims(end-1:end);
                %maxfactor = max(windims ./ screendims);
                
                if event.VerticalScrollCount < 0,
                    this.zoom_box.zoom(0.9);
                elseif event.VerticalScrollCount > 0,
                    this.zoom_box.zoom(1.05);
                end
            end
            
            function ClosedZoom(~, ~)
                close(this);
                notify(this, 'WindowClosed');
            end
            
            function CloseFcn(~, ~)
                try
                    close(this);
                    notify(this, 'WindowClosed');
                catch ME %#ok<NASGU>
                    set(gcf,'CloseRequestFcn', 'closereq');
                    delete(gcf);
                end
            end
            
        end
        
        function close(this)
            delete(this.hFig);
            this.hFig = [];
            delete(this.zoom_box);
            this.zoom_box = [];
        end
        
        function delete(this)
            delete(this.zoom_box);
            this.zoom_box = [];
            
            delete(this.hFig);
            this.hFig = [];
            
            this.hAx = [];
            this.hImg = [];
        end
        
        function save(this, filename)
            imwrite(this.img_data, filename);
        end
        
        function associate(this, cube, key)
            % OBJ.associate(this, cube)
            % OBJ.associate(this, cube, key)
            % OBJ.associate(this, key, cube)
            %
            % Contains a cube to associate image data with
            %
            if nargin < 3,
                key = [];
            end
            
            if isempty(key),
                key = 'annotation';
            end
            
            if isobject(key),
                nkey = cube;
                cube = key;
                key = nkey;
            end
            
            [tf, loc] = ismember(this.associated_key, key);
            if isempty(tf),
                loc = numel(this.associated_key)+1;
            end
            
            if (loc == 0),
                loc = numel(this.associated_key)+1;
            end
            
            if isempty(cube), % Deletion:
                this.associated_key(loc) = [];
                this.associated_cube(loc) = [];
            else
                this.associated_key{loc} = key;
                if isempty(cube.xyzOffset)
                    cube.setXyzOffset([1 1 1]);
                end
                this.associated_cube{loc} = cube;
            end
            
        end
        
    end
    
end

