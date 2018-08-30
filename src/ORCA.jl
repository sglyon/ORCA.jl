module ORCA

using PlotlyBase, JSON

export orca_cmd, savefig

let
    paths_file = joinpath(@__DIR__, "..", "deps", "paths.jl")
    if !isfile(paths_file)
        error("ORCA not installed properly. Please call `Pkg.build(\"ORCA\")`")
    end
    include(paths_file)
end

"""
    savefig(p::Plot, fn::AbstractString; kwargs...)

Save a plot `p` to a file named `fn`

The following are accepted as keyword arguments

$(_SAVEFIG_DOC_EXTRA)
"""
function PlotlyBase.savefig(
        p::Plot, fn::AbstractString; kwargs...
    )
    kw = Dict{Any,Any}(kwargs)
    if !haskey(kw, :format)
        parts = split(basename(fn), '.', limit=2)
        if length(parts) == 2
            kw[:format] = String(parts[2])
        end
    end
    options = []
    for argname in _ARGS
        arg = pop!(kw, argname, nothing)
        arg == nothing && continue
        push!(options, "--$(argname)=$arg")
    end

    for flagname in _ARGS
        flag = pop!(kw, flagname, nothing)
        flag == nothing && continue
        push!(options, "--$(flagname)=$flag")
    end

    if length(kw) > 0
        msg = "Unrecognized keyword argument(s) $(collect(keys(kw)))"
        error(msg * " Please see docstring for supported arguments")
    end

    opts = join(options, " ")
    cmd = length(options) > 0 ? `$orca_cmd graph $(JSON.json(p)) -o $fn $(opts)` :
        `$orca_cmd graph $(JSON.json(p)) -o $fn`
end

end # module
