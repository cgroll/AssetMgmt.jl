## remark: Markowitz itself does not rely on any time information
## hence: it is built solely on DataFrames

#########################
## Universe definition ##
#########################

type Universe
    mus::DataFrame
    covMatr::DataFrame
    mvp::Portfolio
    auxVals::Array{Float64, 1}

    function Universe(mus::DataFrame, covMatr::DataFrame,
                      mvp::Portfolio, auxVals::Array{Float64, 1})
        nMus = size(mus, 2)
        nCovs = size(covMatr, 1)
        nWgts = size(mvp)
        if !(nMus == nCovs == nWgts)
            error("Dimensions of mus and covs must match")
        end
        new(mus, covMatr, mvp, auxVals)
    end
end


#################################
## Universe outer constructors ##
#################################

function Universe(mus::DataFrame, covMatr::DataFrame)
    auxV = auxVals(mus, covMatr)    
    p = mvp(mus, covMatr, [auxV...])
    return Universe(mus, covMatr, p, [auxV...])
end

function Universe(tm::Timematr)
    ## from data
    mus = mean(tm)
    covMatr = cov(tm)
    return Universe(mus, covMatr)
end

## function Universe(mus::Array{Float64, 1}, covMatr::Array{Float64, 2})
##     muDf = DataFrame(mus[:]')
##     covDf = DataFrame(covMatr)
##     univ = Universe(muDf, covDf)
##     return univ
## end

## function Universe(mus::Array{Float64, 2}, covMatr::Array{Float64, 2})
##     univ = Universe(mus[:], covMatr)
##     return univ
## end

###################
## Universe size ##
###################

import Base.size
function size(univ::Universe)
    return length(univ.mus);
end

##############################
## get Markowitz portfolios ##
##############################

function auxVals(univ::Universe)
    return univ.auxVals
end    

function auxVals(musDf::DataFrame, covMatrDf::DataFrame)
    ## extract values
    covMatr = array(covMatrDf);
    mus = array(musDf)[:];
    
    ## get size of universe
    nAss = size(covMatrDf, 1);
    
    ## derive fundamental values
    onesN = ones(nAss);
    
    a = mus'/covMatr*mus;
    b = onesN'/covMatr*mus;
    c = onesN'/covMatr*onesN;
    d = a[1]*c[1] - b[1]^2;
    
    return a[1], b[1], c[1], d
end    


function mvp(univ::Universe)
    return univ.mvp
end

function mvp(musDf::DataFrame, covMatrDf::DataFrame,
             auxV::Array{Float64, 1})
    ## extract values
    covMatr = array(covMatrDf);
    
    ## get helper values
    c = auxV[3, 1]
    
    ## get size of universe
    nAss = size(covMatrDf, 1);
    
    ## derive fundamental values
    onesN = ones(nAss);
    
    ## get GMVP
    pf = Portfolio([inv(covMatr)*onesN/c], names(musDf));
    
    return pf
end


######################
## display Universe ##
######################

import Base.Multimedia.display
function display(univ::Universe)
    ## get type and field information
    typ = typeof(univ)
    println("\ntype: $typ")    
    print("dimensions: ")
    print(size(univ))
    print("\n")

    print("\nMean values:\n")

    display(univ.mus)

    print("\n\nCorrelation matrix, variances on diagonal:\n")
    rho = corrcov(univ.covMatr)

    ## put variances on diagonal
    nAss = size(univ)
    for ii=1:nAss
        rho[ii, ii] = univ.covMatr[ii, ii]
    end
    displayCovMatr(rho)
end

function displayCovMatr(covMatr::DataFrame)
    namesColumn = DataFrame(variable = names(covMatr))
    display([covMatr namesColumn]    )
end

###########
## names ##
###########

import Base.names
function names(univ::Universe)
    return names(univ.mus)
end

#######################
## portfolio moments ##
#######################

function getPMean(pf::Portfolio, univ::Universe)
    pMean = array(univ.mus)*pf.weights
    return pMean
end

function getPVar(pf::Portfolio, univ::Universe)
    w = pf.weights
    pVar = w'*array(univ.covMatr)*w
    return pVar
end

function getPMoments(pf::Portfolio, univ::Universe)
    mu = getPMean(pf, univ)
    pVar = getPVar(pf, univ)
    return [mu pVar]
end

##############################
## get Markowitz portfolios ##
##############################

function getMuGrid(univ::Universe, addup = 0.05::Float64,
                   nGrid = 10::Int)
    minMuPf = mvp(univ);
    minMu = getPMean(minMuPf, univ);
    
    return linspace(minMu[1], (maximum(array(univ.mus)) + addup), nGrid)
end

## function getFrontier(univ::Universe, addup = 0.05::Float64, nGrid =
##                      10::Int)
##     muGrid = getMuGrid(univ, addup, nGrid)

## end


function effPf(univ::Universe, mus::Array{Float64, 1})
    ## minimize variance for given portfolio means mu
    nAss = size(univ)
    nMus = length(mus)
    
    R = [array(univ.mus)[:] ones(nAss)]
    covMatr = array(univ.covMatr)

    muExtended = [mus[:]', ones(nMus)']
    
    (a, b, c, d) = auxVals(univ);
    phiInv = 1/d*[c -b; -b a];

    ## weights = inv(covMatr)*R*inv(R'*inv(covMatr)*R)*[mu[1], 1];
    weights = inv(covMatr)*R*phiInv*muExtended # each column is
                                        # weights vector

    invs = Investments(DataFrame(weights', names(univ.mus)))
end


