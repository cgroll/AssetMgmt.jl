type retStat
    name::Symbol
    mu::Float64
    median::Float64
    sigma::Float64
    VaR95::Float64
    VaR99::Float64
    VaR995::Float64
end

function returnStatistics(tm::Timematr)
    ## calculate statistic on return series
    
    if size(tm, 2) > 1
        error("returnStatistics only works for single asset yet") 
    end

    rets = core(tm)

    mu = mean(rets)
    sigma = std(rets)
    (median, VaR95, VaR99, VaR995) = quantile(rets[:], [0.5; 0.05; 0.01; 0.005])

    return retStat(names(tm)[1], mu, median, sigma, VaR95, VaR99, VaR995)
end

