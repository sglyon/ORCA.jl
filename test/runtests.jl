using ORCA, PlotlyJS, Test

function myplot(fn)
    x = 0:0.1:2π
    plt = scatter(x=x, y=sin.(x)) |> plot
    ORCA.savefig(plt, fn, verbose=true)
end

for ext in ["pdf", "png", "jpeg", "webp", "eps", "svg"]
    # no errors
    fn = tempname() * "." * ext
    @test myplot(fn)
end
