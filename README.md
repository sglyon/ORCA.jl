# DEPRECATION NOTICE

The primary purpose of this package is to enable saving `PlotlyBase.Plot` and `PlotlyJS.SyncPlot` figures to files like svg, png, pdf, etc.

This functionality is now built in to PlotlyBase.jl itself -- and thus available to PlotlyJS -- making ORCA.jl obsolete and not needed.

Please use the `savefig` routines built directly in to PlotlyBase instead of using this package

# ORCA.jl



[![Build Status](https://travis-ci.org/sglyon/ORCA.jl.svg?branch=master)](https://travis-ci.org/sglyon/ORCA.jl)

Julia interface to plotly's [ORCA](https://github.com/plotly/orca) tool for
generating static files based on plotly graph specs.

## Usage

There is a single exported function `savefig`. After loading PlotlyBase.jl or
PlotlyJS.jl and creating a plot named `p` you can call
`savefig(p::Union{Plot,SyncPlot}, filename::String; options...)` to save the
plot in `p` to a file named `filename`. See docstring for a description of
`options`.
