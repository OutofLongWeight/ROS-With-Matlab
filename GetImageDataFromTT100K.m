json=jsondecode(fileread('E:\Download\data\annotations.json'));
% 生成图像文件夹
floders=json.types;
for i=1:numel(floders)
    dirname='data\'+string(floders{i});
    if exist(dirname,'dir')==0
        mkdir(dirname);
    end
end
% 图像结构体
imgs=fieldnames(json.imgs);

for i=1:numel(imgs)
    objs=json.imgs.(imgs{i}).objects;
    if size(objs)~=0
        img=imread('E:\Download\data\'+string(json.imgs.(imgs{i}).path));
        for j=1:numel(objs)
            % jsondecode结果存入数据格式不同所以两种可能都写(╯‵□′)╯︵┻━┻
            try
                obj=objs{j,1};
            catch
                obj=objs(j);
            end
            % 图像中路标位置，多个就是数组
            xmin=obj.bbox.xmin;
            ymin=obj.bbox.ymin;
            xl=obj.bbox.xmax-xmin;
            yl=obj.bbox.ymax-ymin;
            
            % 路标图像保存
            single=imcrop(img,round([xmin ymin xl yl]));
            imwrite(single,strcat('data\',obj.category,'\',datestr(now,'mmmmddyyyyHHMMSSFFF'),'.jpg'),'jpg')
        end
    end
end