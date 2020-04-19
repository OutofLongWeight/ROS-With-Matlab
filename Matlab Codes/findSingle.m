function [res] = findSingle(M)
path='E:\Download\全部打包\HSV提取基础版\sample\';
fileFolder=fullfile(path);%读取标准指示图标文件
dirOutput=dir(fullfile(fileFolder,'*.*'));
fileNames={dirOutput.name};

[fs,fl,ff]=size(fileNames);%读取标准图样

M=imresize(M,[100 100]);
figure;
imshow(M);
M=imbinarize(rgb2gray(M));
R1=zeros(1,fl);
%循环对比图标与提取结果
for i=3:fl
    %             fileNames{1,i}
    N=imread(char([path,fileNames{1,i}]));
    N=imresize(N,[100 100]);
    [sl,ss]=size(size(N));
    if (ss > 2)
        N=imbinarize(rgb2gray(N));
    end
    R1(i)=corr2(M,N);
end
[R1,s]=sort(R1,'descend');% 倒序排列可能的结果
% s
% fileNames
img=imread(char([path,fileNames{1,s(1)}]));
figure;imshow(img);title(fileNames{1,s(1)});
res={fileNames{1,s(1)}};
end
%匹配算法不够精确，所以给出三个可能性最大的
% res=zeros(1,3);
% for i=1:3
%     img=imread(char([path,fileNames{1,s(i)}]));
%     figure;imshow(img);title(fileNames{1,s(i)});
%     res(i)={fileNames{1,s(i)}};
% end