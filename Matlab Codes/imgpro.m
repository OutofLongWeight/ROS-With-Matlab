%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%图像处理找到可能的路标图像（红色边框）并将其分离ˋ( ° ▽、° )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [res] = imgpro(I,newnet)
% close all;
%I=imresize(I,[592 748]);%图片缩放，指定长宽

% figure,imshow(I);title('原图');
%分离红色
Hsv=rgb2hsv(I);   %将图像由RGB颜色空间转化为HSV颜色空间
%figure,imshow(Hsv);title('Hsv');
%hsv模型：h色调度数，s饱和度0~1，v亮度0纯黑到1纯白
I1=Hsv(:,:,1);%hsv矩阵第一维是角度->色调
I2=Hsv(:,:,2);%饱和度
I3=Hsv(:,:,3);%明度
%figure,imshow(I1);title('Hsv(:,:,1)');
%数值需要大量测试
I1=roicolor(I1,0,0.0556)+roicolor(I1,0.6667,1);
I2=roicolor(I2,0.523,1);
I3=roicolor(I3,0.4,1);
%figure;subplot(131);imshow(BW1);subplot(132);imshow(BW2);subplot(133);imshow(BW3);
BW=I1.*I2.*I3;
% BW=roicolor(I1,0.0277,0.032); %利用颜色阀值将红色对象都都显示为白色,其余都为黑色,至此完成图象的二值化
figure,imshow(BW);title('只显示红色');

% 获取联通区域->路标可能区域
se=strel('disk',20); %创建一个指定半径10的平面圆盘形的结构元素
BW=imclose(BW,se);%将图象置白色；闭运算，半径10，补全小空洞，避免采光影响导致红圈不连通
figure,imshow(BW);title('闭运算结果');
% se=strel('disk',2);
% BW=imopen(BW,se);
% figure,imshow(BW);title('开运算');
% SE=ones(10);%10*10矩阵膨胀
% PZ=imdilate(BW1,SE);%将二值图象膨胀；
% figure,imshow(PZ);title('膨胀后的图象');
TC=bwfill(BW,'holes');
figure,imshow(TC);title('填充后的图象');
% 整幅图像除了可能目标区域全部是白色
decI=uint8(I.*uint8(TC));
% 背景变白三个通道分别给与最大值
I1=decI(:,:,1);
I2=decI(:,:,2);
I3=decI(:,:,3);
I1(TC==0)=255;
I2(TC==0)=255;
I3(TC==0)=255;
decI(:,:,1)=I1;
decI(:,:,2)=I2;
decI(:,:,3)=I3;
figure,imshow(decI);title('去掉背景色');
L=bwlabeln(TC); %函数作用：分离连通区域，将连通区域标记1，2，3.。。
S=regionprops(L,'Area','Centroid','BoundingBox');  %获取标记图像L中所有区域的一系列特征付给S,提取区域像素个数，区域质心，每个区域的最小矩形
cent=cat(1,S.Centroid);%把S.Centroid沿第一维排列，质心
boud=cat(1,S.BoundingBox); %把S.BoundingBox沿第一维排列，区域，每个区域是个行向量代表左上角第一个点的x y坐标以及长高
Len=length(S);
area=cat(1,S.Area);
t2=0;t4=0;t7=0;t8=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 获取三个最大联通区域━━(￣ー￣*|||━━
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

%根据各填充块的面积，找出其中最大的三个填充块，分别存于Max1、Max2、Max3  Max1>Max2>Max3
%Max矩阵记录面积最大三个区域的标志-----来源于S                         Max(1)>Max(2)>Max(3)
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
% 剔除不合理区域━((*′д｀)爻(′д｀*))━!!!!
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if(Max==zeros(1,imnum))
    imshowage=0;errordlg(' 没有路标！！','基本信息');%当无连通区域时停止程序，一般不可能
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
        X=cent(Max(i),1);Y=cent(Max(i),2);%白色为1；取出重心矩阵中最大三块联通区域对应重心的坐标
        MX(i)=round(X);MY(i)=round(Y);%重心可能不是整数，坐标一定是整数，用round
        bx=boud(Max(i),1);by=boud(Max(i),2);blen=boud(Max(i),4);bwid=boud(Max(i),3);%左上角第一个点，以及长和宽
        bx1=round(bx);by1=round(by);Mblen(i)=round(blen);Mbwid(i)=round(bwid);
        if (blen>=bwid)
            MR=bwid;
        else
            MR=blen;
        end
        
        %Matlab中图像坐标纵向是y横向x  [y,x],以下判断边界，是否超出图形区域
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
        
        if(S(Max(i)).Area/(hang*lie)>0.001) %当对象的象素少于1%的时候默认他不是路标
            tz(i)=1;
            t2=0;t4=0;t7=0;t8=0;
        end
    end
end
if(tz==zeros(1,imnum))
    imshowage=0;errordlg(' 没有路标！！','基本信息');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%找出最佳对象的位置(〃￣︶￣)人(￣︶￣〃)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%显示路标图象
flag=zeros(1,imnum);
for i=1:imnum
    if(tz(i)==1)
        high=Mblen(i); %Mblen(i)是对应矩形的长
        liezb=round(MX(i)-Mbwid(i)/2); %MX(i)对应质心的X坐标
        hangzb=round(MY(i)-Mblen(i)/2); %MY(i)对应质心的Y坐标
        width=Mbwid(i); %Mbwid(i)是对应矩形的宽
        flag(i)=1;
        Iresult=imcrop(decI,[liezb hangzb width high]);%截出可能区域
        imwrite(Iresult,'result_'+string(i)+'.bmp','bmp');
    end
end

%显示截取的图像
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
% 完结撒花*★,°*:.☆(￣▽￣)/$:*.°★* 。
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