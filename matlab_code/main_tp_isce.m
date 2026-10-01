% Ensure all function files in matlab_code are accessible
current_dir = fileparts(mfilename('fullpath'));
if ~isempty(current_dir)
    addpath(current_dir);
end

%% Data Loading
[signals, labels, Fe, filenames] = load_emg_dataset();
N_signals = length(signals);
fprintf('      -> %d signaux charges (Fe = %d Hz, 5 sec par signal).\n\n', N_signals, Fe);

%% Feature Extraction
feature_names = { ...
    'Energy', 'RMS', 'Variance', 'Mean', 'Skewness', 'Kurtosis', ...
    'Power_M0', 'MPF', 'Fmed', 'Spec_Skewness', 'Spec_Kurtosis', ...
    'HL_Ratio', 'Rel_Energy_Low', 'Rel_Energy_High'};

N_features = length(feature_names);
features_matrix = zeros(N_signals, N_features);

for i = 1:N_signals
    x = signals{i};
    val_energy = feat_energy(x);
    val_rms    = feat_rms(x);

    val_mean = feat_mean(x);
    val_var  = feat_var(x);
    val_skew = feat_skewness(x);
    val_kurt = feat_kurtosis(x);
    
    [Pxx, f] = compute_psd_welch(x, Fe);
    
    val_m0            = feat_spectral_power(Pxx, f);
    val_mpf           = feat_mpf(Pxx, f);
    val_fmed          = feat_fmed(Pxx, f);
    val_spec_skewness = feat_spec_skewness(Pxx, f);
    val_spec_kurtosis = feat_spec_kurtosis(Pxx, f);
    val_hl_ratio      = feat_hl_ratio(Pxx, f, [20, 150], [150, 450]);
    [~, ~, rel_low, rel_high] = feat_band_energy(Pxx, f, [20, 150], [150, 450]);
    
    features_matrix(i, :) = [ ...
        val_energy, val_rms, val_var, val_mean, val_skew, val_kurt, ...
        val_m0, val_mpf, val_fmed, val_spec_skewness, val_spec_kurtosis, ...
        val_hl_ratio, rel_low, rel_high];
end

%% Boxplots 
plot_feature_boxplots(features_matrix, labels);

%% ROC & AUC
results = struct();

for f_idx = 1:N_features
    fname = feature_names{f_idx};
    fvals = features_matrix(:, f_idx);
    
    [auc_val, max_acc, opt_th, opt_sens, opt_spec, fpr, tpr] = compute_roc_auc(fvals, labels);
    
    results(f_idx).name     = fname;
    results(f_idx).c1_mean  = mean(fvals(labels == 0));
    results(f_idx).c1_std   = std(fvals(labels == 0));
    results(f_idx).c2_mean  = mean(fvals(labels == 1));
    results(f_idx).c2_std   = std(fvals(labels == 1));
    results(f_idx).auc      = auc_val;
    results(f_idx).max_acc  = max_acc;
    results(f_idx).opt_th   = opt_th;
    results(f_idx).opt_sens = opt_sens;
    results(f_idx).opt_spec = opt_spec;
    results(f_idx).fpr      = fpr;
    results(f_idx).tpr      = tpr;
end

% Sort results descending by AUC
[~, sort_order] = sort([results.auc], 'descend');
sorted_results = results(sort_order);

%% Ranking 
fprintf('%-16s | %-22s | %-22s | %-6s | %-8s | %-10s | %-6s | %-6s\n', ...
    'Descripteur', 'Classe 1 (M±S)', 'Classe 2 (M±S)', 'AUC', 'Acc Max', 'Seuil Opt', 'Sens', 'Spec');

for k = 1:N_features
    r = sorted_results(k);
    c1_str = sprintf('%.2e ± %.1e', r.c1_mean, r.c1_std);
    c2_str = sprintf('%.2e ± %.1e', r.c2_mean, r.c2_std);
    fprintf('%-16s | %-22s | %-22s | %-6.3f | %6.1f%% | %10.3e | %5.1f%% | %5.1f%%\n', ...
        r.name, c1_str, c2_str, r.auc, r.max_acc*100, r.opt_th, r.opt_sens*100, r.opt_spec*100);
end

%% ROC Comparison & Ranking Plots 
plot_roc_comparison(sorted_results, 7);
plot_feature_ranking(sorted_results);
