% ����ROS�źŻ��Ƶ��²���ͬһ̨����ʱ��Ҫ�ȿ���matlab��Ϊrosmaster�ڵ�
% ��ϸ�������£�
% ���ߵķ���ǽһ��Ҫ��
% ��������matlab ����matlab�汾����2016a����û��ros������
%   setenv('ROS_MASTER_URI','�˴�Ϊ��');
%   setenv('ROS_IP','����');
%   matlabִ��rosinit����
% ���ߵķ���ǽһ��Ҫ��
% ����������ROS���ڻ�������terminal ��ݼ�Ctrl+Alt+T
%   sudo vim ~/.bashrc ���ļ������ ��������ip���ӵ�����
%   export ROS_IP=����ͷ����ip
%   export ROS_MASTER_URI=http://matlab����ip:11311
% Ȼ��ر�terminal���� �ؿ�һ��terminal��ros����roscore���ܻᱨ������Ҫ�����ˣ�����
% ���ߵķ���ǽһ��Ҫ��
% ��������ͷ
% ��matlabִ��rosnode list,rosnode info node��,rostopic list,rostopic info
% topic����rostopic echo topic�� �����Щ���û����ͺ���
% Ȼ��Ϳ��Կ��ĵ�ʹ��matlab������[]~(������)~*
% ����*��,��*:.��(������)/$:*.���* ������

% �˳�������������ros����ͷ����ת��Ϊͼ����󲢵��ô�����򽫽��������ȥ

sub = rossubscriber('/usb_cam/image_raw');% ���Ļ���
[pub,pub_msg] = rospublisher('/dowhat','std_msgs/String');% ����
pub_msg.Data = '';
% while 1
    close all;
    rev=receive(sub,1);% ���һ��ȴ����ܻ������ݣ��л���ֻҪ��ͨ����������ͷ����ͼ��
    % ����ͼ���Ǿ�����Ҫ��ȡ����ͨ����ֵ����ros�����ȡ��ģʽ
    r=zeros(rev.Width,rev.Height);
    g=zeros(rev.Width,rev.Height);
    b=zeros(rev.Width,rev.Height);
    
    img=reshape(rev.Data,rev.Width*3,rev.Height);% rgb����ͨ�����Կ�*3
    for i = 1:rev.Width
        r(i,:)=img(i*3-2,:);% ��
        g(i,:)=img(i*3-1,:);% ��
        b(i,:)=img(i*3,:);% ��
    end
    
    I=zeros(rev.Width,rev.Height,3);% �ϳɲ�ɫͼ��
    % uint8һ��Ҫ���ϣ���Ȼ������I���ԣ�matlab����ȡ֮��rgb������double(�Τأ���)
    I(:,:,1)=uint8(r);
    I(:,:,2)=uint8(g);
    I(:,:,3)=uint8(b);
    
    I=uint8(imrotate(flipud(I),-90));% ��������ʽ��������ݵ��·���Ӻ�����������
    % ͬʱ����rgb����ͨ����ȡ����ʱ�Ǵ����Һ���Ҳ����˵ͼ�����˾���(lll�V�ةV)
    % �˴�uint8һ��Ҫ��
    imshow(I);
    % ����ʶ�����
    res = imgpro(I,newnet)
    % ��ͣ50s���������ʱ��
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
