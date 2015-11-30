function edgeList = graph_retrieval(synLocation, synToken, synChannel, synResolution, synIdList, neuLocation, neuToken, neuChannel, neuResolution, segGraph)
% TODO This doesn't quite work because of segment access

if isempty(segGraph)
    segGraph = 0;
end

f = OCPFields;
edgeList = [];

ocpS = OCP();
ocpS.setServerLocation(synLocation);
ocpS.setAnnoToken(synToken);
ocpS.setAnnoChannel(synChannel);

ocpS.setDefaultResolution(synResolution);

ocpN = OCP();
ocpN.setServerLocation(neuLocation);
ocpN.setAnnoToken(neuToken);
ocpN.setAnnoChannel(neuChannel);
ocpN.setDefaultResolution(neuResolution);

% Find all synapses
if isempty(synIdList)
    q1 = OCPQuery(eOCPQueryType.RAMONIdList);
    q1.setResolution(synResolution);
    
    q1.addIdListPredicate(eOCPPredicate.type, eRAMONAnnoType.synapse);
    synIdList = ocpS.query(q1);
end

% For each synapse find segments and neurons

if segGraph == 1
    disp('Creating a segment-based graph, rather than a neuron-based graph...')
end

for i = 1:length(synIdList)
    edgePairs = [];
    
    segId = ocpS.getField(synIdList(i),f.synapse.segments);
    if ~isempty(segId)
        segId = segId(:,1)'; %TODO
        segId(segId == 0) = [];
        
        if segGraph
            if ~isempty(segId)
                edgePairs = combnk(segId,2);
                edgePairs(:,3) = repmat(synIdList(i),size(edgePairs,1), 1);
                %TODO direction information
                edgePairs(:,4) = repmat(0, size(edgePairs,1), 1);
            end
            
        else
            
            nList = [];
            for j = 1:length(segId)
                try
                    nList(end+1) = ocpN.getField(segId(j), f.segment.neuron);
                catch
                    disp('no partner found')
                end
            end
            nList(nList == 0) = []; %removes segments with no neurons...
            
            if ~isempty(nList)
                edgePairs = combnk(nList,2);
                edgePairs(:,3) = repmat(synIdList(i),size(edgePairs,1), 1);
                
                %TODO direction information
                edgePairs(:,4) = repmat(0, size(edgePairs,1), 1);
                
            end
        end
        edgeList = [edgeList; edgePairs];
        
    else
        disp('no synapse-segment links for this synapse')
    end
end

%TODO
for ii = 1:size(edgeList,1)
    ee = edgeList(ii,1:2);
    edgeList(ii,1) = min(ee);
    edgeList(ii,2) = max(ee);
end

