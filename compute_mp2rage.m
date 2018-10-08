function mp2rage = compute_mp2rage(TI1real,TI1imag,TI2real,TI2imag)

% TI1real : real image, first phase (inversion time)
% TI2real : real image, second phase (inversion time)
% etc.
 
% Use matlab's complex datatype
GRE_TI1 = complex(TI1real,TI1imag);
GRE_TI2 = complex(TI2real,TI2imag);

% Compute MP2RAGE. Order of 1,2 doesn't matter because we're taking the
% real part at the end anyway
MP2RAGEcalc = (conj(GRE_TI1).*GRE_TI2)./(abs(GRE_TI1).^2 + abs(GRE_TI2).^2);
mp2rage = real(MP2RAGEcalc);

% Rescale to all positive values. Normalization enforces a range [-0.5,0.5]
mp2rage = 1 + mp2rage;
