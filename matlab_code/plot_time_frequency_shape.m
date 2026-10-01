function h_fig = plot_time_frequency_shape(x1, x2, Fe, zoom_window)
% PLOT_TIME_FREQUENCY_SHAPE Plots raw sEMG signals, zoomed waveform shapes, and time-frequency spectrograms
    if nargin < 1 || isempty(x1)
        data_dir = 'EMG_database';
        if ~exist(data_dir, 'dir') && exist(fullfile('..', 'EMG_database'), 'dir')
            data_dir = fullfile('..', 'EMG_database');
        end
        
        file1 = fullfile(data_dir, 'EMG1.mat');
        file2 = fullfile(data_dir, 'EMG11.mat');
        
        if exist(file1, 'file') && exist(file2, 'file')
            d1 = load(file1);
            d2 = load(file2);
            x1 = d1.EMG(:);
            x2 = d2.EMG(:);
        else
            error('EMG1.mat and EMG11.mat not found. Please provide input signal x1.');
        end
    end

    if nargin < 2
        x2 = [];
    end
    if nargin < 3 || isempty(Fe)
        Fe = 10000;
    end
    if nargin < 4 || isempty(zoom_window)
        zoom_window = [0.5, 0.6]; % Default: 100 ms window from 500 ms to 600 ms
    end

    has_two_signals = ~isempty(x2);

    if has_two_signals
        h_fig = figure('Name', 'Morphologie sEMG et Représentation Temps-Fréquence (STFT)', ...
                       'Color', 'w', 'Position', [80, 60, 1300, 780]);
        
        % Left Column: Signal 1 (Class 1)
        render_column(x1, Fe, zoom_window, 'EMG 1 (Classe 1 : Contraction Modérée)', [0.12, 0.47, 0.71], 1, 2);
        
        % Right Column: Signal 2 (Class 2)
        render_column(x2, Fe, zoom_window, 'EMG 11 (Classe 2 : Contraction Élevée)', [0.84, 0.15, 0.16], 2, 2);
    else
        h_fig = figure('Name', 'Morphologie sEMG et Représentation Temps-Fréquence (STFT)', ...
                       'Color', 'w', 'Position', [150, 100, 750, 780]);
        render_column(x1, Fe, zoom_window, 'Signal sEMG', [0.12, 0.47, 0.71], 1, 1);
    end
end

% --- Internal Sub-function to render a 3-panel column ---
function render_column(x, Fe, zoom_window, title_str, col, col_idx, total_cols)
    x = x(:);
    N = length(x);
    time_vec = (0:N-1)' / Fe; % Time in seconds
    
    % --- Panel 1: Full Time Signal (5 seconds) ---
    subplot(3, total_cols, col_idx);
    plot(time_vec, x, 'Color', col, 'LineWidth', 0.6);
    hold on;
    % Highlight the zoomed segment with a transparent patch or boundary lines
    y_limits = [-9, 9];
    patch([zoom_window(1), zoom_window(2), zoom_window(2), zoom_window(1)], ...
          [y_limits(1), y_limits(1), y_limits(2), y_limits(2)], ...
          [1, 0.9, 0.2], 'FaceAlpha', 0.35, 'EdgeColor', [0.8, 0.6, 0.1], 'LineWidth', 1.2);
    hold off;
    title([title_str, ' — Signal Temporel Complet (5 s)'], 'FontWeight', 'bold', 'FontSize', 10);
    xlabel('Temps (s)');
    ylabel('Amplitude (mV)');
    xlim([0, time_vec(end)]);
    ylim(y_limits);
    grid on;

    % --- Panel 2: Zoomed-in Waveform Shape (100 ms) ---
    subplot(3, total_cols, col_idx + total_cols);
    zoom_mask = (time_vec >= zoom_window(1)) & (time_vec <= zoom_window(2));
    time_zoom_ms = (time_vec(zoom_mask) - zoom_window(1)) * 1000; % Relative ms
    x_zoom = x(zoom_mask);
    
    plot(time_zoom_ms, x_zoom, 'Color', col, 'LineWidth', 1.4);
    hold on;
    plot(time_zoom_ms, x_zoom, '.', 'Color', col * 0.7, 'MarkerSize', 5); % Show discrete samples
    yline(0, 'k--', 'LineWidth', 0.8); % Zero voltage baseline
    hold off;
    title(sprintf('Forme d''Onde Zoomée (Fenêtre de %d ms)', round((zoom_window(2)-zoom_window(1))*1000)), ...
          'FontWeight', 'bold', 'FontSize', 10);
    xlabel('Temps Relatif (ms)');
    ylabel('Amplitude (mV)');
    xlim([0, (zoom_window(2) - zoom_window(1)) * 1000]);
    ylim(y_limits);
    grid on;

    % --- Panel 3: Time-Frequency Representation (STFT / Spectrogram) ---
    subplot(3, total_cols, col_idx + 2*total_cols);
    
    % Short-Time Fourier Transform parameters
    nperseg = 1024; % ~102.4 ms window
    noverlap = 896; % ~87.5% overlap for smooth visual time-frequency surface
    
    % Compute STFT spectrogram (with fallback if toolbox function is absent)
    if exist('spectrogram', 'file') == 2
        [~, F_stft, T_stft, P_stft] = spectrogram(x, hann(nperseg), noverlap, nperseg, Fe);
    else
        [P_stft, F_stft, T_stft] = compute_stft_manual(x, Fe, nperseg, noverlap);
    end
    
    % Zoom frequency axis to physiological bandwidth: 0 to 500 Hz
    f_mask = (F_stft <= 500);
    F_sub = F_stft(f_mask);
    P_sub_db = 10 * log10(P_stft(f_mask, :) + 1e-10); % Convert power to decibels (dB)
    
    % Render 2D Time-Frequency colormap
    surf(T_stft, F_sub, P_sub_db, 'EdgeColor', 'none');
    axis tight;
    view(0, 90); % 2D top-down view
    colormap(gca, 'jet');
    c = colorbar;
    c.Label.String = 'Puissance (dB)';
    c.FontSize = 8;
    
    title('Représentation Temps-Fréquence (Spectrogramme STFT)', 'FontWeight', 'bold', 'FontSize', 10);
    xlabel('Temps (s)');
    ylabel('Fréquence (Hz)');
    ylim([0, 500]);
end

% --- Explicit STFT Computation ---
function [P_stft, F_stft, T_stft] = compute_stft_manual(x, Fe, L, noverlap)
    N = length(x);
    step = L - noverlap;
    K = floor((N - L) / step) + 1;
    
    w = 0.5 - 0.5 * cos(2 * pi * (0:L-1)' / (L - 1));
    U = sum(w.^2);
    num_bins = floor(L / 2) + 1;
    
    P_stft = zeros(num_bins, K);
    T_stft = zeros(1, K);
    
    for m = 1:K
        start_idx = (m - 1) * step + 1;
        end_idx   = start_idx + L - 1;
        seg = x(start_idx:end_idx) .* w;
        
        X = fft(seg);
        X_half = X(1:num_bins);
        P = (abs(X_half).^2) / (Fe * U);
        P(2:end-1) = 2 * P(2:end-1);
        
        P_stft(:, m) = P;
        T_stft(m) = (start_idx + L/2 - 1) / Fe; % Center time of window
    end
    
    F_stft = (0:num_bins-1)' * (Fe / L);
end
