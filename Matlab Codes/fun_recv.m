% 由于ROS信号机制导致不是同一台机器时需要先开启matlab作为rosmaster节点
% 详细步骤如下：
% 两边的防火墙一定要关
% 首先启动matlab 设置matlab版本大于2016a否则没有ros工具箱
%   setenv('ROS_MASTER_URI','此处为空');
%   setenv('ROS_IP','本机');
%   matlab执行rosinit命令
% 两边的防火墙一定要关
% 接下来启动ROS所在机器启动terminal 快捷键Ctrl+Alt+T
%   sudo vim ~/.bashrc 在文件中添加 以下两句ip不加单引号
%   export ROS_IP=摄像头所在ip
%   export ROS_MASTER_URI=http://matlab所在ip:11311
% 然后关闭terminal窗口 重开一个terminal在ros启动roscore可能会报错，不重要（＞人＜；）
% 两边的防火墙一定要关
% 启动摄像头
% 在matlab执行rosnode list,rosnode info node名,rostopic list,rostopic info
% topic名，rostopic echo topic名 如果这些命令都没问题就好了
% 然后就可以开心的使用matlab程序了[]~(￣▽￣)~*
% 撒花*★,°*:.☆(￣▽￣)/$:*.°★* 。撒花

% 此程序是用来接受ros摄像头数据转化为图像矩阵并调用处理程序将结果发布出去

sub = rossubscriber('/usb_cam/image_raw');% 订阅话题
[pub,pub_msg] = rospublisher('/dowhat','std_msgs/String');% 发布
pub_msg.Data = '';
% while 1
    close all;
    rev=receive(sub,1);% 最多一秒等待接受话题内容，有缓存只要互通启动了摄像头就有图像
    % 传入图像是矩阵需要获取三个通道的值根据ros程序读取的模式
    r=zeros(rev.Width,rev.Height);
    g=zeros(rev.Width,rev.Height);
    b=zeros(rev.Width,rev.Height);
    
    img=reshape(rev.Data,rev.Width*3,rev.Height);% rgb三个通道所以宽*3
    for i = 1:rev.Width
        r(i,:)=img(i*3-2,:);% 红
        g(i,:)=img(i*3-1,:);% 绿
        b(i,:)=img(i*3,:);% 蓝
    end
    
    I=zeros(rev.Width,rev.Height,3);% 合成彩色图像
    % uint8一定要加上，不然最后输出I不对，matlab这样取之后rgb矩阵是double(ノへ￣、)
    I(:,:,1)=uint8(r);
    I(:,:,2)=uint8(g);
    I(:,:,3)=uint8(b);
    
    I=uint8(imrotate(flipud(I),-90));% 由于是流式输出的数据导致方向从横向变成了纵向，
    % 同时由于rgb三个通道获取数据时是从左到右横向也就是说图像变成了镜像(lll￢ω￢)
    % 此处uint8一定要加
    imshow(I);
    % 调用识别程序
    res = imgpro(I,newnet)
    % 暂停50s给程序处理的时间
%     [l,n]=size(res);
%     for j=1:n
%         pub_msg.Data=char(strcat(pub_msg.Data,string(res(j))));
%     end
try
    pub_msg.Data=char(res(1));
catch
    try
        pub_msg.Data=char(res(2));
    catch
        pub_msg.Data=char(res(3));
    end
end
    send(pub,pub_msg);
%     pause(30)
% end
