##################################
## visualize colored line paths ##
##################################

function gdfGroupPlot(tn::AbstractTimenum;
                      variableInfo::DataFrame = DataFrame(),
                      joinCol::Symbol = :AssetLabel,
                      colorCol::Symbol = :AssetClass,
                      legendName::String = "automatic")

    ## get variable names
    nams = names(tn)

    ## standard data manipulation:
    ## remove / replace NAs, convert dates
    tn = narowrm(tn)
    vals = asArr(tn, Float64, NaN) # NA to NaN
    dats = dat2num(tn)
    df = composeDataFrame([dats vals], [:Idx; nams])
    stackedData = stack(df, nams)

    ## transform asset label symbols to UTF8Strings for join
    stackedData[:variable] = symbToStr(stackedData[:variable])
    
    # rename column name
    rename!(stackedData, :variable, joinCol)

    # join asset class
    subInfo = variableInfo[:, [joinCol, colorCol]]
    xx = join(stackedData, subInfo, on = joinCol)

    if legendName == "automaticName" # automatic legend name
        p = plot(xx, x="Idx", y="value",
                 group=joinCol, color=colorCol,
                 Geom.line)
    else
        p = plot(xx, x="Idx", y="value",
                 group=joinCol, color=colorCol,
                 Geom.line,
                 Guide.colorkey(legendName))
    end
    return p
end


#################################
## visualize mu-sigma universe ##
#################################

function plotAssetMoments(mod::MuSigmaModel;
                          scalingFunc::Function = AssetMgmt.defaultMuSigmaScaling,
                          assetInfo::DataFrame = DataFrame(),
                          joinCol::Symbol = :AssetLabel,
                          colorCol::Symbol = :AssetClass,
                          legendName::String = "automaticName")
    ## Visualize return moments.
    ## Return moments are scaled according to some given function.
    ## Also, points can be colored with respect to additional
    ## information. 
    
    ## check for extended asset info
    extendedInfo = true
    if isempty(assetInfo)
        extendedInfo = false
    end
    
    ## get number of asset
    nAss = size(mod.mu, 1)

    ## extract and scale moments
    sigmas = getVolas(mod)
    scaledMus, scaledSigmas = scalingFunc(mod.mu, sigmas)

    ## convert symbol names to strings for join
    nams = AssetMgmt.symbToStr(mod.names)

    ## get moments as DataFrame
    momentsTable = DataFrame(Asset = nams, mu = scaledMus,
                             sigma = scaledSigmas)

    if extendedInfo # append additional asset info
        rename!(momentsTable, :Asset, joinCol)

        ## conduct join
        momentsTable = join(momentsTable, assetInfo, on = joinCol)
    end

    if extendedInfo # special coloring 
        if legendName == "automaticName" # automatic legend name
            p = plot(momentsTable, x="sigma", y="mu",
                     color=colorCol,
                     Geom.point, Guide.title("μ-σ diagram"), 
                     Guide.xlabel("σ"), Guide.ylabel("μ"));
        else
            p = plot(momentsTable, x="sigma", y="mu",
                     color=colorCol,
                     Geom.point, Guide.title("μ-σ diagram"), 
                     Guide.xlabel("σ"), Guide.ylabel("μ"),
                     Guide.colorkey(legendName));
        end
    else # no special coloring
        if legendName == "automaticName"
            p = plot(momentsTable, x="sigma", y="mu",
                     color="Asset",
                     Geom.point, Guide.title("μ-σ diagram"), 
                     Guide.xlabel("σ"), Guide.ylabel("μ"));
        else
            p = plot(momentsTable, x="sigma", y="mu",
                     color="Asset",
                     Geom.point, Guide.title("μ-σ diagram"), 
                     Guide.xlabel("σ"), Guide.ylabel("μ"),
                     Guide.colorkey(legendName));
        end
    end
    return p
end


## plot efficient frontier
##------------------------

