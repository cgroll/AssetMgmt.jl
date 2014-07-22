module AssetMgmt

using TimeData
using DataFrames
using DataArrays
using Gadfly
using Datetime
#using NLopt

##############################################################################
##
## Exported methods and types
##
##############################################################################

export # functions and types
Investments,
chkEqualsOne,
invRet,
makeWeights

## define basic investment type and type constraints
include("constraints.jl")
include("investments.jl")

## define strategies
include("strategies.jl")
include("markowitz.jl")
include("moments.jl")

## define filters
include("tOv_filters.jl")

## performance analysis
include("performance.jl")
include("diversification.jl")
include("grouping.jl")
include("plotting.jl")

## basic utilities
include("utils.jl")
include("io.jl")

## estimation
include("estimation.jl")
include("mu_sigma_estimation.jl")

## EGARCH
include("egarch.jl")

end # module
