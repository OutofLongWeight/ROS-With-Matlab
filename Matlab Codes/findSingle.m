function [res] = findSingle(M)
path='E:\Download\ȫ�����\HSV��ȡ������\sample\';
fileFolder=fullfile(path);%��ȡ��׼ָʾͼ���ļ�
dirOutput=dir(fullfile(fileFolder,'*.*'));
fileNames={dirOutput.name};

[fs,fl,ff]=size(fileNames);%��ȡ��׼ͼ��

M=imresize(M,[100 100]);
figure;
imshow(M);
M=imbinarize(rgb2gray(M));
R1=zeros(1,fl);
%ѭ���Ա�ͼ������ȡ���
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
[R1,s]=sort(R1,'descend');% �������п��ܵĽ��
% s
% fileNames
img=imread(char([path,fileNames{1,s(1)}]));
figure;imshow(img);title(fileNames{1,s(1)});
res={fileNames{1,s(1)}};
end
%ƥ���㷨������ȷ�����Ը�����������������
% res=zeros(1,3);
% for i=1:3
%     img=imread(char([path,fileNames{1,s(i)}]));
%     figure;imshow(img);title(fileNames{1,s(i)});
%     res(i)={fileNames{1,s(i)}};
% end