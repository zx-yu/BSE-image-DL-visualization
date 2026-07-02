clc
clear 
close all
size = 220;
baseFolder=[];
digitDatasetPath = fullfile(baseFolder, ['TrainingImage_' num2str(size)]);
imds = imageDatastore(digitDatasetPath, ...
    'IncludeSubfolders',true,'LabelSource','foldernames');
labelCount = countEachLabel(imds);
[imdsNew,~] = splitEachLabel(imds,1000,'randomize');
[imdsTrain,imdsValidation, imdsTest] = splitEachLabel(imdsNew,0.8,0.1,'randomize');
numClasses = numel(categories(imdsTrain.Labels));

layers = [
    imageInputLayer([220 220 1],'Name','input')
    
    convolution2dLayer(3,8,'Name','conv_1','BiasLearnRateFactor',0)%98
    batchNormalizationLayer('Name','BN_1')
    reluLayer('Name','relu_1')
        
    averagePooling2dLayer(2,'Stride',2,'Name','mpool_1')%49
    
    convolution2dLayer(3,16,'Name','conv_2','BiasLearnRateFactor',0)%47
    batchNormalizationLayer('Name','BN_2')
    reluLayer('Name','relu_2')
    
    averagePooling2dLayer(2,'Stride',2,'Name','mpool_2')%23
    
    convolution2dLayer(3,32,'Name','conv_3','BiasLearnRateFactor',0)%21
    batchNormalizationLayer('Name','BN_3')
    reluLayer('Name','relu_3')
    
    averagePooling2dLayer(2,'Stride',2,'Name','mpool_3')%10
    
    convolution2dLayer(3,32,'Name','conv_4','BiasLearnRateFactor',0)%8
    batchNormalizationLayer('Name','BN_4')
    reluLayer('Name','relu_4')
    
    averagePooling2dLayer(2,'Stride',2,'Name','mpool_4')%4
    convolution2dLayer(3,64,'Name','conv_5','BiasLearnRateFactor',0)%2
    batchNormalizationLayer('Name','BN_5')
    reluLayer('Name','relu_5')
    
    averagePooling2dLayer(2,'Stride',2,'Name','mpool_5')%1
    
    dropoutLayer(0.7,'Name','drop1')
    fullyConnectedLayer(numClasses,'Name','fc','BiasLearnRateFactor',0)%

    softmaxLayer('Name','softmax')
    classificationLayer('Name','classOutput')];

lgraph =layerGraph(layers);
maxEpochs=500;
options = trainingOptions('adam', ...
    'MiniBatchSize',512, ...
    'InitialLearnRate',0.001, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.8, ...
    'LearnRateDropPeriod',10, ...
    'MaxEpochs',maxEpochs, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',20, ...
    'Verbose',false, ...
    'Plots','training-progress', ...
    'ExecutionEnvironment','multi-gpu', ...
    'OutputFcn',@(info)stopIfAccuracyNotImproving(info,0.00001));

[net,info] = trainNetwork(imdsTrain,lgraph,options);
YPred = classify(net,imdsTest);
YTest = imdsTest.Labels;
accuracy = sum(YPred == YTest)/numel(YTest);
timestamp = datestr(now, 'yyyymmddHHMMSS');
filename = ['v0TrainingResults_', num2str(size), '_', timestamp,'.mat'];
save(filename);
