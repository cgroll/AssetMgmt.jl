##########################################
## define dictionary inverting function ##
##########################################

function invertDict(dict::Dict)
    invDict = Dict()
    for val in unique(values(dict))
        ## for each possible value, find all keys
        ## @show val
        keysWithGivenValue = Array(Symbol, 0)
        ## counter = 1
        for key in dict
            ## @show key
            if key[2] == val
                push!(keysWithGivenValue, key[1])
                ## counter = counter + 1
            end
        end
        invDict[val] = keysWithGivenValue
    end
    return invDict
end

#########################################
## split-apply-combine functionalities ##
#########################################

## grouping columns:
## - grouping is determined through dictionary
## - grouping occurs with respect to columns as opposed to rows 
## - grouping will return dimensions nObs x nGroups
## - for each group, dictionary lists all members of the group
## - function should return scalar value and require first input

function groupAssets(invs::Investments, groups::Dict{Any, Any})
    ## aggregate weights with respect to group membership
    ## 
    ## Inputs:
    ##	invs 				nObs x nAss Investments
    ## 	groups 			nGroups x 1 Dict{Symbol, Array{Symbol}}
    ## 						specifying group membership
    ## 
    ## Outputs:
    ## 	groupedInvs 	nObs x nGroups group Investments
    
    wgts = invs.vals
    groupWgts = DataFrame()
    for group in groups
        ## group[2] is Array of symbols
        coreWgts = array(wgts[group[2]])
        groupWgts[group[1]] = sum(coreWgts, 2)[:]
    end
    AssetMgmt.Investments(groupWgts, idx(invs))
end

function groupAssets(invs::Investments, groups::Dict{Any, Any},
                     f::Function)
    ## apply function to groups of assets
    ## 
    ## Inputs:
    ##	invs 				nObs x nAss Investments
    ## 	groups 			nGroups x 1 Dict{Symbol, Array{Symbol}}
    ## 						specifying group membership
    ## 	f					function to be applied on groups, return
    ## 						column vector of scalar values per group
    ## 
    ## Outputs:
    ## 	groupedInvs 	nObs x nGroups Timematr / Timedata

    wgts = invs.vals
    groupWgts = DataFrame()
    for group in groups
        ## group[2] is Array of symbols
        coreWgts = array(wgts[group[2]])
        groupWgts[group[1]] = f(coreWgts)[:]
    end
    AssetMgmt.Timematr(groupWgts, idx(invs))
end

function groupVars(tm::Timematr, groups::Dict{Any, Any},
                     f::Function)
    ## apply function to groups of assets
    ## 
    ## Inputs:
    ##	tm 				nObs x nAss Timematr
    ## 	groups 			nGroups x 1 Dict{Symbol, Array{Symbol}}
    ## 						specifying group membership
    ## 	f					function to be applied on groups, return
    ## 						column vector of scalar values per group
    ## 
    ## Outputs:
    ## 	groupedInvs 	nObs x nGroups Timematr / Timedata

    wgts = tm.vals
    groupWgts = DataFrame()
    for group in groups
        ## group[2] is Array of symbols
        coreWgts = array(wgts[group[2]])
        groupWgts[group[1]] = f(coreWgts)[:]
    end
    AssetMgmt.Timematr(groupWgts, idx(tm))
end

function sectorPerformances(invs::Investments, discRet::Timematr,
                           assetsInSector::Dict{Any, Any})
    ## calculate (normalized) sector return
    ##
    ## Inputs:
    ## 	invs 				nObs x nAss Investments of portfolio weights
    ## 	discRet			nObs x nAss Timematr of asset returns
    ## 	assetsInSector	nGroups x 1 Dict{Symbol, Array{Symbol}}
    ## 						specifying group membership
    ##
    ## Outputs:
    ## 	nObs x nGroups Timematr of sector returns

    ## get overall sector weights for normalization
    sectorWgts = AssetMgmt.groupAssets(invs, assetsInSector)

    ## transform investments to Timematr to allow mathematical
    ## functions 
    invsTm = convert(Timematr, invs)
    
    ## preallocation
    sectorPortfolios = DataFrame(size(sectorWgts)...)
    rename!(sectorPortfolios, names(sectorPortfolios), names(sectorWgts))

    for sect in assetsInSector
        currentSectorWgts = invsTm[sect[2]]
        associatedReturns = discRet[:, sect[2]]
        unscaledSectorReturn = rowsums(currentSectorWgts .*
                                       associatedReturns)
        sectorPortfolios[sect[1]] = (core(unscaledSectorReturn) ./
                                     core(sectorWgts[sect[1]]))[:]
    end
    return Timematr(sectorPortfolios, idx(invs))
end
