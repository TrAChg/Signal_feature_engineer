function energy_val = feat_energy(x)
    x = x(:);
    energy_val = sum(x.^2);
end
