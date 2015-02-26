classdef OCPQuery < handle
    %OCPQuery ************************************************
    % Class specifying a query for database services
    %
    % Usage:
    %
    %  q = OCPQuery(); Creates object
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
    
    properties(SetAccess = 'private', GetAccess = 'public')
        %% Properties - Serivce request type (should be of type eRequests)
        type = []
        
        %% Properties - ID
        % This integer value(s) represent the unique 32 bit integer
        % assigned to each annotation created by the database
        id = [];
        
        %% Properties - DB Resolution higherarchy level
        % This scalar integer value represents the database resolution higherarchy
        % level to interact with
        resolution = [];
        
        %% Properties - Volume Args - 1x2 Range [min max]
        % These represent a cube of size (xmax-xmin,ymax-ymin,zmax-zmin)
        % cutout from the corner (xmin,ymin,zmin). These correspond to the
        % python conventions for ranges
        xRange = [];
        yRange = [];
        zRange = [];
        
        %% Properties - Slice Args
        % ##### Note #####
        % Slices may not represent "true" data since scaling is
        % done to render proper images.  If you want a single slice of raw
        % data use the "dense" cutout queries with one of the dimensions having
        % a range = 1
        % ##### Note #####
        %
        % This represents in which coordinate plane the slice should be
        % rendered.  It should be of type eOCPSlicePlane which is an enumeration
        % aid developers
        slicePlane = []; % Should be type eOCPSlicePlane
        
        % These represent a rectanglular plane of size (amax-amin,bmax-bmin)
        % from the corner (amin,bmin). The slice is taken at cIndex in the
        % out of plane dimension.
        aRange = [];
        bRange = [];
        cIndex = [];
        
        % This represents the alpha value (0-1) for the overlay service. If
        % omitted an overlay alpha of 1 is used for backwards compatibility
        overlayAlpha = []; % Should be 0-1
        
        %% Properties - ID List query predicates
        idListPredicates = containers.Map('KeyType','char','ValueType','double');
        
        %% Properties - ID List query limit
        % This controls the number of objects returned by an ID query
        idListLimit = [];
        
        %% Properties - XYZ Coord for voxel ID by xyz query
        xyzCoord = [];
        
        %% Properties - List of ids to include in an anno dense or slice query, 
        % ignoring others within the spatial extent of the query
        filterIds = [];
        %% Properties - Channel list for multichannel data query (cell array for multiple channels)
        channels = [];
    end
    
    methods
        %% Methods - General & Setters
        function this = OCPQuery(type,id)
            % constructor is "overloaded" so that you can intialize it:
            % 1) Empty
            % 2) With the 'type' property set (eOCPQueryType)
            % 3) With both 'type' property (eOCPQueryType) and id set.  This
            % is useful when simply querying the DB for RAMON objects
            
            % Guarantee Default Values
            this.type = [];
            this.id = [];
            this.resolution = [];
            this.xRange = [];
            this.yRange = [];
            this.zRange = [];
            this.slicePlane = [];
            this.aRange = [];
            this.bRange = [];
            this.cIndex = [];
            this.idListPredicates = containers.Map;
            this.idListLimit = [];
            this.xyzCoord = [];
            this.filterIds = [];
            this.channels = [];
            
            if exist('type','var')
                this.setType(type);
            end
            
            if exist('id','var')
                this.setId(id);
            end
        end
        
        function this = setCutoutArgs(this, varargin)
            % [xMin xMax] [yMin yMax] [zMin zMax]
            % [xMin xMax] [yMin yMax] [zMin zMax], res
            % xMin, xMax, yMin, yMax, zMin, zMax
            % xMin, xMax, yMin, yMax, zMin, zMax, res
            
            switch nargin
                case 4
                    this.setXRange(varargin{1});
                    this.setYRange(varargin{2});
                    this.setZRange(varargin{3});
                case 5
                    this.setXRange(varargin{1});
                    this.setYRange(varargin{2});
                    this.setZRange(varargin{3});
                    this.setResolution(varargin{4});
                    
                case 7
                    this.setXRange([varargin{1} varargin{2}]);
                    this.setYRange([varargin{3} varargin{4}]);
                    this.setZRange([varargin{5} varargin{6}]);
                    
                case 8
                    this.setXRange([varargin{1} varargin{2}]);
                    this.setYRange([varargin{3} varargin{4}]);
                    this.setZRange([varargin{5} varargin{6}]);
                    this.setResolution(varargin{7});
                    
                otherwise
                    ex = MException('OCPQuery:IncorrectNumArgs',...
                        'Incorrect Number of Arguments:%d',nargin);
                    throw(ex);
            end
        end
        
        function this = setSliceArgs(this, varargin)
            % slicePlane [aMin aMax] [bMin bMax] cIndex
            % slicePlane [aMin aMax] [bMin bMax] cIndex resolution
            % slicePlane aMin aMax bMin bMax cIndex
            % slicePlane aMin aMax bMin bMax cIndex resolution
            
            switch nargin
                case 5
                    this.setSlicePlane(varargin{1});
                    this.setARange(varargin{2});
                    this.setBRange(varargin{3});
                    this.setCIndex(varargin{4});
                case 6
                    this.setSlicePlane(varargin{1});
                    this.setARange(varargin{2});
                    this.setBRange(varargin{3});
                    this.setCIndex(varargin{4});
                    this.setResolution(varargin{5});
                    
                case 7
                    this.setSlicePlane(varargin{1});
                    this.setARange([varargin{2} varargin{3}]);
                    this.setBRange([varargin{4} varargin{5}]);
                    this.setCIndex(varargin{6});
                    
                case 8
                    this.setSlicePlane(varargin{1});
                    this.setARange([varargin{2} varargin{3}]);
                    this.setBRange([varargin{4} varargin{5}]);
                    this.setCIndex(varargin{6});
                    this.setResolution(varargin{7});
                    
                otherwise
                    ex = MException('OCPQuery:IncorrectNumArgs',...
                        'Incorrect Number of Arguments:%d',nargin);
                    throw(ex);
            end
        end
        
        function this = setType(this, type)
            % This method sets the class property 'type' which
            % indicates what type of database query you intend to do.
            
            if ~exist('type','var')
                ex = MException('OCPQuery:MissingArgs',...
                    'You must specify the query type using the eOCPQueryType enumeration');
                throw(ex);
            end
            
            if isa(type, 'eOCPQueryType')
                % Is of Type eOCPQueryType
            else
                % Is not of type eOCPQueryType
                validateattributes(type,{'numeric'},{'finite','nonnegative','integer','nonnan','real'});
                try
                    type = eOCPQueryType(uint32(type));
                catch ME
                    rethrow(ME);
                end
            end
            
            % If going from a volume to a slice guess that you want to look
            % at a Z slice for convenience.
            if ~isempty(this.type)
                if this.type == eOCPQueryType.annoDense ||...
                        this.type == eOCPQueryType.imageDense
                    if type == eOCPQueryType.annoSlice || ...
                            type == eOCPQueryType.imageSlice || ...
                            type == eOCPQueryType.overlaySlice
                        this.aRange = this.xRange;
                        this.bRange = this.yRange;
                        this.cIndex = this.zRange(1);
                        this.slicePlane = eOCPSlicePlane.xy;
                    end
                end
            end
            
            this.type = type;
        end

        
        function this = setId(this,id)
            % This member function sets id to query.  It can be a single ID
            % or an array.  If it is an array the batch interface will be
            % used.            
            validateattributes(id,{'numeric'},{'integer','finite','nonnegative','nonnan','real'});
            this.id = id;
        end
        
        function this = setChannels(this,ch)
            % This member function sets channels to query for multichannel
            % image databases.  Used ONLY in multichannel data.
            % If specifying multiple channels, ch must be a cell array
            if isa(ch, 'cell')
                % Collection of channels
                cellfun(@(x) validateattributes(x,{'char'},{'row'}), ch)
            else
                if ~isempty(ch)   
                    % if not a cell you can pass in empty [] to clear but
                    % that is it.
                    error('OCPQuery:ChannelType','Channels must be a cell array');
                end
            end
            this.channels = ch;
        end
        
        function this = setResolution(this,res)
            % This member function sets the db resolution to query.
            
            validateattributes(res,{'numeric'},{'scalar','integer','finite','nonnegative','nonnan','real'});
            this.resolution = res;
        end
        
        function this = setXRange(this,x)
            % This member function sets the x Range [min max]  for a volume
            % cutout
            validateattributes(x,{'numeric'},{'size', [1 2],'integer','finite','nonnegative','nonnan','real'});
            
            if x(2) <= x(1)
                errmsg = sprintf('%s\n\n%s%s',...
                    'Max must be greater than Min.',...
                    ' Ranges represent a cube of size (xmax-xmin,ymax-ymin,zmax-zmin)',...
                    ' cutout from the corner (xmin,ymin,zmin). These correspond to the',...
                    ' python conventions for ranges.');
                ex = MException('OCPQuery:BadRange',errmsg);
                throw(ex);
            end
            
            this.xRange = x;
        end
        function this = setYRange(this,y)
            % This member function sets the y Range [min max] for a volume
            % cutout
            validateattributes(y,{'numeric'},{'size', [1 2],'integer','finite','nonnegative','nonnan','real'});
            if y(2) <= y(1)
                errmsg = sprintf('%s\n\n%s%s',...
                    'Max must be greater than Min.',...
                    ' Ranges represent a cube of size (xmax-xmin,ymax-ymin,zmax-zmin)',...
                    ' cutout from the corner (xmin,ymin,zmin). These correspond to the',...
                    ' python conventions for ranges.');
                ex = MException('OCPQuery:BadRange',errmsg);
                throw(ex);
            end
            this.yRange = y;
        end
        function this = setZRange(this,z)
            % This member function sets the z Range [min max] for a volume
            % cutout
            validateattributes(z,{'numeric'},{'size', [1 2],'integer','finite','nonnegative','nonnan','real'});
            if z(2) <= z(1)
                errmsg = sprintf('%s\n\n%s%s',...
                    'Max must be greater than Min.',...
                    ' Ranges represent a cube of size (xmax-xmin,ymax-ymin,zmax-zmin)',...
                    ' cutout from the corner (xmin,ymin,zmin). These correspond to the',...
                    ' python conventions for ranges.');
                ex = MException('OCPQuery:BadRange',errmsg);
                throw(ex);
            end
            this.zRange = z;
        end
        
        function this = setARange(this,a)
            % This member function sets the a Range [min max]
            % This corresponds to either x,y,or z coordinates depending on
            % which plane the image is being created in (xy,xz,yz)
            validateattributes(a,{'numeric'},{'size', [1 2],'integer','finite','nonnegative','nonnan','real'});
            
            if a(2) <= a(1)
                errmsg = sprintf('%s\n\n%s%s',...
                    'Max must be greater than Min.',...
                    ' Ranges represent a cube of size (xmax-xmin,ymax-ymin,zmax-zmin)',...
                    ' cutout from the corner (xmin,ymin,zmin). These correspond to the',...
                    ' python conventions for ranges.');
                ex = MException('OCPQuery:BadRange',errmsg);
                throw(ex);
            end
            
            this.aRange = a;
        end
        function this = setBRange(this,b)
            % This corresponds to either x,y,or z coordinates depending on
            % which plane the image is being created in (xy,xz,yz)
            validateattributes(b,{'numeric'},{'size', [1 2],'integer','finite','nonnegative','nonnan','real'});
            
            if b(2) <= b(1)
                errmsg = sprintf('%s\n\n%s%s',...
                    'Max must be greater than Min.',...
                    ' Ranges represent a cube of size (xmax-xmin,ymax-ymin,zmax-zmin)',...
                    ' cutout from the corner (xmin,ymin,zmin). These correspond to the',...
                    ' python conventions for ranges.');
                ex = MException('OCPQuery:BadRange',errmsg);
                throw(ex);
            end
            
            this.bRange = b;
        end
        function this = setCIndex(this,index)
            % This corresponds to either x,y,or z index depending on
            % which plane the image is being created in (xy,xz,yz)
            validateattributes(index,{'numeric'},{'scalar','integer','finite','nonnegative','nonnan','real'});
            this.cIndex = index;
        end
        
        function this = setOverlayAlpha(this,val)
            % This member function sets the alpha value used in overlay queries         
            validateattributes(val,{'numeric'},{'finite','nonnegative','nonnan','real','>=',0,'<=',1});
            this.overlayAlpha = val;
        end
        
        function this = setSlicePlane(this, plane)
            % This method sets the class property 'slicePlane' which
            % indicates in which image plane the image slice should be rendered
            % (xy, xz, yz).
            
            if isa(plane, 'eOCPSlicePlane')
                % Is of Type eOCPSlicePlane
            else
                % Is not of type eOCPSlicePlane
                validateattributes(plane,{'numeric'},{'finite','nonnegative','integer','nonnan','real'});
                try
                    plane = eOCPSlicePlane(uint32(plane));
                catch ME
                    rethrow(ME);
                end
            end
            
            this.slicePlane = plane;
        end
        
        
        function this = addIdListPredicate(this,predicate,value)
            % This method adds a predicate to the id list query
            if isa(predicate, 'eOCPPredicate')
                % Is of Type eOCPPredicate
            else
                % Is not of type eOCPPredicate
                validateattributes(predicate,{'numeric'},{'finite','nonnegative','integer','nonnan','real'});
                try
                    predicate = eOCPPredicate(uint32(predicate));
                catch ME
                    rethrow(ME);
                end
            end
            
            this.idListPredicates(predicate.char()) = value;
        end
        
        function this = removeIdListPredicate(this,predicate)
            % This method removes a predicate from the id list query
            this.idListPredicates.remove(predicate.char());
        end
        
        function this = setIdListLimit(this,limit)
            % This member function sets list size limit. 
            validateattributes(limit,{'numeric'},{'scalar','integer','finite','nonnegative','nonnan','real','positive','nonzero'});
            this.idListLimit = limit;
        end
        
        
        function this = setXyzCoord(this, xyz)
            % This method sets the class property 'xyzCoord' which
            % indicates a point in the data set by its x,y,z coordinate
            
            validateattributes(xyz,{'numeric'},{'integer','finite','nonnegative','nonnan','real','size', [1 3]});
            this.xyzCoord = xyz;
        end
        
        function this = setFilterIds(this,ids)
            % This member function sets list of filter IDs             
            validateattributes(ids,{'numeric'},{'integer','finite','nonnegative','nonnan','real'});
            this.filterIds = ids;
        end
        
        
        
        %% Methods - Validation & Dev Help
        function [valid, msg] = validate(this,dbInfo)
            % Method to validate cutout args.  Returns a true for valid, false for
            % invalid and a message describing what failed checks
            valid = true;
            msg = '';
            
            %% Basic checking
            if isempty(this.type)
                valid = false;
                msg = sprintf('%s- type is required for all queries and to enable full validation.\n',msg);
                return
            else
                switch this.type
                    case {eOCPQueryType.imageDense,...
                            eOCPQueryType.annoDense,...
                            eOCPQueryType.probDense}
                        
                        if isempty(this.xRange)
                            valid = false;
                            msg = sprintf('%s[E] X Range is required for dense cutouts\n',msg);
                        end
                        if isempty(this.yRange)
                            valid = false;
                            msg = sprintf('%s[E] Y Range is required for dense cutouts\n',msg);
                        end
                        if isempty(this.zRange)
                            valid = false;
                            msg = sprintf('%s[E] Z Range is required for dense cutouts\n',msg);
                        end
                        
                        % Warnings
                        if ~isempty(this.id)
                            msg = sprintf('%s[W] id ignored with Dense queries.\n',msg);
                        end
                        if isempty(this.resolution)
                            msg = sprintf('%s[W] Resolution is empty.  Default resolution will be used at runtime.\n',msg);
                        end
                        if ~isempty(this.slicePlane)
                            msg = sprintf('%s[W] slicePlane ignored with Dense queries.\n',msg);
                        end
                        if sum([isempty(this.aRange) isempty(this.bRange) isempty(this.cIndex)]) ~= 3
                            msg = sprintf('%s[W] A and B ranges and cIndex ignored with Dense queries.\n',msg);
                        end
                        if ~isempty(this.overlayAlpha)
                            msg = sprintf('%s[W] overlayAlpha ignored with Dense queries.\n',msg);
                        end
                        if this.idListPredicates.Count ~= 0
                            msg = sprintf('%s[W] idListPredicates ignored with Dense queries.\n',msg);
                        end
                        if ~isempty(this.xyzCoord)
                            msg = sprintf('%s[W] xyzCoord ignored with Dense queries.\n',msg);
                        end
                        if ~isempty(this.idListLimit)
                            msg = sprintf('%s[W] idListLimit ignored with Dense queries.\n',msg);
                        end
                        
                        
                    case {eOCPQueryType.imageSlice,...
                            eOCPQueryType.annoSlice}
                        
                        if isempty(this.aRange)
                            valid = false;
                            msg = sprintf('%s[E] A Range is required for slice cutouts\n',msg);
                        end
                        if isempty(this.bRange)
                            valid = false;
                            msg = sprintf('%s[E] B Range is required for slice cutouts\n',msg);
                        end
                        if isempty(this.cIndex)
                            valid = false;
                            msg = sprintf('%s[E] cIndex is required for slice cutouts\n',msg);
                        end
                        
                        if ~isempty(this.overlayAlpha)
                            msg = sprintf('%s[W] overlayAlpha ignored with slice cutouts.\n',msg);
                        end
                        
                        if isempty(this.slicePlane)
                            valid = false;
                            msg = sprintf('%s[E] slicePlane is required for slice cutouts\n',msg);
                        end
                        
                        if ~isa(this.slicePlane,'eOCPSlicePlane')
                            valid = false;
                            msg = sprintf('%s[E] slicePlane must be of type eOCPSlicePlane\n',msg);
                        end
                        
                        % Warnings
                        if ~isempty(this.id)
                            msg = sprintf('%s[W] id ignored with Dense queries.\n',msg);
                        end
                        if isempty(this.resolution)
                            msg = sprintf('%s[W] Resolution is empty.  Default resolution will be used at runtime.\n',msg);
                        end
                        if sum([isempty(this.xRange) isempty(this.yRange) isempty(this.zRange)]) ~= 3
                            msg = sprintf('%s[W] X,Y, and Z ranges ignored with Slice queries.\n',msg);
                        end
                        if this.idListPredicates.Count ~= 0
                            msg = sprintf('%s[W] idListPredicates ignored with Slice queries.\n',msg);
                        end
                        if ~isempty(this.idListLimit)
                            msg = sprintf('%s[W] idListLimit ignored with Slice queries.\n',msg);
                        end
                        
                    case {eOCPQueryType.overlaySlice}
                        
                        if isempty(this.aRange)
                            valid = false;
                            msg = sprintf('%s[E] A Range is required for slice cutouts\n',msg);
                        end
                        if isempty(this.bRange)
                            valid = false;
                            msg = sprintf('%s[E] B Range is required for slice cutouts\n',msg);
                        end
                        if isempty(this.cIndex)
                            valid = false;
                            msg = sprintf('%s[E] cIndex is required for slice cutouts\n',msg);
                        end
                        
                        if isempty(this.slicePlane)
                            valid = false;
                            msg = sprintf('%s[E] slicePlane is required for slice cutouts\n',msg);
                        end
                        
                        if ~isa(this.slicePlane,'eOCPSlicePlane')
                            valid = false;
                            msg = sprintf('%s[E] slicePlane must be of type eOCPSlicePlane\n',msg);
                        end
                        
                        % Warnings
                        if isempty(this.overlayAlpha)
                            this.overlayAlpha = 1;
                            msg = sprintf('%s[W] overlayAlpha missing. Value set to default of 1.\n',msg);
                        end
                        
                        if ~isempty(this.id)
                            msg = sprintf('%s[W] id ignored with Dense queries.\n',msg);
                        end
                        if isempty(this.resolution)
                            msg = sprintf('%s[W] Resolution is empty.  Default resolution will be used at runtime.\n',msg);
                        end
                        if sum([isempty(this.xRange) isempty(this.yRange) isempty(this.zRange)]) ~= 3
                            msg = sprintf('%s[W] X,Y, and Z ranges ignored with Slice queries.\n',msg);
                        end
                        if this.idListPredicates.Count ~= 0
                            msg = sprintf('%s[W] idListPredicates ignored with Slice queries.\n',msg);
                        end
                        if ~isempty(this.idListLimit)
                            msg = sprintf('%s[W] idListLimit ignored with Slice queries.\n',msg);
                        end
                        
                        
                    case {eOCPQueryType.RAMONDense}
                        if isempty(this.id)
                            valid = false;
                            msg = sprintf('%s[E] id is required for dense RAMON cutouts\n',msg);
                        end
                        
                        if sum([isempty(this.xRange) isempty(this.yRange) isempty(this.zRange)]) ~= 3
                            if sum([isempty(this.xRange) isempty(this.yRange) isempty(this.zRange)]) ~= 0
                                valid = false;
                                msg = sprintf('%s[E] If you are restricting the query to a cutout, X,Y, and Z ranges are required. Otherwise clear X,Y, and Z ranges.\n',msg);
                            end
                        end
                        
                        % Warnings
                        if isempty(this.resolution)
                            msg = sprintf('%s[W] Resolution is empty.  Default resolution will be used at runtime.\n',msg);
                        end
                        if ~isempty(this.slicePlane)
                            msg = sprintf('%s[W] slicePlane ignored with RAMON Object queries.\n',msg);
                        end
                        if sum([isempty(this.aRange) isempty(this.bRange) isempty(this.cIndex)]) ~= 3
                            msg = sprintf('%s[W] A and B ranges and cIndex ignored with RAMON Object queries.\n',msg);
                        end
                        if this.idListPredicates.Count ~= 0
                            msg = sprintf('%s[W] idListPredicates ignored with RAMON Object queries.\n',msg);
                        end
                        if ~isempty(this.xyzCoord)
                            msg = sprintf('%s[W] xyzCoord ignored with RAMON Object queries.\n',msg);
                        end
                        if ~isempty(this.overlayAlpha)
                            msg = sprintf('%s[W] overlayAlpha ignored with RAMON Object queries.\n',msg);
                        end
                        if ~isempty(this.idListLimit)
                            msg = sprintf('%s[W] idListLimit ignored with RAMON Object queries.\n',msg);
                        end
                        if ~isempty(this.filterIds)
                            msg = sprintf('%s[W] filterIds ignored with RAMON Object queries.\n',msg);
                        end
                        % not multichannel
                        msg = sprintf('%s[W] channels ignored with non-multichannel data.\n',msg);
                        
                    case {eOCPQueryType.RAMONVoxelList}
                        if isempty(this.id)
                            valid = false;
                            msg = sprintf('%s[E] id is required for RAMON voxelList\n',msg);
                        end
                        
                        % Warnings
                        if sum([isempty(this.xRange) isempty(this.yRange) isempty(this.zRange)]) ~= 3
                            msg = sprintf('%s[W] X,Y, and Z ranges ignored with RAMON voxel list queries.\n',msg);
                        end
                        if isempty(this.resolution)
                            msg = sprintf('%s[W] Resolution is empty.  Default resolution will be used at runtime.\n',msg);
                        end
                        if ~isempty(this.slicePlane)
                            msg = sprintf('%s[W] slicePlane ignored with RAMON Object queries.\n',msg);
                        end
                        if sum([isempty(this.aRange) isempty(this.bRange) isempty(this.cIndex)]) ~= 3
                            msg = sprintf('%s[W] A and B ranges and cIndex ignored with RAMON Object queries.\n',msg);
                        end
                        if this.idListPredicates.Count ~= 0
                            msg = sprintf('%s[W] idListPredicates ignored with RAMON Object queries.\n',msg);
                        end
                        if ~isempty(this.xyzCoord)
                            msg = sprintf('%s[W] xyzCoord ignored with RAMON Object queries.\n',msg);
                        end
                        if ~isempty(this.overlayAlpha)
                            msg = sprintf('%s[W] overlayAlpha ignored with RAMON Object queries.\n',msg);
                        end
                        if ~isempty(this.idListLimit)
                            msg = sprintf('%s[W] idListLimit ignored with RAMON Object queries.\n',msg);
                        end
                        if ~isempty(this.filterIds)
                            msg = sprintf('%s[W] filterIds ignored with RAMON Object queries.\n',msg);
                        end                        
                        % not multichannel
                        msg = sprintf('%s[W] channels ignored with non-multichannel data.\n',msg);
                        
                        
                    case eOCPQueryType.RAMONMetaOnly
                        if isempty(this.id)
                            valid = false;
                            msg = sprintf('%s[E] id is required for Metadata Only RAMON queries\n',msg);
                        end
                        
                        % Warnings
                        if isempty(this.resolution)
                            msg = sprintf('%s[W] Resolution is empty.  Default resolution will be used at runtime.\n',msg);
                        end
                        if sum([isempty(this.xRange) isempty(this.yRange) isempty(this.zRange)]) ~= 3
                            msg = sprintf('%s[W] X,Y, and Z ranges ignored with Metadata Only queries.\n',msg);
                        end
                        if ~isempty(this.slicePlane)
                            msg = sprintf('%s[W] slicePlane ignored with Metadata Only queries.\n',msg);
                        end
                        if sum([isempty(this.aRange) isempty(this.bRange) isempty(this.cIndex)]) ~= 3
                            msg = sprintf('%s[W] A and B ranges and cIndex ignored with Metadata Only queries.\n',msg);
                        end
                        if this.idListPredicates.Count ~= 0
                            msg = sprintf('%s[W] idListPredicates ignored with Metadata Only queries.\n',msg);
                        end
                        if ~isempty(this.xyzCoord)
                            msg = sprintf('%s[W] xyzCoord ignored with Metadata Only queries.\n',msg);
                        end
                        if ~isempty(this.overlayAlpha)
                            msg = sprintf('%s[W] overlayAlpha ignored with RAMON Object queries.\n',msg);
                        end
                        if ~isempty(this.idListLimit)
                            msg = sprintf('%s[W] idListLimit ignored with Metadata Only queries.\n',msg);
                        end
                        if ~isempty(this.filterIds)
                            msg = sprintf('%s[W] filterIds ignored with Metadata Only queries.\n',msg);
                        end                        
                        % not multichannel
                        msg = sprintf('%s[W] channels ignored with non-multichannel data.\n',msg);
                        
                    case eOCPQueryType.RAMONBoundingBox
                        
                        if isempty(this.id)
                            valid = false;
                            msg = sprintf('%s[E] id is required for RAMON object bounding box queries\n',msg);
                        end
                        
                        if sum([isempty(this.xRange) isempty(this.yRange) isempty(this.zRange)]) ~= 3
                            if sum([isempty(this.xRange) isempty(this.yRange) isempty(this.zRange)]) ~= 0
                                valid = false;
                                msg = sprintf('%s[E] If you are restricting the query to a cutout, X,Y, and Z ranges are required. Otherwise clear X,Y, and Z ranges.\n',msg);
                            end
                        end
                        
                        % Warnings
                        if isempty(this.resolution)
                            msg = sprintf('%s[W] Resolution is empty.  Default resolution will be used at runtime.\n',msg);
                        end
                        if sum([isempty(this.aRange) isempty(this.bRange) isempty(this.cIndex)]) ~= 3
                            msg = sprintf('%s[W] A and B ranges and cIndex ignored with RAMON Bounding Box queries.\n',msg);
                        end
                        if ~isempty(this.slicePlane)
                            msg = sprintf('%s[W] slicePlane ignored with RAMON Bounding Box queries.\n',msg);
                        end
                        if this.idListPredicates.Count ~= 0
                            msg = sprintf('%s[W] idListPredicates ignored with RAMON Bounding Box queries.\n',msg);
                        end
                        if ~isempty(this.overlayAlpha)
                            msg = sprintf('%s[W] overlayAlpha ignored with RAMON Bounding Box queries.\n',msg);
                        end
                        if ~isempty(this.xyzCoord)
                            msg = sprintf('%s[W] xyzCoord ignored with RAMON Bounding Box queries.\n',msg);
                        end
                        if ~isempty(this.idListLimit)
                            msg = sprintf('%s[W] idListLimit ignored with RAMON Bounding Box queries.\n',msg);
                        end
                        if ~isempty(this.filterIds)
                            msg = sprintf('%s[W] filterIds ignored with RAMON Bounding Box queries.\n',msg);
                        end
                        % not multichannel
                        msg = sprintf('%s[W] channels ignored with non-multichannel data.\n',msg);
                        
                    case eOCPQueryType.RAMONIdList
                        
                        if sum([isempty(this.xRange) isempty(this.yRange) isempty(this.zRange)]) ~= 3
                            if sum([isempty(this.xRange) isempty(this.yRange) isempty(this.zRange)]) ~= 0
                                valid = false;
                                msg = sprintf('%s[E] If you are restricting the query to a cutout, X,Y, and Z ranges are required. Otherwise clear X,Y, and Z ranges.\n',msg);
                            end
                        end
                        
                        % Warnings                        
                        if isempty(this.idListLimit)
                            msg = sprintf('%s[W] idListLimit is empty.  All annotations meeting the predicate requirements will be returned (this can take a long time depending on your database!)\n',msg);
                        end
                        if ~isempty(this.id)
                            msg = sprintf('%s[W] id ignored with Id List queries.\n',msg);
                        end
                        if isempty(this.resolution)
                            msg = sprintf('%s[W] Resolution is empty.  Default resolution will be used at runtime.\n',msg);
                        end
                        if sum([isempty(this.aRange) isempty(this.bRange) isempty(this.cIndex)]) ~= 3
                            msg = sprintf('%s[W] A and B ranges and cIndex ignored with Id List queries.\n',msg);
                        end
                        
                        if isempty(this.idListPredicates)
                            msg = sprintf('%s[W] idListPredicates is empty.  Every object in the database will be returned\n',msg);
                        end
                        if ~isempty(this.slicePlane)
                            msg = sprintf('%s[W] slicePlane ignored with Id List queries.\n',msg);
                        end
                        if ~isempty(this.overlayAlpha)
                            msg = sprintf('%s[W] overlayAlpha ignored with Id List queries.\n',msg);
                        end
                        if ~isempty(this.xyzCoord)
                            msg = sprintf('%s[W] xyzCoord ignored with Id List queries.\n',msg);
                        end
                        if ~isempty(this.filterIds)
                            msg = sprintf('%s[W] filterIds ignored with Id List queries.\n',msg);
                        end
                        % not multichannel
                        msg = sprintf('%s[W] channels ignored with non-multichannel data.\n',msg);
                        
                    case eOCPQueryType.voxelId
                        
                        if isempty(this.xyzCoord)
                            valid = false;
                            msg = sprintf('%s[E] xyzCoord is required when querying a voxel ID by xyz coordinate\n',msg);
                        end
                        
                        % Warnings
                        if isempty(this.resolution)
                            msg = sprintf('%s[W] Resolution is empty.  Default resolution will be used at runtime.\n',msg);
                        end
                        if sum([isempty(this.aRange) isempty(this.bRange) isempty(this.cIndex)]) ~= 3
                            msg = sprintf('%s[W] A and B ranges and cIndex ignored when querying a voxel ID by xyz coordinate.\n',msg);
                        end
                        if sum([isempty(this.xRange) isempty(this.yRange) isempty(this.zRange)]) ~= 3
                            msg = sprintf('%s[W] Cutout Args are ignored when querying a voxel ID by xyz coordinate.\n',msg);
                        end
                        if ~isempty(this.id)
                            msg = sprintf('%s[W] id is ignored when querying a voxel ID by xyz coordinate\n',msg);
                        end
                        if ~isempty(this.idListPredicates)
                            msg = sprintf('%s[W] idListPredicates is ignored when querying a voxel ID by xyz coordinate\n',msg);
                        end
                        if ~isempty(this.slicePlane)
                            msg = sprintf('%s[W] slicePlane ignored when querying a voxel ID by xyz coordinate\n',msg);
                        end
                        if ~isempty(this.overlayAlpha)
                            msg = sprintf('%s[W] overlayAlpha ignored querying a voxel ID by xyz coordinate.\n',msg);
                        end
                        if ~isempty(this.idListLimit)
                            msg = sprintf('%s[W] idListLimit ignored when querying a voxel ID by xyz coordinate.\n',msg);
                        end
                        if ~isempty(this.filterIds)
                            msg = sprintf('%s[W] filterIds ignored with voxel ID by xyz coordinate.\n',msg);
                        end
                        % not multichannel
                        msg = sprintf('%s[W] channels ignored with non-multichannel data.\n',msg);
                        
                        
                    otherwise
                        ex = MException('OCPQuery:BadQueryTYpe',...
                            'Invalid Query Type:%d',uint32(this.type));
                        throw(ex);
                end
            end
            
            %% Advanced Checking
            % if good so far and dbinfo exists do more advanced checking
            if valid == true && exist('dbInfo','var')
                
                switch this.type
                    case {eOCPQueryType.imageDense,...
                            eOCPQueryType.annoDense,...
                            eOCPQueryType.probDense}
                        
                        % Make sure Resolution if valid
                        if ~ismember(this.resolution,dbInfo.DATASET.RESOLUTIONS)
                            valid = false;
                            msg = sprintf('%s[E] Resolution not supported by database.\n',msg);
                            return
                        end
                                                
                        if ~isempty(this.resolution)
                            % Make sure x,y,z are good
                            imgDims = dbInfo.DATASET.IMAGE_SIZE(this.resolution);
                            if this.xRange(1) < 0
                                valid = false;
                                msg = sprintf('%s[E] Lower X Range out of valid dataset range.\n',msg);
                            end
                            if this.xRange(2) > imgDims(1)
                                valid = false;
                                msg = sprintf('%s[E] Upper X Range out of valid dataset range.\n',msg);
                            end
                            if this.yRange(1) < 0
                                valid = false;
                                msg = sprintf('%s[E] Lower Y Range out of valid dataset range.\n',msg);
                            end
                            if this.yRange(2) > imgDims(2)
                                valid = false;
                                msg = sprintf('%s[E] Upper Y Range out of valid dataset range.\n',msg);
                            end
                        else
                            msg = sprintf('%s[W] Since resolution not specified X and Y coordinates could not be checked against the database.\n',msg);
                        end
                        
                        if this.zRange(1) < dbInfo.DATASET.SLICERANGE(1)
                            valid = false;
                            msg = sprintf('%s[E] Lower Z Range out of valid dataset range.\n',msg);
                        end
                        if this.zRange(2) > dbInfo.DATASET.SLICERANGE(2)
                            valid = false;
                            msg = sprintf('%s[E] Upper Z Range out of valid dataset range.\n',msg);
                        end
                        
                        % Check if channels are listed and valid for
                        % multichannel queries
                        if (dbInfo.PROJECT.TYPE == eRAMONDataType.channels16) || ...
                                (dbInfo.PROJECT.TYPE == eRAMONDataType.channels8)
                            
                            if isempty(this.channels)
                                % Gotta have channels for multichannel
                                % data!
                                valid = false;
                                msg = sprintf('%s[E] Must specify channels to cutout for multichannel data\n',msg);
                                return
                            end
                            
                            
                            % Check that channels requested are in DB
                            channel_cell_array = fieldnames(dbInfo.CHANNELS);
                            
                            if isa(this.channels, 'cell')
                                % Collection of channels
                                for jj = 1:length(this.channels)
                                    ch_matches(jj) = any(strcmp(this.channels{jj},channel_cell_array));  %#ok<AGROW>
                                end
                                
                                if all(ch_matches) == 0
                                    valid = false;
                                    bad_ind = find(ch_matches == 0);
                                    msg = sprintf('%s[E] Channels not found in database: ',msg);
                                    tmsg = sprintf('%s,',this.channels{bad_ind}); %#ok<FNDSB>
                                    msg = sprintf('%s%s\n',msg, tmsg(1:end-1));
                                    return
                                end
                            end
                        else
                            % not multichannel
                            msg = sprintf('%s[W] channels ignored with non-multichannel data.\n',msg);
                        end
                        
                        
                    case {eOCPQueryType.imageSlice,...
                            eOCPQueryType.annoSlice,...
                            eOCPQueryType.overlaySlice}
                        
                        % Make sure Resolution if valid
                        if ~ismember(this.resolution,dbInfo.DATASET.RESOLUTIONS)
                            valid = false;
                            msg = sprintf('%s[E] Resolution not supported by database.\n',msg);
                            return
                        end
                        
                        % Make sure a,b,c are good
                        switch this.slicePlane
                            case eOCPSlicePlane.xy
                                if ~isempty(this.resolution)
                                    imgDims = dbInfo.DATASET.IMAGE_SIZE(this.resolution);
                                    if this.aRange(1) < 0
                                        valid = false;
                                        msg = sprintf('%s[E] Lower A Range (X dim) out of valid dataset range.\n',msg);
                                    end
                                    if this.aRange(2) > imgDims(1)
                                        valid = false;
                                        msg = sprintf('%s[E] Upper A Range (X dim) out of valid dataset range.\n',msg);
                                    end
                                    if this.bRange(1) < 0
                                        valid = false;
                                        msg = sprintf('%s[E] Lower B Range (Y dim) out of valid dataset range.\n',msg);
                                    end
                                    if this.bRange(2) > imgDims(2)
                                        valid = false;
                                        msg = sprintf('%s[E] Upper B Range (Y dim) out of valid dataset range.\n',msg);
                                    end
                                else
                                    msg = sprintf('%s[W] Since resolution not specified X and Y coordinates could not be checked against the database.\n',msg);
                                end
                                
                                if this.cIndex < dbInfo.DATASET.SLICERANGE(1) || this.cIndex > dbInfo.DATASET.SLICERANGE(2)
                                    valid = false;
                                    msg = sprintf('%s[E] cIndex (Z dim) out of valid dataset range.\n',msg);
                                end
                                
                                
                            case eOCPSlicePlane.xz
                                if ~isempty(this.resolution)
                                    imgDims = dbInfo.DATASET.IMAGE_SIZE(this.resolution);
                                    if this.aRange(1) < 0
                                        valid = false;
                                        msg = sprintf('%s[E] Lower A Range (X dim) out of valid dataset range.\n',msg);
                                    end
                                    if this.aRange(2) > imgDims(1)
                                        valid = false;
                                        msg = sprintf('%s[E] Upper A Range (X dim) out of valid dataset range.\n',msg);
                                    end
                                    if this.bRange(1) < dbInfo.DATASET.SLICERANGE(1)
                                        valid = false;
                                        msg = sprintf('%s[E] Lower B Range (Z dim) out of valid dataset range.\n',msg);
                                    end
                                    if this.bRange(2) > dbInfo.DATASET.SLICERANGE(2)
                                        valid = false;
                                        msg = sprintf('%s[E] Upper B Range (Z dim) out of valid dataset range.\n',msg);
                                    end
                                else
                                    msg = sprintf('%s[W] Since resolution not specified X and Y coordinates could not be checked against the database.\n',msg);
                                end
                                
                                if this.cIndex < 0 || this.cIndex > imgDims(2)
                                    valid = false;
                                    msg = sprintf('%s[E] cIndex (Y dim) out of valid dataset range.\n',msg);
                                end
                                
                                
                            case eOCPSlicePlane.yz
                                if ~isempty(this.resolution)
                                    imgDims = dbInfo.DATASET.IMAGE_SIZE(this.resolution);
                                    if this.aRange(1) < 0
                                        valid = false;
                                        msg = sprintf('%s[E] Lower A Range (Y dim) out of valid dataset range.\n',msg);
                                    end
                                    if this.aRange(2) > imgDims(2)
                                        valid = false;
                                        msg = sprintf('%s[E] Upper A Range (Y dim) out of valid dataset range.\n',msg);
                                    end
                                    if this.bRange(1) < dbInfo.DATASET.SLICERANGE(1)
                                        valid = false;
                                        msg = sprintf('%s[E] Lower B Range (Z dim) out of valid dataset range.\n',msg);
                                    end
                                    if this.bRange(2) > dbInfo.DATASET.SLICERANGE(2)
                                        valid = false;
                                        msg = sprintf('%s[E] Upper B Range (Z dim) out of valid dataset range.\n',msg);
                                    end
                                else
                                    msg = sprintf('%s[W] Since resolution not specified X and Y coordinates could not be checked against the database.\n',msg);
                                end
                                
                                if this.cIndex < 0 || this.cIndex > imgDims(1)
                                    valid = false;
                                    msg = sprintf('%s[E] cIndex (X dim) out of valid dataset range.\n',msg);
                                end
                                
                        end
                        
                        % Check if channels are listed and valid for
                        % multichannel queries
                        if (dbInfo.PROJECT.TYPE == eRAMONDataType.channels16) || ...
                                (dbInfo.PROJECT.TYPE == eRAMONDataType.channels8)
                            
                            % Check that channels requested are in DB
                            channel_cell_array = fieldnames(dbInfo.CHANNELS);
                            
                            if isa(this.channels, 'cell')
                                % Collection of channels
                                for jj = 1:length(this.channels)                                    
                                    ch_matches(jj) = any(strcmp(this.channels{jj},channel_cell_array));  %#ok<AGROW>
                                end
                                
                                if all(ch_matches) == 0
                                    valid = false;
                                    bad_ind = find(ch_matches == 0);
                                    msg = sprintf('%s[E] Channels not found in database: ',msg);
                                    tmsg = sprintf('%s,',this.channels{bad_ind}); %#ok<FNDSB>
                                    msg = sprintf('%s%s\n',msg, tmsg(1:end-1));
                                   return
                                end
                            end
                        else
                            % not multichannel
                            msg = sprintf('%s[W] channels ignored with non-multichannel data.\n',msg);
                        end
                        
                        
                        
                    case {eOCPQueryType.RAMONDense}
                        % Make sure Resolution if valid
                        if ~ismember(this.resolution,dbInfo.DATASET.RESOLUTIONS)
                            valid = false;
                            msg = sprintf('%s[E] Resolution not supported by database.\n',msg);
                            return
                        end
                        
                        % If Doing a cutout then check xyz
                        if ~isempty(this.xRange) && ~isempty(this.yRange) && ~isempty(this.zRange)
                            if ~isempty(this.resolution)
                                imgDims = dbInfo.DATASET.IMAGE_SIZE(this.resolution);
                                if this.xRange(1) < 0
                                    valid = false;
                                    msg = sprintf('%s[E] Lower X Range out of valid dataset range.\n',msg);
                                end
                                if this.xRange(2) > imgDims(1)
                                    valid = false;
                                    msg = sprintf('%s[E] Upper X Range out of valid dataset range.\n',msg);
                                end
                                if this.yRange(1) < 0
                                    valid = false;
                                    msg = sprintf('%s[E] Lower Y Range out of valid dataset range.\n',msg);
                                end
                                if this.yRange(2) > imgDims(2)
                                    valid = false;
                                    msg = sprintf('%s[E] Upper Y Range out of valid dataset range.\n',msg);
                                end
                            else
                                msg = sprintf('%s[W] Since resolution not specified X and Y coordinates could not be checked against the database.\n',msg);
                            end
                            
                            if this.zRange(1) < dbInfo.DATASET.SLICERANGE(1)
                                valid = false;
                                msg = sprintf('%s[E] Lower Z Range out of valid dataset range.\n',msg);
                            end
                            if this.zRange(2) > dbInfo.DATASET.SLICERANGE(2)
                                valid = false;
                                msg = sprintf('%s[E] Upper Z Range out of valid dataset range.\n',msg);
                            end
                        end
                        
                        
                    case {eOCPQueryType.RAMONVoxelList}
                        % Make sure Resolution if valid
                        if ~ismember(this.resolution,dbInfo.DATASET.RESOLUTIONS)
                            valid = false;
                            msg = sprintf('%s[E] Resolution not supported by database.\n',msg);
                            return
                        end
                        
                    case eOCPQueryType.RAMONMetaOnly
                        % No db checks
                        
                        
                    case eOCPQueryType.RAMONBoundingBox
                        % Make sure Resolution if valid
                        if ~ismember(this.resolution,dbInfo.DATASET.RESOLUTIONS)
                            valid = false;
                            msg = sprintf('%s[E] Resolution not supported by database.\n',msg);
                            return
                        end
                        
                        % If Doing a cutout then check xyz
                        if ~isempty(this.xRange) && ~isempty(this.yRange) && ~isempty(this.zRange)
                            if ~isempty(this.resolution)
                                imgDims = dbInfo.DATASET.IMAGE_SIZE(this.resolution);
                                if this.xRange(1) < 0
                                    valid = false;
                                    msg = sprintf('%s[E] Lower X Range out of valid dataset range.\n',msg);
                                end
                                if this.xRange(2) > imgDims(1)
                                    valid = false;
                                    msg = sprintf('%s[E] Upper X Range out of valid dataset range.\n',msg);
                                end
                                if this.yRange(1) < 0
                                    valid = false;
                                    msg = sprintf('%s[E] Lower Y Range out of valid dataset range.\n',msg);
                                end
                                if this.yRange(2) > imgDims(2)
                                    valid = false;
                                    msg = sprintf('%s[E] Upper Y Range out of valid dataset range.\n',msg);
                                end
                            else
                                msg = sprintf('%s[W] Since resolution not specified X and Y coordinates could not be checked against the database.\n',msg);
                            end
                            
                            if this.zRange(1) < dbInfo.DATASET.SLICERANGE(1)
                                valid = false;
                                msg = sprintf('%s[E] Lower Z Range out of valid dataset range.\n',msg);
                            end
                            if this.zRange(2) > dbInfo.DATASET.SLICERANGE(2)
                                valid = false;
                                msg = sprintf('%s[E] Upper Z Range out of valid dataset range.\n',msg);
                            end
                        end
                        
                        
                    case eOCPQueryType.RAMONIdList
                        
                        % If Doing a cutout then check xyz
                        if ~isempty(this.xRange) && ~isempty(this.yRange) && ~isempty(this.zRange)
                            % Make sure Resolution if valid
                            if ~isempty(this.resolution)
                                if ~ismember(this.resolution,dbInfo.DATASET.RESOLUTIONS)
                                    valid = false;
                                    msg = sprintf('%s[E] Resolution not supported by database.\n',msg);
                                    return
                                end
                                
                                imgDims = dbInfo.DATASET.IMAGE_SIZE(this.resolution);
                                if this.xRange(1) < 0
                                    valid = false;
                                    msg = sprintf('%s[E] Lower X Range out of valid dataset range.\n',msg);
                                end
                                if this.xRange(2) > imgDims(1)
                                    valid = false;
                                    msg = sprintf('%s[E] Upper X Range out of valid dataset range.\n',msg);
                                end
                                if this.yRange(1) < 0
                                    valid = false;
                                    msg = sprintf('%s[E] Lower Y Range out of valid dataset range.\n',msg);
                                end
                                if this.yRange(2) > imgDims(2)
                                    valid = false;
                                    msg = sprintf('%s[E] Upper Y Range out of valid dataset range.\n',msg);
                                end
                            else
                                msg = sprintf('%s[W] Since resolution not specified X and Y coordinates could not be checked against the database.\n',msg);
                            end
                            
                            if this.zRange(1) < dbInfo.DATASET.SLICERANGE(1)
                                valid = false;
                                msg = sprintf('%s[E] Lower Z Range out of valid dataset range.\n',msg);
                            end
                            if this.zRange(2) > dbInfo.DATASET.SLICERANGE(2)
                                valid = false;
                                msg = sprintf('%s[E] Upper Z Range out of valid dataset range.\n',msg);
                            end
                        end
                        
                    case eOCPQueryType.voxelId
                        
                        % Make sure Resolution if valid
                        if ~isempty(this.resolution)
                            if ~ismember(this.resolution,dbInfo.DATASET.RESOLUTIONS)
                                valid = false;
                                msg = sprintf('%s[E] Resolution not supported by database.\n',msg);
                            end
                        end
                        
                        if ~isempty(this.resolution)
                            imgDims = dbInfo.DATASET.IMAGE_SIZE(this.resolution);
                            if this.xyzCoord(1) < 0
                                valid = false;
                                msg = sprintf('%s[E] X coord out of valid dataset range.\n',msg);
                            end
                            if this.xyzCoord(1) > imgDims(1)
                                valid = false;
                                msg = sprintf('%s[E] X coord out of valid dataset range.\n',msg);
                            end
                            if this.xyzCoord(2) < 0
                                valid = false;
                                msg = sprintf('%s[E] Y coord out of valid dataset range.\n',msg);
                            end
                            if this.xyzCoord(2) > imgDims(2)
                                valid = false;
                                msg = sprintf('%s[E] Y coord out of valid dataset range.\n',msg);
                            end
                        else
                            msg = sprintf('%s[W] Since resolution not specified X and Y coordinates could not be checked against the database.\n',msg);
                        end
                        
                        if this.xyzCoord(3) < dbInfo.DATASET.SLICERANGE(1)
                            valid = false;
                            msg = sprintf('%s[E] z coord out of valid dataset range.\n',msg);
                        end
                        if this.xyzCoord(3) > dbInfo.DATASET.SLICERANGE(2)
                            valid = false;
                            msg = sprintf('%s[E] Z coord out of valid dataset range.\n',msg);
                        end
                        
                    otherwise
                        ex = MException('OCPQuery:BadQueryTYpe',...
                            'Invalid Query Type:%d',uint32(this.type));
                        throw(ex);
                end
            end
        end
        
        %% Methods - Save Query
        function save(this,file)
            % Method to save a query for later use.  If filename is not
            % included a dialog will open to select location to save.
            if ~exist('file','var')
                [filename,pathname] = uiputfile('*.mat','Save Query As');
                
                if isequal(filename,0)
                    warning('OCPQuery:FileSelectionCancel','No file was selected.  Query not saved.');
                    return;
                end
                
                file = fullfile(pathname,filename);
            end
            
            query = this; %#ok<NASGU>
            
            save(file,'query');
        end
        
    end
    
    %% Static Method for Loading
    methods(Static)
        
        function query = open(file)
            % Method to load a saved query.  If filename is not
            % included a dialog will open to select file to load
            
            if ~exist('file','var')
                [filename, pathname, ~] = uigetfile( ...
                    {  '*.mat','MAT-files (*.mat)'}, ...
                    'Pick a Query File', ...
                    'MultiSelect', 'off');
                
                if isequal(filename,0)
                    warning('OCPQuery:FileSelectionCancel','No file was selected.  Query not opened.');
                    query = [];
                    return;
                end
                
                file = fullfile(pathname,filename);
            end
            
            loaded = load(file);
            query = loaded.query;
        end
    end
    
end

