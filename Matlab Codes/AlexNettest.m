close all
net=alexnet;
layers=net.Layers;
% 训练数据集
imgs=imageDatastore('sample','LabelSource','foldernames','IncludeSubfolders',true);
[imgs1,imgs2]=splitEachLabel(imgs,3);
% imgs.Labels=unique(imgs.Labels);
% 配置增强参数，将图像随机旋转
imageAugmenter = imageDataAugmenter('RandXReflection',true,'RandXTranslation',[-30,30],'RandYTranslation',[-30,30]);
% 修改图像属性
augimds=augmentedImageDatastore([227 227],imgs1,'ColorPreprocessing','gray2rgb');
% 数据集的标签属性改为图像名
% imgs.Labels=[imgs.Files];
% [ds1,ds2] = splitEachLabel(imgs,0.8);% 每个子文件夹下文件按比例分配
% 新全连接层输出结果分类数量等于图片数
fullyconlayer=fullyConnectedLayer(numel(unique(imgs.Labels)),'WeightLearnRateFactor',20,'BiasLearnRateFactor',20);
% 全连接层替换
layers(end-2)=fullyconlayer;
% 输出层也需要替换
layers(end)=classificationLayer;
% 迁移训练设置学习速度0.001(只允许小批量改动)，优化算法sgdm、adam
% opts=trainingOptions('sgdm','InitialLearnRate',0.001);
opts=trainingOptions('sgdm','MiniBatchSize',10,'MaxEpochs',30,'InitialLearnRate',1e-4,'ValidationFrequency',3,'ValidationPatience',Inf,'Verbose',false,'Plots','training-progress');
% 训练
[newnet,info] = trainNetwork(augimds, layers, opts);
% [newnet,info] = trainNetwork(augimds, layers, opts);