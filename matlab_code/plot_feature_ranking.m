function h_fig = plot_feature_ranking(sorted_results)

    N_feats = length(sorted_results);
    names = {sorted_results.name};
    clean_names = strrep(names, '_', ' ');
    auc_vals = [sorted_results.auc];
    acc_vals = [sorted_results.max_acc] * 100;
    
    h_fig = figure('Name', 'Classement des Descripteurs', 'Color', 'w', 'Position', [200, 200, 1050, 520]);
    
    % Subplot 1: AUC
    subplot(1, 2, 1);
    barh(auc_vals, 'FaceColor', [0.18, 0.45, 0.71], 'EdgeColor', 'k');
    set(gca, 'YTick', 1:N_feats, 'YTickLabel', clean_names, 'YDir', 'reverse', 'FontWeight', 'bold');
    xlabel('Aire sous la Courbe (AUC)', 'FontWeight', 'bold');
    title('Classement par AUC', 'FontWeight', 'bold');
    xlim([0.4, 1.0]);
    xline(0.5, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Seuil Aleatoire (0.5)');
    grid on;
    
    % Subplot 2: Max Accuracy
    subplot(1, 2, 2);
    barh(acc_vals, 'FaceColor', [0.27, 0.63, 0.29], 'EdgeColor', 'k');
    set(gca, 'YTick', 1:N_feats, 'YTickLabel', clean_names, 'YDir', 'reverse', 'FontWeight', 'bold');
    xlabel('Precision Maximale (%)', 'FontWeight', 'bold');
    title('Precision Maximale (Accuracy)', 'FontWeight', 'bold');
    xlim([45, 105]);
    xline(50, 'r--', 'LineWidth', 1.5, 'DisplayName', 'Seuil Aleatoire (50%)');
    grid on;
end
