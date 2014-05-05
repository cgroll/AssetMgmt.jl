module AssetMgmt

using TimeData
using DataFrames
using DataArrays
using Gadfly

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
## include("moments.jl")

## define filters
include("tOv_filters.jl")

## performance analysis
include("performance.jl")
include("diversification.jl")
include("grouping.jl")
include("plotting.jl")

## basic utilities
include("utils.jl")

end # module
