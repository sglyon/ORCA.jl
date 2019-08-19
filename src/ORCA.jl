module ORCA

using JSON
using PlotlyJS

export savefig, orca_cmd

let
    paths_file = joinpath(@__DIR__, "..", "deps", "paths.jl")
    if !isfile(paths_file)
        error("ORCA not installed properly. Please call `Pkg.build(\"ORCA\")`")
    end
    include(paths_file)
end


"""
  program_installed(p)

Uses `Sys.which()` to check if the executable for program `p` is accessible.
"""
function program_installed(p::AbstractString)
    res = Sys.which(p)
    ret = res==nothing ? false : true
    return ret
end

"Check for xvfb-run, required for headless operations (like Docker)"
xvfb_exists() = program_installed("xvfb-run")
"Check for inkscape, required for emf exports"
inkscape_exists() = program_installed("inkscape") # required for "emf" exports
"Check for pdftops, required for eps export"
pdftops_exists() = program_installed("pdftops") # required for eps output

"Check if the code is running inside docker container"
is_docker() = isfile("/.dockerenv") ? true : false


"""
    infer_format(filename)

Performs basic checks and returns the file format to use which is also
supported by ORCA. This funtion performs a quick check to see if the
dependencies needed by some export format are available.

If output file has no extension then "png" is used.
"""
function infer_format(fn::AbstractString)
    # list of supported output formats
    output_types = ["png", "jpeg", "webp", "svg", "pdf", "eps", "emf"]

    # no extension provided use "png"
    !occursin(".", fn) && return "png"

    ext = split(basename(fn), '.')[end]
    if !in(ext, output_types)
        error("Output type should be one of $output_types")
    end

    (ext=="eps") && (!pdftops_exists()) && error("program pdftops required for writing 'eps'")
    (ext=="wmf") && (!inkscape_exists()) && error("program inkscape required for writing 'wmf'")
    (ext=="emf") && (!inkscape_exists()) && error("program inkscape required for writing 'emf'")

    return ext
end



"""
    savefig(plot, outfile, format; scale, width, height, verbose])

Save PlotlyJS plot as an image file using ORCA. Format of the output
file is inferred from the extension. 

Supported formats are `png`, `jpeg`, `svg`, `pdf`, `eps`, `emf`, `webp`.

## Arguments

* plot: PlotlyJS plot
* outfile: Output filename
* format: Output format
* scale: Default scale factor is 1.0
* height: Default is to use one from plot's layout 
* width: Default is to use one from plot's layout
* verbose: For debugging will show output from STDERR, and STDOUT

For some file format external dependencies should be met;

* pdftops is needed for eps export
* inkscape is required for wmf and emf export 
* xvfb is required for all plots in a headless environment

## Example 

```julia
plt=scatter(;x=rand(10), y=rand(10), mode="markers") |> plot
savefig(plt, "simple_plot.png"; format="png")
```

"""
function savefig(p::PlotlyJS.SyncPlot, outfile::AbstractString, 
        format::AbstractString; 
        scale=1.0,
        width=nothing, height=nothing,
        verbose=false
    )
    
    exec_cmd=`$orca_cmd graph`
    is_docker() && !xvfb_exists() && error("xvfb-run required to operate inside container")
    if is_docker() == true
        exec_cmd=`/usr/bin/xvfb-run $exec_cmd`
    end
    
    # materialize plot in JSON format
    json_file = tempname() * ".json"
    write(json_file, JSON.json(p))
    
    output_filename = basename(outfile)
    output_dirname  = dirname(outfile)

    exec_cmd = `$exec_cmd $json_file -f $format -o $output_filename --scale $scale`
    output_dirname !== "" && (exec_cmd=`$exec_cmd -d $output_dirname`)
    height !== nothing && (exec_cmd=`$exec_cmd --height $height`)
    width !== nothing && (exec_cmd=`$exec_cmd --width $width`)
    verbose && (exec_cmd=`$exec_cmd --verbose`)

    sout = Pipe()
    serr = Pipe()
    proc = run(pipeline(exec_cmd, stdout=sout, stderr=serr))
    close.([sout.in, serr.in])
    outstr=read(sout, String)
    errstr=read(serr, String)

    # if return code is not zero
    if (proc.exitcode != 0)
        println("STDOUT: $outstr")
        println("STDERR: $errstr")
        error("Error converting plot to image")
    end

    verbose && println("STDOUT:\n$outstr\nSTDERR:\n$errstr")    

    return true
end


function savefig(p::PlotlyJS.SyncPlot, outfile::AbstractString; 
        scale=1.0,
        width=nothing, height=nothing,
        verbose=false
    )
    
    format=infer_format(outfile)
    savefig(p, outfile, format; 
            scale=scale, width=width, height=height, verbose=verbose)

    return true
end



end # module
