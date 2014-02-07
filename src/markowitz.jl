## remark: Markowitz itself does not rely on any time information
## hence: it is built solely on DataFrames

#########################
## Universe definition ##
#########################

type Universe
    mus::DataFrame
    covMatr::DataFrame
    ## mvp::Portfolio
    ## auxVals::Array{Float64, 1}

    function Universe(mus::DataFrame, covMatr::DataFrame)
        nMus = size(mus, 2)
        nCovs = size(covMatr, 1)
        if(nMus != nCovs)
            error("Dimensions of mus and covs must match")
        end
        new(mus, covMatr)
    end
end

        ## mvp::Portfolio, auxVals::Array{Float64, 1}
#################################
## Universe outer constructors ##
#################################

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
    ## extract values
    covMatr = array(univ.covMatr);
    mus = array(univ.mus)[:];
    
    ## get size of universe
    nAss = size(univ);
    
    ## derive fundamental values
    onesN = ones(nAss);
    
    a = mus'/covMatr*mus;
    b = onesN'/covMatr*mus;
    c = onesN'/covMatr*onesN;
    d = a[1]*c[1] - b[1]^2;
    
    return a[1], b[1], c[1], d
end    


function mvp(univ::Universe)
    ## extract values
    covMatr = array(univ.covMatr);
    
    ## get helper values
    (a, b, c, d) = auxVals(univ);
    
    ## get size of universe
    nAss = size(univ);
    
    ## derive fundamental values
    onesN = ones(nAss);
    
    ## get GMVP
    pf = Portfolio([inv(covMatr)*onesN/c], names(univ));
    
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
