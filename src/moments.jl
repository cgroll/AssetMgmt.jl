###########################
## Portfolio get moments ##
###########################

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

function getPVar(wgts::Array{Float64, 2}, covMatr::Array{Float64, 2})
    nPfs = size(wgts, 1)
    pVars = Array(Float64, nPfs)
    for ii=1:nPfs
        pVars[ii, 1] = (wgts[ii, :]*covMatr*(wgts[ii, :])')[1]
    end
    return pVars
end

function getPVar(invs::Investments, covMatr::DataFrame)
    pVars = getPVar(core(invs), array(covMatr))
    return Timematr(pVars, idx(invs))
end
