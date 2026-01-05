clc;clear;close all
data = importdata('Train/labels.txt');
img_nrs = data(:,1);
true_labels = data(:,2);
%%
true_labels(true_labels ~=0) = 4;
true_labels(true_labels ==0) = 3;
%%
my_labels = zeros(size(true_labels));
N = size(img_nrs);  


Fs = [];
for n =1:N
    fprintf('idx %d\n ', n);
    k = img_nrs(n);
    im = imread(sprintf('Train/captcha_%04d.png', k));
    
    % preprocessing
    img_rgb =im2double(im); 
    img_gray = rgb2gray(img_rgb);
    img_gray = fft_denoise(img_gray);
    img_bw = im2double(Preprocessing(img_gray));
    skel= bwskel(img_bw>0,'MinBranchLength',10);
    branchPoint = bwmorph(skel,'branchpoints');
    
    stats = regionprops(img_bw, 'BoundingBox', 'ConvexArea','Circularity','Area','Centroid','Solidity');
%     Fs = [Fs;  sum(skel(:)), stats.BoundingBox(3), stats.BoundingBox(4), stats.ConvexArea, stats.Circularity, stats.Area, stats.Centroid, stats.Solidity]; % before feature selection
    Fs = [Fs;  stats.BoundingBox(3), sum(skel(:))];
end

%% Training
num_train = 900;
num_valid = 300;
train_patterns = Fs(1:num_train, :);
validation_patterns = Fs(num_train + 1:end, :);
train_labels = true_labels(1:num_train, :);
validation_labels = true_labels(num_train + 1:end, :);


k = 4;
cv = cvpartition(train_labels, 'KFold', k);
accuracies = zeros(k,1);
for i = 1:k
    % Training and test indices
    trainIdx = training(cv, i);
    testIdx = test(cv, i);
    
    X_train = train_patterns(trainIdx, :);
    y_train = train_labels(trainIdx);
    X_test = train_patterns(testIdx, :);
    y_test = train_labels(testIdx);
 
    Mdl  = fitctree(double(train_patterns),train_labels);

    % Predict on test fold
    y_pred = predict(Mdl, X_test);
    
    % Compute accuracy for this fold
    fold_acc = mean(y_pred == y_test);
    accuracies(i) = fold_acc;
end

% Average k-Fold accuracy
mean_accuracy = mean(accuracies);
disp(['k-Fold CV Accuracy: ', num2str(mean_accuracy)]);

y_test_pred = predict(Mdl, validation_patterns);
fprintf('test: %.2f', mean(y_test_pred == validation_labels))
% save digit_detect_tree.mat Mdl
%% show feature importance
% figure;
% imp = predictorImportance(Mdl);
% bar(imp);
% title('Predictor Importance Estimates');
% ylabel('Estimates');
% xlabel('Predictors');
% h = gca;
% h.XTickLabel = [{'skeleton length'}, {'Bounding Box width'}, {'Bounding Box height'}, {'ConvexArea'}, {'Circularity'}, {'Area'}, {'Centroid x'}, {'Centroid y'}, {'Solidity'}];
% h.XTickLabelRotation = 45;
% h.TickLabelInterpreter = 'none';
