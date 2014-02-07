###########################
## Portfolio get moments ##
###########################

function getPMean(pf::Portfolio, mus::DataFrame)
    pMean = array(mus)*pf.weights
    return pMean
end

function getPMean(invs::Investments, mus::DataFrame)
    ## possibly multiple mu vectors
    (nMus, nAss) = size(mus)
    if nMus == 1
        pMean = weights(invs)*array(mus)'
    else                                # multiple mus
        pMean = sum(weights(invs).*array(mus), 2)
    end
    tm = Timematr(pMean, idx(invs))
    return tm
end

#################################
## Portfolio covariance matrix ##
#################################

function getPVar(pf::Portfolio, covMatr::DataFrame)
    pVar = (pf.weights)'*array(covMatr)*pf.weights
end

function getPVar(invs::Investments, covMatr::DataFrame)
    nDays = size(invs, 1)
    pVars = Array(Float64, nDays)
    covArr = array(covMatr)
    wgts = core(invs)
    for ii=1:nDays
        pVars[ii, 1] = (wgts[ii, :]*covArr*(wgts[ii, :])')[1]
    end
    
    varTm = Timematr(pVars, idx(invs))
    return varTm
end
