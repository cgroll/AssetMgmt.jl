using TimeData
## using Plotly
## using Gadfly
include("/home/chris/.julia/v0.3/Gadfly/src/Gadfly.jl")
include("/home/chris/.julia/v0.3/AssetMgmt/src/AssetMgmt.jl")
## using DateTime


## kk = by(sectors, :sector, x -> transpose(x[:, 1]))
## for ii=1:size(kk, 1)
##     kk[ii, 2] = array(kk[ii, 2])
## end

##############
## get data ##
##############

include("/home/chris/research/julia/EconDatasets/src/EconDatasets.jl")
logRet = EconDatasets.dataset("SP500")
sectorsStr = EconDatasets.dataset("Sectors")

## transform to discrete non-percentage returns
discRet = exp(logRet/100).-1

t = Task(() -> AssetMgmt.produceEmpiricalMoments(discRet, 4400))
for x in t
    println(x)
end



## transform sector entries into symbols
tickerSymbols = [symbol(symb) for symb in sectorsStr[:, 1]]
sectorSymbols = [symbol(symb) for symb in sectorsStr[:, 2]]
sectors = DataFrame()
sectors[:ticker] = tickerSymbols
sectors[:sector] = sectorSymbols

## transform dataframe to dictionary
(nObs, nAss) = size(logRet)
sectDict = {sectors[ii, 1] => sectors[ii, 2] for ii=1:nAss}

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

#################################
## define groupAssets function ##
#################################

## invert sector dictionary
assetsInSector = invertDict(sectDict)

## get equally weighted portfolio wgts
eqWgts = AssetMgmt.equWgtInvestments(discRet)
sectorWgts = groupAssets(eqWgts, assetsInSector)

for group in assetsInSector
    @show group
end

## find number of stocks per sector
by(sectors, :sector, x -> size(x, 1))


## get number of sectors
nSectors = length(assetsInSector)

## get mean sector returns
sectorRetsDf = DataFrame()
for sect in assetsInSector
    ## @show sect
    @show sect
    ## sectorData = logRet[sect[2]]
    ## sectorMean = rowmeans(sectorData)
    ## sectorRetsDf[convert(Symbol, sect[1])] = core(sectorMean)[:]
end

sectorRets = Timematr(sectorRetsDf, idx(logRet))

plot(x=[1:size(sectorRets, 1)], y=core(sectorRets)[:, 1])

k = plot(x=rand(10), y=rand(10), Geom.line)

k = AssetMgmt.plot(sectorRets)

draw(PDF("myplot.pdf", 6inch, 3inch), k)

energyRets = logRet[assetsInSector["Energy"]]

symbs = convert(Array{Symbol, 1}, sectors[:, 1][:])



for stock in sectDict
    @show stock[2]
end



sectTuple = [(sectors[ii, 1], sectors[ii, 2]) 
             for ii=1:size(sectors, 1) ]

kk = Iterators.groupby(sectTuple, x -> x[2])
for ii in kk
    @show ii
end

for stock in sectDict
    @show stock[2]
end

kk = groupby(sectDict, x -> x[2])


for vals in values(sectDict)
    @show vals
end

dictSymbs = convert(Dict, sectors)
groupby(dictSymbs, dictSymbs)
    
smallData = logRet[1:10, :]



for ii=1:size(smallData, 1)
    


###################################
## transform to discrete returns ##
###################################



(nObs, nAss) = size(discRet)

## create equally weighted investments
eqInvs = AssetMgmt.equWgtInvestments(discRet);
AssetMgmt.str(eqInvs)

## get portfolio returns
pfRet = AssetMgmt.invRet(eqInvs, discRet, name=:equallyWeighted);
str(pfRet)

## get random portfolio returns as benchmarks
randInvs = AssetMgmt.randInvestments(discRet)
randRet1 = AssetMgmt.invRet(randInvs, discRet, name=:randPort1)
randInvs = AssetMgmt.randInvestments(discRet)
randRet2 = AssetMgmt.invRet(randInvs, discRet, name=:randPort2)

## create visual analysis
## AssetMgmt.plotPfPerformance(eqInvs, discRet, randRet1, randRet2, strName=:equWgts)

## get filtered weights
fltWgts = AssetMgmt.regularRB(eqInvs, discRet, freq=250)
AssetMgmt.plotPfPerformance(fltWgts, discRet, pfRet, randRet1, strName=:equWgts_flt250)

## enlargen default plot size
set_default_plot_size(24cm, 14cm)



########################
## plots using plotly ##
########################

using Plotly
Plotly.signin("cgroll", "2it4121bd9")

(x0,y0) = [1,2,3,4], [10,15,13,17]
(x1,y1) = [2,3,4,5], [16,5,11,9]
response = Plotly.plot([[x0 y0] [x1 y1]])
url = response["url"]
filename = response["filename"]


dats = datsAsStrings(discRet)

Plotly.plot({dats, core(discRet[:, 1])[:]},
            ["filename"=>"Plot from Julia API (6)",
             "fileopt"=>"overwrite"])

# plot:
# maxweights / significant weights

