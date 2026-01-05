% Assumes varables:
% train_data: size [900 x 28 x 28] 
% validation_data: size [300 x 28 x 28] 

clc;clear;close all;

data = importdata('Train/labels.txt');
data= data(1:900,:); % train with first 900 images
img_nrs_original = data(:,1); 
true_labels_original = data(:,(2:5)); 
N_total = size(img_nrs_original, 1); 

% Shuffling
rng('default'); 
shuffled_indices = randperm(N_total);

img_nrs = img_nrs_original(shuffled_indices);
true_labels = true_labels_original(shuffled_indices,:);

all_patterns = [];
all_labels = {};
t_extract = tic;
fprintf('Extracting Training Features...\n');

% TRAINING
for i = 1:N_total
    sprintf('idx %d', i);
    k = img_nrs(i); 
    im = imread(sprintf('Train/captcha_%04d.png', k));
    img_rgb =im2double(im); 
    img_gray = rgb2gray(img_rgb);
    img_gray = fft_denoise(img_gray);
    img_bw = im2double(Preprocessing(img_gray));


    totDigitCnt = get_digit_total_num(img_bw);
    
    
    [bboxs, rotate_angle, img_gray_out] = digit_detection(img_bw, totDigitCnt);
    a = FeatureExtraction(img_gray_out, bboxs, totDigitCnt);
    
    if size(a) == 0
        i 
    else
        if totDigitCnt == 4
            for j=1:totDigitCnt
                all_patterns(end+1,:) = a(j,:); 
                all_labels{end+1} = num2str(true_labels(i,j));
            end
        else 
            for j=1:totDigitCnt
                all_patterns(end+1,:) = a(j,:);
                all_labels{end+1} = num2str(true_labels(i,j+1));
            end
        end
    end
end
toc(t_extract)

all_labels = transpose(all_labels);
N_digits = size(all_patterns, 1); 

%% K Fold cross validation
K_folds = 5; 
fprintf('\n=======================================================\n');
fprintf('Building model and running %d-Fold Cross-Validation (%d total digits)...\n', K_folds, N_digits);
fprintf('=======================================================\n');

t_cv_manual = tic;
cvp = cvpartition(all_labels, 'KFold', K_folds);
cv_accuracies = zeros(K_folds, 1); % Store accuracy for each fold
all_cv_pred = cell(N_digits, 1);  
%%
% K-Fold Iteration Loop
for k = 1:K_folds
    
    fprintf('\n>>> Running Fold %d of %d...\n', k, K_folds);
    train_idx = cvp.training(k); 
    test_idx = cvp.test(k);
    
    train_patterns_fold = all_patterns(train_idx,:);
    train_labels_fold = all_labels(train_idx);
    test_patterns_fold = all_patterns(test_idx,:);
    test_labels_fold = all_labels(test_idx);
    
    % SVM %
    %     tr_fold = templateSVM('KernelFunction','linear');
    %     Mdl_fold = fitcecoc(double(train_patterns_fold), train_labels_fold, 'Learners', tr_fold);
    % ADA BOOST %
    % tr = templateTree('MaxNumSplits',100);
    % Mdl = fitcensemble(double(train_patterns),train_labels, 'Learners',tr); 
    % KNN (final model) %
    K=3;
    Mdl_fold = fitcknn(double(all_patterns),all_labels, 'NumNeighbors',K, 'BreakTies','nearest');

    % Prediction
    pred_labels_fold = predict(Mdl_fold, test_patterns_fold);    
    accuracy_fold = mean(strcmp(pred_labels_fold, test_labels_fold));
    cv_accuracies(k) = accuracy_fold;
    
    fprintf('  - Fold %d Traning Samples: %d\n', k, size(train_patterns_fold, 1));
    fprintf('  - Fold %d Validation Samples: %d\n', k, size(test_patterns_fold, 1));
    fprintf('  - Fold %d Accuracy: %5.2f%%\n', k, accuracy_fold * 100);
    
    all_cv_pred(test_idx) = pred_labels_fold;
end

mean_cv_accuracy = mean(cv_accuracies);
std_cv_accuracy = std(cv_accuracies); 
t_cv_end = toc(t_cv_manual);

fprintf('\nBuilding FINAL model using all digit features (for later system evaluation)...\n');
t_final_train = tic;

% SVM %
% tr_final = templateSVM('KernelFunction','linear');
% Mdl_final = fitcecoc(double(all_patterns), all_labels, 'Learners', tr_final); 
KNN %
k=3;
Mdl_final = fitcknn(double(all_patterns),all_labels, 'NumNeighbors',k, 'BreakTies','nearest');

toc(t_final_train)
save Mdl.mat Mdl_final

