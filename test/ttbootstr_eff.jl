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
data = fullData[:, 1:end]

## dataFile = string(Pkg.dir("AssetMgmt"), "/data/discr_ret.csv")
## data = readTimedata(dataFile)

univ = AssetMgmt.Universe(data)

## get "true" underlying distribution
pdMat = PDMat(array(univ.covMatr))
d = MvNormal(array(univ.mus)[:], pdMat)

muAddon = 0.5
nMuGrid = 40
muGrid = AssetMgmt.getMuGrid(univ, muAddon, nMuGrid)
effPfs = AssetMgmt.effPf(univ, muGrid)
effMus = AssetMgmt.getPMean(effPfs, univ)
effVars = AssetMgmt.getPVar(effPfs, univ)

## plot true efficient frontier
p = FramedPlot(title="Bootstrapped efficient frontiers",
         xlabel="\\sigma",
         ylabel="\\mu")

add(p, Curve(sqrt(effVars), effMus[:], color="red"))
add(p, Points(sqrt(diag(array(univ.covMatr))), array(univ.mus)))

nBootstr = 250
nObs = 4600

realizedMus = Array(Float64, length(muGrid), nBootstr)
realizedVars = Array(Float64, length(muGrid), nBootstr)

tic();

@profile begin
for ii=1:nBootstr
## for ii=1:5
    simVals = rand(d, nObs)'

    mus = mean(simVals, 1)
    covMatr = cov(simVals)

    fakeUniv = AssetMgmt.Universe(mus, covMatr, names(univ))
    fakeMuGrid = AssetMgmt.getMuGrid(fakeUniv, muAddon, nMuGrid)
    fakeEffPfs = AssetMgmt.effPf(fakeUniv, fakeMuGrid)

    realizedMus[:, ii] = AssetMgmt.getPMean(fakeEffPfs, univ)
    realizedVars[:, ii] = AssetMgmt.getPVar(fakeEffPfs, univ)

    ## realizedSigmas = sqrt(realizedVars)
    add(p, Curve(sqrt(realizedVars[:, ii]), realizedMus[:, ii], color="blue"))
end
end
    
toc()

p


#######################################
## visualized bootstrapped frontiers ##
#######################################


