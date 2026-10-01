function [Pxx, f] = compute_psd_welch(x, Fe, nperseg, noverlap)
    if nargin < 3 || isempty(nperseg)
        nperseg = 2048;
    end
    if nargin < 4 || isempty(noverlap)
        noverlap = 1024;
    end

    x = x(:);
    
    if exist('pwelch', 'file') == 2
        window = hann(nperseg);
        [Pxx, f] = pwelch(x, window, noverlap, nperseg, Fe);
    else
        N = length(x);
        X = fft(x);
        Pxx = (abs(X(1:floor(N/2)+1)).^2) / (N * Fe);
        Pxx(2:end-1) = 2 * Pxx(2:end-1);
        f = (0:floor(N/2))' * (Fe / N);
    end
end
