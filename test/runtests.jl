module runtests

tests = [## "ttconstraints.jl",
         ## "moments.jl",
         ## "ttinvestments.jl",
         ## "portfolio.jl",
         "ttutils.jl",
         ## "ttstrategies.jl",
         "ttuniverseModels.jl"
         ]

for t in tests
    include(string(Pkg.dir("AssetMgmt"), "/test/", t))
end

end
