module testUniverse

using TimeData
using DataFrames
using Distributions
using NumericExtensions
using Winston

include(string(Pkg.dir("AssetMgmt"), "/src/AssetMgmt.jl"))

println("\n Running bootstrap analysis\n")

###############
## real data ##
###############

fullData = readTimedata("/home/chris/research/asset_mgmt/data/datesLogRet.csv")
data = fullData[:, 50:250]

## dataFile = string(Pkg.dir("AssetMgmt"), "/data/discr_ret.csv")
## data = readTimedata(dataFile)

univ = AssetMgmt.Universe(data)

## get "true" underlying distribution
pdMat = PDMat(array(univ.covMatr))
d = MvNormal(array(univ.mus)[:], pdMat)

muGrid = AssetMgmt.getMuGrid(univ)
effPfs = AssetMgmt.effPf(univ, muGrid)
effMus = AssetMgmt.getPMean(effPfs, univ)
effVars = AssetMgmt.getPVar(effPfs, univ)

## plot true efficient frontier
p = FramedPlot(title="Bootstrapped efficient frontiers",
         xlabel="\\sigma",
         ylabel="\\mu")

add(p, Curve(sqrt(effVars), effMus[:], color="red"))
add(p, Points(sqrt(diag(array(univ.covMatr))), array(univ.mus)))

nBootstr = 100
nObs = 200

realizedMus = Array(Float64, length(muGrid), nBootstr)
realizedVars = Array(Float64, length(muGrid), nBootstr)

for ii=1:nBootstr
    simVals = rand(d, nObs)'
    simVals = Timematr(simVals, names(univ))

    fakeUniv = AssetMgmt.Universe(simVals)
    fakeMuGrid = AssetMgmt.getMuGrid(fakeUniv)
    fakeEffPfs = AssetMgmt.effPf(fakeUniv, fakeMuGrid)

    realizedMus[:, ii] = AssetMgmt.getPMean(fakeEffPfs, univ)
    realizedVars[:, ii] = AssetMgmt.getPVar(fakeEffPfs, univ)

    ## realizedSigmas = sqrt(realizedVars)
    add(p, Curve(sqrt(realizedVars[:, ii]), realizedMus[:, ii], color="blue"))
end
p


#######################################
## visualized bootstrapped frontiers ##
#######################################


