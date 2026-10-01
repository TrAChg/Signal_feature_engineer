function [zc_count, zc_rate] = feat_zero_crossing(x, threshold)
% FEAT_ZERO_CROSSING Computes the Zero Crossing (ZC) count and rate

if nargin < 2 || isempty(threshold)
    threshold = 0; % Strict zero crossing by default
end

x = x(:); % Ensure column vector
N = length(x);

if N < 2
    zc_count = 0;
    zc_rate = 0;
    return;
end

% Consecutive sample products to detect sign changes
x_current = x(1:end-1);
x_next    = x(2:end);

% Condition 1: Sign reversal across zero
sign_change = (x_current .* x_next < 0);

% Condition 2: Amplitude step exceeds noise deadband
amplitude_step = abs(x_next - x_current) >= threshold;

% Count valid zero crossings
zc_logical = sign_change & amplitude_step;
zc_count = sum(zc_logical);

% Normalized rate (fraction of intervals that cross zero)
zc_rate = zc_count / (N - 1);
end
