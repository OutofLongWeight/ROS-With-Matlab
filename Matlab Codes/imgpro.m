%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%ͼ�����ҵ����ܵ�·��ͼ�񣨺�ɫ�߿򣩲��������A( �� ������ )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [res] = imgpro(I,newnet)
% close all;
%I=imresize(I,[592 748]);%ͼƬ���ţ�ָ������

% figure,imshow(I);title('ԭͼ');
%�����ɫ
Hsv=rgb2hsv(I);   %��ͼ����RGB��ɫ�ռ�ת��ΪHSV��ɫ�ռ�
%figure,imshow(Hsv);title('Hsv');
%hsvģ�ͣ�hɫ��������s���Ͷ�0~1��v����0���ڵ�1����
I1=Hsv(:,:,1);%hsv�����һά�ǽǶ�->ɫ��
I2=Hsv(:,:,2);%���Ͷ�
I3=Hsv(:,:,3);%����
%figure,imshow(I1);title('Hsv(:,:,1)');
%��ֵ��Ҫ��������
I1=roicolor(I1,0,0.0556)+roicolor(I1,0.6667,1);
I2=roicolor(I2,0.523,1);
I3=roicolor(I3,0.4,1);
%figure;subplot(131);imshow(BW1);subplot(132);imshow(BW2);subplot(133);imshow(BW3);
BW=I1.*I2.*I3;
% BW=roicolor(I1,0.0277,0.032); %������ɫ��ֵ����ɫ���󶼶���ʾΪ��ɫ,���඼Ϊ��ɫ,�������ͼ��Ķ�ֵ��
figure,imshow(BW);title('ֻ��ʾ��ɫ');

