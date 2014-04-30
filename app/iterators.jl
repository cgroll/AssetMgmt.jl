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
ymGrouped = groupby(close, x -> map(x -> year(x), dates))

ma60 = map(mean, partition(close[1:10], 8, 1))
