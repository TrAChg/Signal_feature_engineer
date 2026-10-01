function fig_handles = plot_feature_boxplots(features_matrix, labels)

    c1_idx = (labels == 0);
    c2_idx = (labels == 1);
    
    fig_handles = [];
    
    % Temporal & Energy (Energy, RMS, Power_M0)
    h1 = figure('Name', 'Boxplots - Descripteurs Temporels & Energetiques', 'Color', 'w', 'Position', [100, 100, 1000, 320]);
    temp_indices = [1, 2, 7];
    temp_titles = {'Energie Totale', 'RMS', 'M0'};
    for p = 1:3
        subplot(1, 3, p);
        idx = temp_indices(p);
        c1 = features_matrix(c1_idx, idx);
        c2 = features_matrix(c2_idx, idx);
        boxplot([c1, c2], {'Classe 1', 'Classe 2'});
        title(temp_titles{p}, 'FontWeight', 'bold');
        grid on;
    end
    fig_handles = [fig_handles, h1];
    
    % Spectral Features (MPF, Fmed, Spec_Skewness, Spec_Kurtosis, HL_Ratio)
    h2 = figure('Name', 'Boxplots - Descripteurs Frequentiels', 'Color', 'w', 'Position', [100, 200, 1200, 320]);
    spec_indices = [8, 9, 10, 11, 12];
    spec_titles = {'MPF (Hz)', 'Fmed (Hz)', 'Skewness Spectrale', 'Kurtosis Spectrale', 'Ratio H/L'};
    for p = 1:5
        subplot(1, 5, p);
        idx = spec_indices(p);
        c1 = features_matrix(c1_idx, idx);
        c2 = features_matrix(c2_idx, idx);
        boxplot([c1, c2], {'Classe 1', 'Classe 2'});
        title(spec_titles{p}, 'FontWeight', 'bold');
        grid on;
    end
    fig_handles = [fig_handles, h2];
    
    % Statistical Features (Mean, Variance, Skewness, Kurtosis)
    h3 = figure('Name', 'Boxplots - Descripteurs Statistiques', 'Color', 'w', 'Position', [100, 300, 900, 320]);
    stat_indices = [3, 4, 5, 6];
    stat_titles = {'Moyenne', 'Var', 'Skewness', 'Kurtosis'};
    for p = 1:4
        subplot(1, 4, p);
        idx = stat_indices(p);
        c1 = features_matrix(c1_idx, idx);
        c2 = features_matrix(c2_idx, idx);
        boxplot([c1, c2], {'Classe 1', 'Classe 2'});
        title(stat_titles{p}, 'FontWeight', 'bold');
        grid on;
    end
    fig_handles = [fig_handles, h3];
end