% ��ȡ��ͨ����->·���������
se=strel('disk',20); %����һ��ָ���뾶10��ƽ��Բ���εĽṹԪ��
BW=imclose(BW,se);%��ͼ���ð�ɫ�������㣬�뾶10����ȫС�ն�������ɹ�Ӱ�쵼�º�Ȧ����ͨ
figure,imshow(BW);title('��������');
% se=strel('disk',2);
% BW=imopen(BW,se);
% figure,imshow(BW);title('������');
% SE=ones(10);%10*10��������
% PZ=imdilate(BW1,SE);%����ֵͼ�����ͣ�
% figure,imshow(PZ);title('���ͺ��ͼ��');
TC=bwfill(BW,'holes');
figure,imshow(TC);title('�����ͼ��');
% ����ͼ����˿���Ŀ������ȫ���ǰ�ɫ
decI=uint8(I.*uint8(TC));
% �����������ͨ���ֱ�������ֵ
I1=decI(:,:,1);
I2=decI(:,:,2);
I3=decI(:,:,3);
I1(TC==0)=255;
I2(TC==0)=255;
I3(TC==0)=255;
decI(:,:,1)=I1;
decI(:,:,2)=I2;
decI(:,:,3)=I3;
figure,imshow(decI);title('ȥ������ɫ');
L=bwlabeln(TC); %�������ã�������ͨ���򣬽���ͨ������1��2��3.����
S=regionprops(L,'Area','Centroid','BoundingBox');  %��ȡ���ͼ��L�����������һϵ����������S,��ȡ�������ظ������������ģ�ÿ���������С����
cent=cat(1,S.Centroid);%��S.Centroid�ص�һά���У�����
boud=cat(1,S.BoundingBox); %��S.BoundingBox�ص�һά���У�����ÿ�������Ǹ��������������Ͻǵ�һ�����x y�����Լ�����
Len=length(S);
area=cat(1,S.Area);
t2=0;t4=0;t7=0;t8=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��ȡ���������ͨ���򩥩�(���`��*|||����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&%%%%%%%%%%%%%%%%%%%
[area,as]=sort(area,'descend');
imnum=min(8,numel(area));
for i=1:imnum
    Max(i)=as(i);
    MR(i)=0;
    MX(i)=0;
    MY(i)=0;
end
Max1=0;Max2=0;Max3=0;ttq=0;

%���ݸ������������ҳ����������������飬�ֱ����Max1��Max2��Max3  Max1>Max2>Max3
%Max�����¼��������������ı�־-----��Դ��S                         Max(1)>Max(2)>Max(3)
% for i=1:Len
%     if (S(i).Area>=Max1)
%         Max3=Max2;Max(3)=Max(2);
%         Max2=Max1;Max(2)=Max(1);
%         Max1=S(i).Area;Max(1)=i;
%     else if(S(i).Area>=Max2)
%             Max3=Max2;Max(3)=Max(2);
%             Max2=S(i).Area;Max(2)=i;
%         else if(S(i).Area>=Max3)
%                 Max3=S(i).Area;Max(3)=i;
%             end
%         end
%     end
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �޳�����������((*��գ�)س(��գ�*))��!!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(Max==zeros(1,imnum))
    imshowage=0;errordlg(' û��·�꣡��','������Ϣ');%������ͨ����ʱֹͣ����һ�㲻����
else
    imshowage=1;
    for i=1:imnum
        tz(i)=0;
        Mblen(i)=0;
        Mbwid(i)=0;
    end
    [hang,lie,r]=size(BW);
    for i=1:imnum
        if Max(i) == 0
            break;
        end
        X=cent(Max(i),1);Y=cent(Max(i),2);%��ɫΪ1��ȡ�����ľ��������������ͨ�����Ӧ���ĵ�����
        MX(i)=round(X);MY(i)=round(Y);%���Ŀ��ܲ�������������һ������������round
        bx=boud(Max(i),1);by=boud(Max(i),2);blen=boud(Max(i),4);bwid=boud(Max(i),3);%���Ͻǵ�һ���㣬�Լ����Ϳ�
        bx1=round(bx);by1=round(by);Mblen(i)=round(blen);Mbwid(i)=round(bwid);
        if (blen>=bwid)
            MR=bwid;
        else
            MR=blen;
        end
        
        %Matlab��ͼ������������y����x  [y,x],�����жϱ߽磬�Ƿ񳬳�ͼ������
        if (MX(i)+round(MR/4)<=lie&&MY(i)+round(MR/6)<=hang&&TC(MY(i)+round(MR/6),MX(i)+round(MR/4))==1)
            t2=1;
        end
        
        if (MX(i)-round(MR/4)>0&&MY(i)-round(MR/6)>0&&TC(MY(i)-round(MR/6),MX(i)-round(MR/4))==1)
            t4=1;
        end
        
        if (MY(i)+round(MR/6)<=hang&&MX(i)-round(MR/4)>0&&TC(MY(i)+round(MR/6),MX(i)-round(MR/4))==1)
            t7=1;
        end
        if (MY(i)-round(MR/6)>0&&MX(i)+round(MR/4)<=lie&&TC(MY(i)-round(MR/6),MX(i)+round(MR/4))==1)
            t8=1;
        end
        
        if(S(Max(i)).Area/(hang*lie)>0.001) %���������������1%��ʱ��Ĭ��������·��
            tz(i)=1;
            t2=0;t4=0;t7=0;t8=0;
        end
    end
end
if(tz==zeros(1,imnum))
    imshowage=0;errordlg(' û��·�꣡��','������Ϣ');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%�ҳ���Ѷ����λ��(�������)��(�������)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%��ʾ·��ͼ��
flag=zeros(1,imnum);
for i=1:imnum
    if(tz(i)==1)
        high=Mblen(i); %Mblen(i)�Ƕ�Ӧ���εĳ�
        liezb=round(MX(i)-Mbwid(i)/2); %MX(i)��Ӧ���ĵ�X����
        hangzb=round(MY(i)-Mblen(i)/2); %MY(i)��Ӧ���ĵ�Y����
        width=Mbwid(i); %Mbwid(i)�Ƕ�Ӧ���εĿ�
        flag(i)=1;
        Iresult=imcrop(decI,[liezb hangzb width high]);%�س���������
        imwrite(Iresult,'result_'+string(i)+'.bmp','bmp');
    end
end

%��ʾ��ȡ��ͼ��
if imshowage==1
    for i=1:imnum
        if(flag(i)==1&&Max(i)~=0)
            M=imread('result_'+string(i)+'.bmp');
            res(i,1)=findSingle(M);
            res(i,2)={string(classify(newnet,imresize(M,[227 227])))};
        end
    end
else
end
% �������*��,��*:.��(������)/$:*.���* ��
%
%                 __------__
%               /~          ~\
%              |    //^\\//^\|
%            /~~\  ||  o| |o|:~\
%           | |6   ||___|_|_||:|
%            \__.  /      o  \/'
%             |   (       O   )
%    /~~~~\    `\  \         /
%   | |~~\ |     )  ~------~`\
%  /' |  | |   /     ____ /~~~)\
% (_/'   | | |     /'    |    ( |
%        | | |     \    /   __)/ \
%        \  \ \      \/    /' \   `\
%          \  \|\        /   | |\___|
%            \ |  \____/     | |
%            /^~>  \        _/ <
%           |  |         \       \
%           |  | \        \        \
%           -^-\  \       |        )
%                `\_______/^\______/
end