function plotEff(mod::MuSigmaModel;
                 scalingFunc = AssetMgmt.defaultMuSigmaScaling,
                 nPoints = 50)

    ## extract and scale moments
    sigmas = AssetMgmt.getVolas(mod)
    scaledMus, scaledSigmas = scalingFunc(mod.mu, sigmas)
    
    ## calculate efficient frontier moments
    muEffUnscaled, sigmaEffUnscaled =
        getEffFrontier(mod, nPoints = nPoints)

    ## scale efficient frontier
    muEff, sigmaEff =
        scalingFunc(muEffUnscaled, sigmaEffUnscaled)
    
    p = plot(layer(x=sigmaEff, y=muEff, Geom.line),
             layer(x=scaledSigmas, y=scaledMus, Geom.point));

    return p
end


## plot asset and portfolio moments
##---------------------------------

function plotPfsAndUniverse(mod::MuSigmaModel,
                            wgts = Array{Float64, 2};
                            scalingFunc::Function = AssetMgmt.defaultMuSigmaScaling)
    ## portfolios should be given in rows

    ## extract and scale moments
    sigmas = AssetMgmt.getVolas(mod)
    scaledMus, scaledSigmas = scalingFunc(mod.mu, sigmas)

    ## get type names
    typNams = UTF8String["asset" for ii=1:length(sigmas)]
    
    ## get asset moments as DataFrame
    assetMomentsTable = DataFrame(mu = scaledMus,
                                  sigma = scaledSigmas,
                                  color = typNams)

    ## get portfolio moments
    muPfs = AssetMgmt.getPMean(wgts, mod.mu)
    sigmaPfs = sqrt(AssetMgmt.getPVar(wgts, mod.sigma))

    ## scale portfolio moments
    scaledMuPfs, scaledSigmaPfs =
        scalingFunc(muPfs, sigmaPfs)

    ## get type names
    typNams = UTF8String["portfolio" for ii=1:length(sigmaPfs)]

    ## get portfolio moments as DataFrame
    pfMomentsTable = DataFrame(mu = scaledMuPfs,
                               sigma = scaledSigmaPfs,
                               color = typNams)

    ## join tables
    momentsTable = [assetMomentsTable; pfMomentsTable]

    p = plot(momentsTable, x="sigma", y="mu",
             color="color",
             Geom.point, Guide.title("μ-σ diagram"), 
             Guide.xlabel("σ"), Guide.ylabel("μ"));
    
    return p
end


## import Gadfly.plot
## function plot(tm::Timematr, settings...)
##     ## plot Timematr object
##     ## - multi-line plot
##     ## - index must be dates convertible to strings
##     ## - plot only some maximum number of randomly picked paths
##     ## - plot some statistics
    
##     dats = AssetMgmt.datsAsStrings(tm)
##     (nObs, nAss) = size(tm)
    
##     ## maximum number of paths plotted
##     maxPaths = 10

##     ## get values for paths
##     if nAss > maxPaths
##         ## get randomly drawn paths

##         chosenAssets = randperm(nAss)[1:maxPaths]
##         randPaths = core(tm)[:, chosenAssets]
##         nams = names(tm)[chosenAssets]

##         ## get statistics
##         allVals = core(tm)
##         averagePath = mean(allVals, 2)
##         lowestEndingPath = indmin(allVals[end, :])
##         lowPath = allVals[:, lowestEndingPath]
##         highestEndingPath = indmax(allVals[end, :])
##         highPath = allVals[:, highestEndingPath]

##         vals = [averagePath lowPath highPath randPaths]
##         valsDf = AssetMgmt.composeDataFrame(vals,
##                                             [:mean, :low, :high,
##                                              nams])  
##     else
##         valsDf = copy(tm.vals)
##     end

##     nams = names(valsDf)
##     valsDf[:Idx] = dats
    
##     stackedData = stack(valsDf, nams)

##     plot(stackedData, x="Idx", y="value",
##          color="variable", Geom.line, settings...)
## end


