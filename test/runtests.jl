using ORCA, PlotlyBase, Test

for ext in ["pdf", "png", "eps", "jpeg", "webp"]
    # no errors
    @test myplot(tempname() * "." * ext) === nothing
end
