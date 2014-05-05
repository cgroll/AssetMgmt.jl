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
