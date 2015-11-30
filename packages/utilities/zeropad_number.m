function numOut = zeropad_number(numIn, digits)

if isnumeric(numIn)
numIn = num2str(numIn);
end

if ~isstr(numIn)
    error('text to convert should be a string at this point')
end

pad = digits - length(numIn);

numOut = [repmat('0',[1,pad]), numIn];