## function plotWithBMs(pfRets::Timematr, bmIndex...) 
##     ## plot portfolio price evolution for returns with benchmarks
##     ##
##     ## Inputs:
##     ## 	pfRets 	nObs x 1 Timematr containing portfolio returns
##     ## 	bmIndex	tuple of nObs x 1 Timematr objects containing time
##     ## 				series (returns) of benchmarks

##     data = pfRets
    
##     nBMs = length(bmIndex)
##     for ii=1:nBMs
##         data = [data bmIndex[ii]]
##     end

##     ## calculate cumulated prices
##     prices = cumprod(data .+ 1, 1)

##     AssetMgmt.plot(prices, Guide.xlabel("time"),
##                    Guide.ylabel("price"),
##                    Guide.title("portfolio evolution with benchmarks")) 
## end

## function plotPriceReturnSeries(pfRets::Timematr,
##                                discRet::Timematr,
##                                BMs...;
##                                strName = :strategy)

##     ## plot price evolution of assets and portfolios
##     ## 
##     ## Inputs:
##     ## 	pfRets	nObs x 1 Timematr of portfolio returns
##     ## 	discRet 	nObs x nAss Timematr of discrete asset returns
##     ## 	BMs		nBms tuple of benchmark returns
##     ## 	strName	optional expression to label strategy in plots 
    
##     (nObs, nAss) = size(discRet)
##     nBMs = length(BMs)
    
##     ## get cumulated prices for individual assets
##     cumPrices = cumprod(discRet .+ 1, 1)

##     ############################
##     ## asset price evolutions ##
##     ############################

##     pricePlot = AssetMgmt.plot(cumPrices, Guide.xlabel("time"),
##                                Guide.ylabel("price"),
##                                Guide.title("normalized asset prices"));

##     ################################################
##     ## portfolio price evolutions with benchmarks ##
##     ################################################

##     ## plot portfolio evolution with benchmarks
##     bmPlot = AssetMgmt.plotWithBMs(pfRets, BMs...);


##     #################################
##     ## plot returns and volatility ##
##     #################################

##     returnPlot = AssetMgmt.plot(pfRets, Guide.xlabel("time"),
##                                 Guide.ylabel("return"),
##                                 Guide.title("portfolio returns")); 

##     ## get squared portfolio returns as proxy for volatility
##     volaPlot = AssetMgmt.plot(pfRets.^2, Guide.xlabel("time"),
##                               Guide.ylabel("squared returns"),
##                               Guide.title("squared portfolio
## returns")); 

##     ################################
##     ## putting the parts together ##
##     ################################

##     pfEvolution = vstack(pricePlot, bmPlot, returnPlot, volaPlot)
##     filename = string("pics/pfEvolution_", strName, ".pdf")
##     draw(PDF(filename, 10inch, 20inch), pfEvolution)
## end

## function plotTOverDiversification(rawInvs::Investments,
##                                   fltInvs::Investments,
##                                   discRet::Timematr;
##                                   ## sectors::Dict; 
##                                   strName = :strategy)

##     ## plot intended and realized turnover and diversification
##     ## measures 
##     ##
##     ## Inputs:
##     ## 	rawInvs	nObs x nAss unfiltered Investments
##     ## 	fltInvs	nObs x nAss turnover reducing Investments
##     ## 	discRet	nObs x nAss Timematr of discrete asset returns
##     ## 	sectors	nSect x 1 Dictionary of assets per sector
##     ## 	strName	optional: expression with strategy name for plot
##     ## 				labeling 

##     ##############
##     ## turnover ##
##     ##############

##     ## get investment turnover
##     tOver = AssetMgmt.turnover(fltInvs, discRet)
##     intTOver = AssetMgmt.turnover(rawInvs, discRet)

##     tOData = [tOver intTOver]
    
##     tOPlot = AssetMgmt.plot(tOData, Guide.xlabel("time"),
##                Guide.ylabel("turnover"),
##                Guide.title("actual turnover vs intended turnover"));

##     ##############################
##     ## diversification measures ##
##     ##############################

##     ## get diversification measures
##     divIndicators = AssetMgmt.diversification(fltInvs)

