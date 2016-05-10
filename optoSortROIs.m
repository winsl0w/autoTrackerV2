function [ROI_coords,mazeOri,ROI_bounds,centers]=optoSortROIs(ROI_coords,mazeOri,centers,ROI_bounds)

%% Separate right-side down ROIs (0) from right to left
tmpCoords_0=centers(~mazeOri,:);
x=tmpCoords_0(:,1).^2;
[val,xSorted]=sort(x);
numRows=mode(diff(find(diff(val)>std(diff(val))==1)));
if isnan(numRows)
    numRows=1;
end
if mod(length(xSorted),numRows)~=0
    xSorted=[xSorted;ones(numRows-mod(length(xSorted),numRows),1)];
end

xSorted=reshape(xSorted,numRows,floor(length(xSorted)/numRows));

permutation_0=[];
for i=1:size(xSorted,2)
y=tmpCoords_0(xSorted(:,i),2).^2;
[~,ySorted]=sort(y);
xSorted(:,i)=xSorted(ySorted,i);
    if sum(xSorted(ySorted,i)==1)>1
    xSorted(xSorted(:,i)==1,i)=NaN;
    end
end
permutation_0=reshape(xSorted',numel(xSorted),1);
permutation_0(isnan(permutation_0))=[];

%% Separate right-side up ROIs (1) from right to left
permutation_1=[];

if sum(mazeOri)>0
tmpCoords_1=centers(mazeOri,:);
x=tmpCoords_1(:,1).^2;
[val,xSorted]=sort(x);
numRows=mode(diff(find(diff(val)>std(diff(val))==1)));
if isnan(numRows)
    numRows=1;
end
if mod(length(xSorted),numRows)~=0
    xSorted=[xSorted;ones(numRows-mod(length(xSorted),numRows),1)];
end

xSorted=reshape(xSorted,numRows,floor(length(xSorted)/numRows));

for i=1:size(xSorted,2)
y=tmpCoords_1(xSorted(:,i),2).^2;
[~,ySorted]=sort(y); 
xSorted(:,i)=xSorted(ySorted,i);
end
permutation_1=reshape(xSorted',numel(xSorted),1);
permutation_1=permutation_1+size(permutation_0,1);

% Sort coordinates into mazeOri=0 and mazeOri=1 categories for
% to align with permutation vectors
centers=[tmpCoords_0;tmpCoords_1];
tmpROI_0=ROI_coords(~mazeOri,:);
tmpROI_1=ROI_coords(mazeOri,:);
ROI_coords=[tmpROI_0;tmpROI_1];
tmpBounds_0=ROI_bounds(~mazeOri,:);
tmpBounds_1=ROI_bounds(mazeOri,:);
ROI_bounds=[tmpBounds_0;tmpBounds_1];
end

% Define master permutation vector and sort ROI_coords
permutation=[permutation_0;permutation_1];
excess=find(permutation==1);
    if length(excess)>1
        permutation(excess(2:end))=[];
    end
permutation(permutation>size(ROI_coords,1))=permutation(permutation>size(ROI_coords,1))-(max(permutation)-size(ROI_coords,1));
ROI_coords=ROI_coords(permutation,:);
ROI_bounds=ROI_bounds(permutation,:);
centers=centers(permutation,:);

% Sort mazeOri to match new ROI_coords permutation
mazeOri(1:size(permutation_0,1))=0;
mazeOri(size(permutation_0,1)+1:size(permutation,1))=1;
mazeOri=boolean(mazeOri);

end



