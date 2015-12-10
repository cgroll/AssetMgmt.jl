module AssetMgmt

using TimeData
using DataFrames
using DataArrays
using Gadfly
using Dates

## using Datetime
#using NLopt

##############################################################################
##
## Exported methods and types
##
##############################################################################

export # functions and types
UniverseModel,
MuSigmaModel,
DistributionModel,
UniverseEstimate,
MuSigmaUniverse,
InitialStrategy,
MuSigmaStrategy,
MaxMu,
MinSigma,
InvestmentStrategy,
SeparateTurnover
## Investments,
## chkEqualsOne,
## invRet,
## makeWeights

## define basic investment type and type constraints
include("universeModels.jl")
include("universeEstimate.jl")
include("initialStrategies.jl")
include("strategies.jl")
include("utils.jl")
include("plotting.jl")
include("muSigmaFunctions.jl")

## include("constraints.jl")
## include("investments.jl")

## ## define strategies
## include("strategies.jl")
## include("markowitz.jl")
## include("moments.jl")

## ## define filters
## include("tOv_filters.jl")

## ## performance analysis
## include("performance.jl")
## include("diversification.jl")
## include("grouping.jl")
## include("plotting.jl")

## ## basic utilities
## include("utils.jl")
## include("io.jl")

## ## estimation
## include("estimation.jl")
## include("mu_sigma_estimation.jl")

## ## EGARCH
## include("egarch.jl")

end # module
