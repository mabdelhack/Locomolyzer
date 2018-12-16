%This function will take two matrices: a 1xN matrix of labels, and a MxN
%matrix of values, and will save them to the savePath as a tab-delimited
%file easily opened in excel

function saveDataMatrix(labels, data, savePath, append)

if nargin==3
    append=0;
end

if ~append
    %the following code generates the labels matrix
    ls=[];
    for n=1:length(labels(1,:))
        curLabel=labels(n);
        ls=[ls curLabel{1} '\t'];
    end
    ls=[ls '\n'];

    if ~isempty(data)
        ds=[];
        data=data';
        for n=1:length(data(1,:))
            for m=1:length(data(:,1))
                curData=data(m,n);
                try
                    if ~isnumeric(curData{1})
                        ds=[ds curData{1} '\t'];
                    else
                        ds=[ds num2str(curData{1}) '\t'];
                    end
                catch
                    ds=[ds num2str(data(m,n)) '\t'];
                end
            end
            ds=[ds '\n'];
        end
    end

    fid=fopen(savePath,'wt');
    fprintf(fid,ls);
    if ~isempty(data)
        fprintf(fid,ds);
    end
    fclose(fid);


elseif append
    oldData=textread(savePath,'%s','delimiter','\t','endofline','\n');
    resetData=[];
    chunkStart=1;
    for i=1:length(oldData(:,1))
        if isempty(strtrim(oldData{i}))
            resetData=[resetData; oldData(chunkStart:i-1)'];
            chunkStart=i+1;
        end
    end
    data=[resetData(2:end,:); data];
    saveDataMatrix(labels,data,savePath);
end
    