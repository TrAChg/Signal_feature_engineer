function [e_low, e_high, rel_low, rel_high] = feat_band_energy(Pxx, f, low_band, high_band)

    if nargin < 3 || isempty(low_band)
        low_band = [20, 150];
    end
    if nargin < 4 || isempty(high_band)
        high_band = [150, 450];
    end

    df = f(2) - f(1);
    %m0 = trapz(f, Pxx);
    m0 = sum(Pxx) * df;

    idx_L = (f >= low_band(1)) & (f <= low_band(2));
    idx_H = (f >= high_band(1)) & (f <= high_band(2));
    
    e_low = trapz(f(idx_L), Pxx(idx_L));
    e_high = trapz(f(idx_H), Pxx(idx_H));
    
    rel_low = e_low / (m0 + eps);
    rel_high = e_high / (m0 + eps);
end
