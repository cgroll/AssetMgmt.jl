####################################
## statistic functions DataFrames ##
####################################

function Base.mean(df::DataFrame, int::Integer)
    if int==2
        error("for row-wise mean, use rowmean instead")
    else
        mus = DataFrame(mean(array(df), 1), names(df))
    end
end

function Base.cov(df::DataFrame)
    return DataFrame(cov(array(df)), names(df))
end

function corrcov(covMatr::DataFrame)
    d = diagm(1/sqrt(diag(array(covMatr))))
    return DataFrame(d*array(covMatr)*d, names(covMatr))
end

##################################
## create random weights matrix ##
##################################

function randWgts(nObs::Int, nAss::Int)
    ## create random weights
    ##
    ## Output:
    ## 	nObs x nAss Array{Float64,2} containing portfolio weights in
    ## 	each row
    
    simVals = rand(nObs, nAss)
    rowsums = sum(simVals, 2)
    wgts = simVals ./ repmat(rowsums, 1, nAss)
end

###############################################
## check matching investment and return data ##
###############################################

function chkMatchInvData(invs::Investments, discRet::Timematr)
    ## test whether investments and return data are matching
    ##
    ## Output: error when inputs don't match

    ## check for conforming dates and assets
    if AssetMgmt.idx(invs) != idx(discRet)
        error("indices / dates of investments and returns must
coincide")
    end

    if AssetMgmt.names(invs) != names(discRet)
        error("asset names of investments and returns must coincide")
    end
end
