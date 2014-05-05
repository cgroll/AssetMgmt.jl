function gmv(mus::DataFrame, covMatr::DataFrame)
    ## global minimum variance portfolio
    nAss = size(mus, 2)

    oneArr = ones(nAss)
    invCov = inv(array(covMatr))
    wgts = 1/(oneArr'*invCov*oneArr).*invCov*oneArr

    return wgts'
end
    
