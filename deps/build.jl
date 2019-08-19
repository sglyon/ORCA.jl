using Conda

env = :_ORCA_jl_
Conda.add_channel("plotly", env)
Conda.add("plotly-orca", env)
Conda.update(env)

open("paths.jl", "w") do f
orca_cmd = Sys.iswindows() ? joinpath(Conda.prefix(env), "orca_app", "orca.exe") : joinpath(Conda.bin_dir(env), "orca")
    println(f, "# This file is automatically generated by build.jl DO NOT EDIT")
    println(f, "const orca_cmd = `$(orca_cmd)`")
end
