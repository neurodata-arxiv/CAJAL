function attredgeWriter(edgeList, attredgeFile)
% Helper function to write attributed edge files toward graphML

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% (c) [2014] The Johns Hopkins University / Applied Physics Laboratory All Rights Reserved. Contact the JHU/APL Office of Technology Transfer for any additional rights.  www.jhuapl.edu/ott
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% 
%    http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


fid = fopen(attredgeFile,'w');

if size(edgeList,2) == 4
    attedgeheader = '#source, target, synapse_id, direction';
    
    
    fprintf(fid,attedgeheader);
    fprintf(fid,'\n');
    for i = 1:length(edgeList)
        fprintf(fid,'%d, %d, %d, %d \n',edgeList(i,1), edgeList(i,2), edgeList(i,3), edgeList(i,4));
    end
    
elseif size(edgeList,2) == 5
    attedgeheader = '#source, target, synapse_id, direction, synapse_truth_id';
    
    fprintf(fid,attedgeheader);
    fprintf(fid,'\n');
    for i = 1:size(edgeList,1) %use size to be more explicit
        fprintf(fid,'%d, %d, %d, %d, %d\n',edgeList(i,1), edgeList(i,2), edgeList(i,3), edgeList(i,4), edgeList(i,5));
    end
    
else
    error('Attredge Writer does not support this edgelist.')
end

fclose(fid);
