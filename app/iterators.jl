url =
    "http://ichart.finance.yahoo.com/table.csv?s=AAPL&a=11&b=12&c=1980&d=03&e=30&f=2014&g=d&ignore=.csv"

raw =download(url)
days = open(raw) |> readall |> s -> split(s, "\n");
individualValues = map(s -> split(s, ","), days);
recent = filter(n -> contains(n[1], "201"), individualValues)

using Iterators
using Datetime

dates = map(r -> date(r[1]), recent)
close = map(r -> parsefloat(r[7]), recent)

ym = map(x -> (year(x), month(x)), dates)
ymGrouped = groupby(dates, x -> (year(x), month(x)))

for day in groupby(dates, x -> (year(x), month(x)))
    println(string(day[1])[1:7])
    dayOfMonth = length(day)
    @show dayOfMonth
end

ma60 = map(mean, partition(close[1:10], 8, 1))


using Iterators
using Gadfly

function ar(phi::Float64, sigma::Float64)
    x -> phi * x + sigma * randn()
end

plotar(arseq, title) = plot(x=1:length(arseq), y=arseq, Geom.line,
                            Guide.xlabel("Time"), Guide.ylabel(""),
                            Guide.title(title))

const ar1coef = 0.9
const ar1sigma = 0.15                                           

k = (ar1coef, ar1sigma) |>
    x -> apply(ar, x) |>
    f -> iterate(f, ar1sigma*rand()) |>
    i -> collect(take(i, 250)) |>
    s -> plotar(s, "AR(1) Time Series")

draw(PNG("myplot.png", 6inch, 3inch), k)


for i in take(1:100, 5)
    @show i
end


[word for word in repeated("Hello", 3)]

kk = collect(partition(1:9, 3, 2))

for i in groupby(["face", "foo", "bar", "book", "baz", "zzz"], x -> x[1])
    @show i
end



using DataFrames, RDatasets

iris = dataset("datasets", "iris")

by(iris, :Species, size)
by(iris, :Species, df -> mean(df[:PetalLength]))
by(iris, :Species, df -> DataFrame(N = size(df, 1)))
