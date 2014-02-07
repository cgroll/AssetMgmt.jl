module testInvestments

using Base.Test
using DataFrames
using Datetime
using TimeData
## using Markowitz

vals = rand(8, 4)
vals = AssetMgmt.makeWeights(vals)
valsDf = DataFrame(vals)

invs = AssetMgmt.Investments(valsDf, [1:8])


end
