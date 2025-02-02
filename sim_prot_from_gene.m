syn_gene = table2array(genes_clearance);
syn_rate = normcdf(zscore(syn_gene));
sTerm = 1 ./ sconnLen .* dt; sTerm(isinf(sTerm)) = 0;
wTerm = weights .* dt;

for i = 1
    alphaTerm = (syn_rate(:,i) .* ROIsize) .* dt;
    iter_max = 10000;
    Rnor = alphaTerm;
    Rall = alphaTerm;
    Pnor = zeros(N_regions);

    for t = 1:iter_max
        %%% moving process
        % regions towards paths
        movDrt = Rnor .* wTerm; % IMPLICIT EXPANSION

        % paths towards regions
        movOut = Pnor .* sTerm; % longer path & smaller v = lower probability of moving out of paths

        Pnor = Pnor - movOut + movDrt;
        Rtmp = Rnor;
        Rnor = Rnor + sum(movOut, 1)' - sum(movDrt, 2);
    
        %%% growth process
        % select a random clearance gene
        degr_gene = syn_gene(:, randi(size(syn_gene, 2)));
        degr_rate = normcdf(zscore(degr_gene));
        betaTerm = exp(-(0.7 .* degr_rate).*dt);

        Rnor = Rnor .* betaTerm + alphaTerm;
    
        if abs(Rnor - Rtmp) < (1e-7 * Rtmp); break; end
        Rall = cat(2, Rall, Rnor);
    end
    figure;
    plot(Rall')
    figure;
    scatter(Rnor, alphaTerm)
end