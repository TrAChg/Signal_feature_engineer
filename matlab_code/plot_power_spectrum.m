function h_fig = plot_roc_comparison(sorted_results, top_k)

    if nargin < 2 || isempty(top_k)
        top_k = min(7, length(sorted_results));
    end

    h_fig = figure('Name', 'Courbes ROC Comparatives', 'Color', 'w', 'Position', [150, 150, 750, 600]);
    hold on;
    
    colors = lines(top_k);
    for p = 1:top_k
        r = sorted_results(p);
        clean_name = strrep(r.name, '_', ' ');
        plot(r.fpr, r.tpr, 'LineWidth', 2, 'Color', colors(p, :), ...
            'DisplayName', sprintf('%s (AUC = %.3f)', clean_name, r.auc));
    end
    
    plot([0 1], [0 1], 'k--', 'LineWidth', 1.5, 'DisplayName', 'Aleatoire (AUC = 0.500)');
    
    xlabel('Taux de Faux Positifs : FPR = 1 - Specificite', 'FontWeight', 'bold');
    ylabel('Taux de Vrais Positifs : TPR = Sensibilite', 'FontWeight', 'bold');
    title('Courbes ROC - Pouvoir Separateur des Descripteurs', 'FontWeight', 'bold');
    legend('Location', 'southeast', 'Box', 'on');
    grid on;
    xlim([-0.02, 1.02]);
    ylim([-0.02, 1.05]);
end
