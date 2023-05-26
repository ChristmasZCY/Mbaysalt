%==========================================================================
% matWRF package
%   Calculate relative humidity at 2m
%
% input  :
%   PSFC   --- pressure surface            (Pa)
%   Q2     --- water vapor ratio at 2m     (1)
%   T2     --- potential temperature at 2m (K)
%
% output :
%   rh2    --- relative humidity      (%, 0-100)
%
% Siqi Li, SMAST
% 2022-12-29
%
% Updates:
%
%==========================================================================
function rh2 = calc_rh2(PSFC, Q2, T2)

load_constants;

pres =  PSFC;
tk = T2;

es = EZERO * exp(ESLCON1* (tk-CELKEL) ./ (tk-ESLCON2));
qvs = EPS * es ./ (0.01*pres - (1-EPS)*es);

rh2 = 100 * max(min(Q2./qvs, 1), 0);