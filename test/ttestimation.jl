module testEstimation

using Base.Test
using DataFrames
using TimeData
using Datetime
include(string(Pkg.dir("AssetMgmt"), "/src/AssetMgmt.jl"))

println("\n Running estimator tests\n")

t = Task(() -> AssetMgmt.subsampleProducer(10, 5))
generatedIndices = Array((Int, Int), 5)
counter = 1
for x in t
    generatedIndices[counter] = x
    counter += 1
end

expIndices = [(1,5), 
              (1,6),
              (1,7),
              (1,8),
              (1,9)]

@test isequal(generatedIndices, expIndices)

t = Task(() -> AssetMgmt.subsampleProducer(10, 5, rolling=true))
generatedIndices = Array(Any, 5)
counter = 1
for x in t
    generatedIndices[counter] = x
    counter += 1
end

expIndices = [(1,5),
              (2,6),
              (3,7),
              (4,8),
              (5,9)]

@test isequal(generatedIndices, expIndices)

end
