function matlabInitTFunction(double,str,mat,bool)
    %matlabInitTestFunction Function used by the matlabInit unit test
    fprintf('00001=%f\n',double);    
    fprintf('00002=%s\n',str); 
    fprintf('00003=%d %d %d %d\n',mat(1,1),mat(1,2),mat(2,1),mat(2,2));  
    fprintf('00004=%d\n',bool); 
end

