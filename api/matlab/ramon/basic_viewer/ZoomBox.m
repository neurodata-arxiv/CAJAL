classdef ZoomBox < handle
% ZoomBox class handles the zoom window preview box. The rectangle in this box
% can be dragged around to provide notice to another window in regards to the
% location to display.
%
%
%
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
        hFig = [];  % Handle of display figure
        hAx = [];   % Axes of display image

        rect = [];  % Handle to imrect containing selection
        hImg = [];  % Handle to image
        hScroll = []; % Scroll panel for zoombox
        hFill = [];   % Rectangle patch for display purposes
        img_dims = []; % Contains dimension of the preview image
    end

    events
        StateChange   % Event is notified when the imrect position changes
        WindowClosed  % Event is notified when the window is closed
    end

    methods
        function this = update_image(this, img)
        % obj = update_image(obj, img)
        %
        % Helper function used in standardizing interaction between various
        % GUI windows. Update ZoomBox image with the provided image
        %
            set(this.hImg, 'CData', img);
        end

        function this = ZoomBox(img, pos)
        % obj = ZoomBox(img, pos)
        % Constructs a ZoomBox with the provided image. The ZoomBox is
        % initially positioned with the lower-left corner centered at pos.
        %
            im_dims = size(img);
            im_dims = im_dims(1:2);
            this.img_dims = im_dims;

            win_dims = im_dims;
            
            screen_dims = get(0, 'ScreenSize');
            screen_size = screen_dims(end-1:end);
            screen_x = screen_size(1);            
            screen_y = screen_size(2) - 60;
            
            
            if win_dims(1) > screen_y,
                win_dims(1) = screen_y;
            end
            
            if win_dims(2) > screen_x,
                win_dims(2) = screen_x;
            end
                        
            this.hFig = figure('Toolbar', 'none', ...
                'Menubar', 'none', ...
                'Units', 'pixels', ...
                'Position', [pos, win_dims(2), win_dims(1)], ...
                'NumberTitle', 'off', ...
                'Name', 'Image Preview', ...
                'Resize', 'off', ...
                'CloseRequestFcn', @CloseFcn);

            mag = max(win_dims ./ this.img_dims);
            
            this.hAx = axes('parent', this.hFig, ...
                'position', [0, 0, 1, 1]);

            this.hImg = imagesc(img, 'parent', this.hAx);
            set(this.hAx, 'ytick', [], 'xtick', []);

            this.hScroll = imscrollpanel(this.hFig, this.hImg);

            api = iptgetapi(this.hScroll);            
            api.setMagnification(mag);                           
            
            if size(img,3) == 1,
                colormap( this.hAx, gray);
            end
            
            % Finally, draw rectangle:

            constrainFcn = makeConstrainToRectFcn('imrect', ...
                [0.5, im_dims(2)+0.5], [0.5, im_dims(1)+0.5]);
            
            this.rect = imrect(this.hAx, ...
                [1,1, win_dims(2), win_dims(1)], ...
                'PositionConstraintFcn', constrainFcn);

            this.rect.setColor('r');
            this.rect.addNewPositionCallback(...
                @(pos)(notify(this,'StateChange')));
            
            
            function CloseFcn(src, event)
                close(this);
                notify(this, 'WindowClosed');
            end
        end

        function close(this)
        % close(obj)
        % Close a ZoomBox window
            delete(this.hFig);
            this.hFig = [];
        end

        function r = getPosition(this, newdims)
        % r = getPosition(obj)
        % r = getPosition(obj, newdims)
        %
        % Returns the position of the rectangle in [x,y,w,h]
        % If newdims specified, returns r in terms of the new image dimensions
        % This is for converting between coordinates of the preview image
        % which may be smaller than the original image.
        % newdims is in terms of [nRows, nCols]
        %
            if nargin < 2,
                newdims = [];
            end

            r = this.rect.getPosition();

            if isempty(newdims),
                return;
            end
             
            w = this.img_dims(2);
            h = this.img_dims(1);
            nw = newdims(2);
            nh = newdims(1);

            r(1) = r(1) * (nw / w);
            r(2) = r(2) * (nh / h);
            r(3) = r(3) * (nw / w);
            r(4) = r(4) * (nh / h);
        end
        
        function setPosition(this, r, newdims)
        % setPosition(obj, r)
        % setPosition(obj, r, newdims)
        %
        % Updates the position of the zoombox to the provided coordinates.
        % If newdims specified, r is specified in terms of the image
        % dimension given by newdims.
        %            
            if nargin < 3,
                newdims = [];
            end            
            
            if ~isempty(newdims),
                w = this.img_dims(2);
                h = this.img_dims(1);
                nw = newdims(2);
                nh = newdims(1);

                r(1) = r(1) * (w/nw);
                r(2) = r(2) * (h/nh);
                r(3) = r(3) * (w/nw);
                r(4) = r(4) * (h/nh);
            end
            this.rect.setPosition(r);
            notify(this,'StateChange');
        end
        
        function delete(this)
        % Destructor for ZoomBox class
            delete(this.hFig);
            this.hFig = [];
        end

        function tf = zoom(this, scale)
        % TF = OBJ.zoom(scale)
        %
        % Attempts to resize the rectangle in the zoombox while preserving
        % aspect ratio. If rectangle cannot be resized successfully (e.g. it
        % scales outside of cube or too small), then false is returned and no
        % change is made. Otherwise, true is returned.
        %
            r = this.rect.getPosition();

            xc = r(1) + r(3)/2;
            yc = r(2) + r(4)/2;

            r(1) = (r(1) - xc)* scale + xc;
            r(2) = (r(2) - yc)* scale + yc;
            r(3) = r(3) * scale;
            r(4) = r(4) * scale;

            tf = 1;
            if r(3) < 1 || r(4) < 1 || ...
               r(3) > this.img_dims(2) || ...
               r(4) > this.img_dims(1),
                    tf = 0;
                    return;
            end

            r(1) = max(0, min(this.img_dims(2) - r(3), r(1)));
            r(2) = max(0, min(this.img_dims(1) - r(4), r(2)));
            r(3) = max(1, min(this.img_dims(2), r(3)));
            r(4) = max(1, min(this.img_dims(1), r(4)));

            this.rect.setPosition(r);
            notify(this, 'StateChange');
        end

    end

end
