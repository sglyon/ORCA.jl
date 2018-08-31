using ORCA, PlotlyBase, Test

function myplot(fn)
    x = 0:0.1:2π
    plt = Plot(scatter(x=x, y=sin.(x)))
    savefig(plt, fn)
end

for ext in ["pdf", "png", "jpeg", "webp"]
    # no errors
    @test myplot(tempname() * "." * ext) === nothing
end
