close all
imgs=imageDatastore('sample','LabelSource','foldernames','IncludeSubfolders',true);
[imgs1,imgs2]=splitEachLabel(imgs,60);

options = trainingOptions('adam',...
        'MaxEpochs',15,'MiniBatchSize',8,...
        'Shuffle','every-epoch',...
        'InitialLearnRate',1e-4,...
        'Verbose',false,...
        'Plots','training-progress');

%ResNetArchitecture
net=resnet50;
lgraph = layerGraph(net);
clear net;

%Number of categories
numClasses = numel(categories(imgs1.Labels));

%NewLearnableLayer
newLearnableLayer = fullyConnectedLayer(numClasses,...
    'Name','new_fc',...
    'WeightLearnRateFactor',10,...
    'BiasLearnRateFactor',10);

%Replacing the last layers withnew layers
lgraph = replaceLayer(lgraph,'fc1000',newLearnableLayer);
newsoftmaxLayer = softmaxLayer('Name','new_softmax');
lgraph = replaceLayer(lgraph,'fc1000_softmax',newsoftmaxLayer);
newClassLayer = classificationLayer('Name','new_classoutput');
lgraph = replaceLayer(lgraph,'ClassificationLayer_fc1000',newClassLayer);

imageAugmenter = imageDataAugmenter('RandXReflection',true,'RandXTranslation',[-10,10],'RandYTranslation',[10,10]);
augimds=augmentedImageDatastore([lgraph.Layers(1).InputSize(1) lgraph.Layers(1).InputSize(1)],imgs1,'ColorPreprocessing','gray2rgb','DataAugmentation',imageAugmenter);

newnet=trainNetwork(augimds,lgraph,options);