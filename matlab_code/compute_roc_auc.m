function [auc, max_acc, opt_th, opt_sens, opt_spec, fpr_out, tpr_out] = compute_roc_auc(feature_vals, labels)

    feature_vals = feature_vals(:);
    labels = labels(:);
    
    c1_vals = feature_vals(labels == 0);
    c2_vals = feature_vals(labels == 1);
    
    n_pos = sum(labels == 1); % Positive class: Class 2
    n_neg = sum(labels == 0); % Negative class: Class 1
    total_samples = length(labels);
    
    % If Class 2 has higher mean than Class 1, predict 1 if val >= threshold
    % Else predict 1 if val <= threshold
    dir_pos = mean(c2_vals) >= mean(c1_vals);
    
    val_min = min(feature_vals);
    val_max = max(feature_vals);
    margin = 0.05 * (val_max - val_min + eps);
    thresholds = linspace(val_min - margin, val_max + margin, 500);
    
    tpr_list = zeros(length(thresholds), 1);
    fpr_list = zeros(length(thresholds), 1);
    acc_list = zeros(length(thresholds), 1);
    sens_list = zeros(length(thresholds), 1);
    spec_list = zeros(length(thresholds), 1);
    
    for i = 1:length(thresholds)
        th = thresholds(i);
        if dir_pos
            predictions = (feature_vals >= th);
        else
            predictions = (feature_vals <= th);
        end
        
        tp = sum((predictions == 1) & (labels == 1));
        fp = sum((predictions == 1) & (labels == 0));
        tn = sum((predictions == 0) & (labels == 0));
        
        sens = tp / n_pos;
        spec = tn / n_neg;
        fpr = fp / n_neg;
        acc = (tp + tn) / total_samples;
        
        tpr_list(i) = sens;
        fpr_list(i) = fpr;
        acc_list(i) = acc;
        sens_list(i) = sens;
        spec_list(i) = spec;
    end
    
    % Sort by FPR for accurate trapezoidal integration
    [fpr_sorted, sort_order] = sort(fpr_list);
    tpr_sorted = tpr_list(sort_order);
    
    % Group unique FPR values taking max TPR to guarantee a proper monotonically non-decreasing curve
    [unique_fpr, ~, ic] = unique(fpr_sorted);
    unique_tpr = zeros(size(unique_fpr));
    for j = 1:length(unique_fpr)
        unique_tpr(j) = max(tpr_sorted(ic == j));
    end
    
    % Ensure endpoints (0,0) and (1,1) are present
    if unique_fpr(1) > 0
        unique_fpr = [0; unique_fpr];
        unique_tpr = [0; unique_tpr];
    end
    if unique_fpr(end) < 1.0
        unique_fpr = [unique_fpr; 1.0];
        unique_tpr = [unique_tpr; 1.0];
    end
    
    auc = sum(diff(unique_fpr) .* (unique_tpr(1:end-1) + unique_tpr(2:end)) / 2);
    if auc < 0.5
        auc = 1.0 - auc;
    end
    
    [max_acc, best_idx] = max(acc_list);
    opt_th = thresholds(best_idx);
    opt_sens = sens_list(best_idx);
    opt_spec = spec_list(best_idx);
    
    fpr_out = unique_fpr;
    tpr_out = unique_tpr;
end