##     ## plot diversification measures related to number of assets
##     divNAssets = divIndicators[[:nAss, :nSignAss, :nShort]]
##     divNAssetsPlot = AssetMgmt.plot(divNAssets, Guide.xlabel("time"),
##                                     Guide.ylabel("number"),
##                                     Guide.title("diversification measures"));

##     ## plot diversification measures expressed as fractions 
##     divFractions = divIndicators[[:maxWgt, :Gini, :stdWgt]]
##     divFractionsPlot = AssetMgmt.plot(divFractions, Guide.xlabel("time"),
##                Guide.ylabel("value"),
##                Guide.title("diversification measures"));

##     divPlot = vstack(tOPlot, divNAssetsPlot, divFractionsPlot)
##     filename = string("pics/pfDiversif_", strName, ".pdf")
##     draw(PDF(filename, 10inch, 12inch), divPlot)
## end
    
## function plotPfDistribution(pfRet::Timematr,
##                             discRet::Timematr,
##                             BMs...; 
##                             strName = :strategy)
##     ## plot strategy performance indicators

##     (nObs, nAss) = size(discRet)
##     nBMs = length(BMs)
    
##     #################################
##     ## portfolio return statistics ##
##     #################################

##     retStats = AssetMgmt.returnStatistics(pfRet)

##     distrPlots = Array(Any, (nBMs+1))
    
##     distrPlots[1] = plot(pfRet.vals, x=string(strName),
##          xintercept = [retStats.mu, retStats.VaR95, retStats.VaR99],
##          Geom.histogram(minbincount=80),
##          Geom.vline(color="orange"),
##          Guide.xlabel("returns"),
##          Guide.ylabel("frequency"),
##          Guide.title("portfolio return distribution"));

##     for ii=1:nBMs
##         ## currBM = Timematr(BMs[ii].vals, idx(BMs[ii]))
##         currBM = BMs[ii]
##         title = string(string(names(currBM)[1]), " return distribution")
##         retStats = AssetMgmt.returnStatistics(currBM)
##         distrPlots[ii+1] = plot(currBM.vals, x=string(names(currBM.vals)[1]),
##                              xintercept = [retStats.mu, retStats.VaR95, retStats.VaR99],
##                              Geom.histogram(minbincount=80),
##                              Geom.vline(color="orange"),
##                              Guide.xlabel("returns"),
##                              Guide.ylabel("frequency"),
##                              Guide.title(title));
##     end
    
##     ###################
##     ## mu-sigma-plot ##
##     ###################

##     retStats = AssetMgmt.returnStatistics(pfRet)
    
##     ## get moments of assets
##     assetMus = mean(core(discRet), 1)
##     assetSigmas = std(core(discRet), 1)
##     ## covs = cov(discRet)
##     ## for ii=1:nAss
##     ##     assetSigmas[names(discRet)[ii]] = sqrt(covs[ii, ii]) 
##     ## end
##     assetNames = Array(ASCIIString, nAss)
##     for ii=1:nAss
##         assetNames[ii] = string(names(discRet)[ii])
##     end
##     assetTyps = ["asset" for ii=1:nAss]
    
##     ## get moments for benchmark strategies
##     bmMus = Array(Float64, nBMs)
##     bmSigmas = Array(Float64, nBMs)
##     bmNames = Array(ASCIIString, nBMs)
##     for ii=1:nBMs
##         currBM = BMs[ii]
##         bmMus[ii] = mean(core(currBM))
##         bmSigmas[ii] = std(core(currBM))
##         bmNames[ii] = string(names(currBM)[1])
##     end
##     bmTyps = ["Benchm" for ii=1:nBMs]
    
##     ## get moments for portfolio return
##     pfMu = retStats.mu
##     pfSigma = retStats.sigma
##     pfName = string(strName)
##     pfTyp = "portf"

##     moments = DataFrame()
##     ## moments[:mus] = [assetMus[:], bmMus[:], pfMu]
##     ## moments[:sigmas] = [assetSigmas[:], bmSigmas[:], pfSigma]
##     ## moments[:names] = [assetNames[:], bmNames[:], pfName]
##     ## moments[:typ] = [assetTyps[:], bmTyps[:], pfTyp]

