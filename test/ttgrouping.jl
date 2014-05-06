module testGrouping

using Base.Test
using DataFrames
using TimeData
using Datetime
include(string(Pkg.dir("AssetMgmt"), "/src/AssetMgmt.jl"))

println("\n Running grouping tests\n")

## create core data
nObs = 10
varNames = [:a, :b, :c, :d, :e, :f]
simVals = rand(nObs, 6)
dats = Date{ISOCalendar}[date(2013, 7, ii) for ii=1:nObs]

## create groups
groups = {:group1 => [:a, :c, :e], :group2 => [:b, :d],
          :group3 => [:f]}  

## test groupVars
tm = Timematr(simVals, varNames, dats)
tmGroup = AssetMgmt.groupVars(tm, groups, x -> sum(x, 2))

## test groupAssets
invs = AssetMgmt.equWgtInvestments(tm)
groupedInvs = AssetMgmt.groupAssets(invs, groups)
groupedInvsSorted = groupedInvs[[:group1, :group2, :group3]]

## calculate expected result
expDf = AssetMgmt.composeDataFrame(repmat([0.5 1/3 1/6], nObs, 1), 
                                   [:group1 :group2 :group3])
expInvs = AssetMgmt.Investments(expDf, dats)

@test isequal(expInvs, groupedInvsSorted)


groupedTm = AssetMgmt.groupAssets(invs, groups, x -> sum(x, 2))
end
