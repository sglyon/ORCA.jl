module ORCA

using PlotlyBase, JSON, HTTP

export orca_cmd, savefig

let
    paths_file = joinpath(@__DIR__, "..", "deps", "paths.jl")
    if !isfile(paths_file)
        error("ORCA not installed properly. Please call `Pkg.build(\"ORCA\")`")
    end
    include(paths_file)
end

"""
    savefig(p::Plot, fn::AbstractString; format=nothing, scale=nothing,
    width=nothing, height=nothing)

Save a plot `p` to a file named `fn`. If `format` is given and is one of
(png, jpeg, webp, svg, pdf, eps), it will be the format of the file. By
default the format is guessed from the extension of `fn`. `scale` sets the
image scale. `width` and `height` set the dimensions, in pixels. Defaults
are taken from `p.layout`, or supplied by plotly
"""
function PlotlyBase.savefig(
        p::Plot, fn::AbstractString; format=nothing, scale=nothing,
        width=nothing, height=nothing
    )
    ext = split(fn, ".")[end]
    if format === nothing
        format = ext
    end

    # end early if we got json or html
    format == "json" && return savejson(p, fn)
    format == "html" && return open(fn, "w") do f show(f, MIME"text/html"(), p) end

    # construct payload
    payload = Dict{Any,Any}(:figure => p, :format=>format)
    scale !== nothing && setindex!(payload, scale, :scale)
    width !== nothing && setindex!(payload, width, :width)
    height !== nothing && setindex!(payload, height, :height)

    ensure_server()

    # make request to server
    res = HTTP.post(
        "http://localhost:7982", Dict(),
        JSON.json(payload),
        status_exception=false
    )

    # save if success, otherwise report error
    if res.status == 200
        open(fn, "w") do f
            write(f, res.body)
        end
    else
        error(String(res.body))
    end
    nothing
end

const proc = Ref{Base.Process}()

function restart_server()
    global proc
    if server_running()
        kill(proc[])
    end
    proc[] = open(`$orca_cmd server --port=7982 --graph-only`)
    atexit(() -> kill(proc[]))
end

function server_running()
    global proc
    isassigned(proc) && process_running(proc[])
end

ensure_server() = !server_running() && restart_server()
__init__() = restart_server()

end # module