fprintf('\nResubstitution error (on all data): %5.2f%%\n\n',100*resubLoss(Mdl_fold));
fprintf('\n\n--- K-Fold Cross-Validation Summary Report ---\n');
fprintf('CV Training/Evaluation Time: %.2f seconds\n', t_cv_end); 
fprintf('==================================================\n');
fprintf('Accuracy List for Each Fold:\n');
for k = 1:K_folds
    fprintf('   Fold %d accuracy: %5.2f%%\n', k, cv_accuracies(k) * 100);
end
fprintf('--------------------------------------------------\n');
fprintf('Mean Cross-Validation Accuracy: %5.2f%%\n', mean_cv_accuracy * 100);
fprintf('Accuracy Standard Deviation: \xb1%5.2f%%\n', std_cv_accuracy * 100); 
fprintf('==================================================\n');

f=figure(2);
if (f.Position(3)<800)
	set(f,'Position',get(f,'Position').*[1,1,1.5,1.5]); 
end

%% Confusion matrix
confusionchart(all_labels, all_cv_pred, 'ColumnSummary','column-normalized', 'RowSummary','row-normalized');
title(sprintf('Mean Cross-Validation Accuracy: %5.2f%% \\pm%5.2f%%', ...
              mean_cv_accuracy * 100, std_cv_accuracy * 100));
fprintf('\nResubstitution error: %5.2f%%\n\n',100*resubLoss(Mdl_fold));
%%
zeor_idx1 = find(str2num(cell2mat(all_cv_pred)) ~= 0);
zeor_idx2 = find(str2num(cell2mat(all_labels)) ~= 0);
zero_idx = intersect(zeor_idx1, zeor_idx2); 
all_labels_temp = all_labels(zero_idx);
all_cv_pred_temp = all_cv_pred(zero_idx);
confusionchart(all_labels_temp, all_cv_pred_temp, 'ColumnSummary','column-normalized', 'RowSummary','row-normalized');
title(sprintf('Mean Cross-Validation Accuracy: %5.2f%% \\pm%5.2f%%', ...
              mean_cv_accuracy * 100, std_cv_accuracy * 100));
          
%% Validation
fprintf('==================================================\n');
fprintf('===========validation of rest 300 data=======\n');
data = importdata('Train/labels.txt');
data= data(901:1200,:);
img_nrs_original = data(:,1); 
true_labels_original = data(:,(2:5)); 
N_total = size(img_nrs_original, 1); 

% Shuffling
rng('default'); 
shuffled_indices = randperm(N_total);

img_nrs = img_nrs_original(shuffled_indices);
true_labels = true_labels_original(shuffled_indices,:);

val_patterns = [];
val_labels = {};
totDigitCnt_List = [];
t_extract = tic;
fprintf('Extracting Training Features...\n');

% TRAINING
for i = 1:N_total
    sprintf('idx %d', i);
    k = img_nrs(i); 
    im = imread(sprintf('Train/captcha_%04d.png', k));
    img_rgb =im2double(im); 
    img_gray = rgb2gray(img_rgb);
    img_gray = fft_denoise(img_gray);
    img_bw = im2double(Preprocessing(img_gray));

    totDigitCnt = get_digit_total_num(img_bw);
    
    [bboxs, rotate_angle, img_gray_out] = digit_detection(img_bw, totDigitCnt);
    a = FeatureExtraction(img_gray_out, bboxs, totDigitCnt);
    totDigitCnt_List(end+1,:) = totDigitCnt; 
    if size(a) == 0
        i 
    else
        if totDigitCnt == 4
            for j=1:totDigitCnt
                val_patterns(end+1,:) = a(j,:); 
                val_labels{end+1} = num2str(true_labels(i,j));
            end
        else 
            for j=1:totDigitCnt
                val_patterns(end+1,:) = a(j,:);
                val_labels{end+1} = num2str(true_labels(i,j+1));
            end
        end
    end
end
toc(t_extract)
%%
val_all_labels = transpose(val_labels);
fprintf('Predicting validation set...\n');
t=tic;

validation_pred = predict(Mdl_fold, val_patterns);
pred = str2double(predict(Mdl_fold,val_patterns)');
val_all_digit = zeros(N_total, 4);
for i = 1:N_total
    n = totDigitCnt_List(i);
    if n == 3
        S = [0, pred(1:n)];
    else
        S = pred(1:n);
    end
    pred = pred(n+1:end);
    val_all_digit(i,:) = S;
end

accuracy = mean(strcmp(validation_pred, val_all_labels));
correct = sum(abs(true_labels - val_all_digit),2)==0;
toc(t);

fprintf('Validation accuracy(digit_level): %5.2f%%\n',accuracy*100);
fprintf('Validation accuracy(img_level): %5.2f%%\n',mean(correct)*100);