##     ## for debugging
##     ## display(moments)
        
##     ## new version should prioritize labels of portfolios over assets
##     moments[:mus] = [bmMus[:], pfMu, assetMus[:]]
##     moments[:sigmas] = [bmSigmas[:], pfSigma, assetSigmas[:]]
##     moments[:names] = [bmNames[:], pfName, assetNames[:]]
##     moments[:typ] = [bmTyps[:], pfTyp, assetTyps[:]]
    
##     muSigmaPlot = plot(layer(moments,
##                              x="sigmas", y="mus", color="typ",
##                              Geom.point),
##                        layer(moments, x="sigmas", y="mus",
##                              label="names", Geom.label),
##                        Guide.xlabel("sigma"),
##                        Guide.ylabel("mu"),
##                        Guide.title("mu-sigma combinations"))

##     distrPlots = vstack(muSigmaPlot, distrPlots...)
##     filename = string("pics/pfDistrib_", strName, ".pdf")
##     draw(PDF(filename, 10inch, 25inch), distrPlots)

## end

## function plotSectorAnalysis(fltInvs::Investments,
##                             discRet::Timematr,
##                             assetsInSector::Dict; 
##                             strName = :strategy)

##         ## get mean sector return series
##     sectorReturns = AssetMgmt.groupVars(discRet,
##                                         assetsInSector,
##                                         x -> mean(x, 2))

##     ## get sector means and vars
##     mus = mean(core(sectorReturns)*100, 1)
##     sigmas = std(core(sectorReturns)*100, 1)

##     ## get sector weights
##     sectorWgts = mean(core(AssetMgmt.groupAssets(fltInvs, assetsInSector)),
##                       1) 
##     absWgts = abs(sectorWgts)
##     longAssets = 1*(sectorWgts .> 0)

##     df = DataFrame()
##     nams = [string(names(sectorReturns)[ii]) for ii=1:length(mus)]
##     df[:names] = nams
##     df[:mus] = mus[:]
##     df[:sigmas] = sigmas[:]
##     df[:absWgts] = absWgts[:]
##     df[:weights] = sectorWgts[:]
##     df[:long] = longAssets[:]

##     muSigmaPlot = plot(layer(df, x="sigmas",
##                              y="mus",
##                              color="weights", Geom.point),
##                        layer(df, x="sigmas", y="mus",
##                              label="names", Geom.label),
##                        Guide.xlabel("sigma"),
##                        Guide.ylabel("mu"),
##                        Guide.title("sector weights with sector moments")
##                        )
    
##     ## get weights for each sector
##     sectorWgts = AssetMgmt.groupAssets(fltInvs, assetsInSector)

##     title = string(string(strName), " portfolio sector weights")
##     sectorWgtsPlot = AssetMgmt.plot(convert(Timematr, sectorWgts), 
##                                     Guide.xlabel("time"),
##                                     Guide.ylabel("sector weight"),
##                                     Guide.title(title))

##     scaledSectorWgts = DataFrame()
##     for eachSector in assetsInSector
##         nAssPerSector = length(eachSector[2])
##         sectorName = eachSector[1]
##         scaledSectorWgts[sectorName] =
##             (core(sectorWgts[sectorName]) ./ nAssPerSector)[:]
##     end
##     scaledSectorWgtsTm = Timematr(scaledSectorWgts, idx(fltInvs))

##     title = string(string(strName), " average asset weight per sector")
##     averageWgtsPlot = AssetMgmt.plot(scaledSectorWgtsTm,
##                                      Guide.xlabel("time"),
##                                      Guide.ylabel("average weight"),
##                                      Guide.title(title))

##     sectPlots = vstack(muSigmaPlot, sectorWgtsPlot, averageWgtsPlot)
##     filename = string("pics/pfSectors_", strName, ".pdf")
##     draw(PDF(filename, 10inch, 20inch), sectPlots)

## end
