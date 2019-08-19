# ORCA.jl

[![Build Status](https://travis-ci.org/asbisen/ORCA.jl.svg?branch=master)](https://travis-ci.org/asbisen/ORCA.jl)

Julia interface to plotly's [ORCA](https://github.com/plotly/orca) tool for
generating static files based on plotly graph specs.

## Usage

There is a single exported function `savefig`. After loading PlotlyBase.jl or
PlotlyJS.jl and creating a plot named `p` you can call
`savefig(p::Union{Plot,SyncPlot}, filename::String; options...)` to save the
plot in `p` to a file named `filename`. See docstring for a description of
`options`.

## Dependencies

Some of the export file formats depends upon 3rd party applications. Make sure these dependencies are met if you plan to export in these formats. 

* EPS: For "eps" export "pdf2ps" binary is required. On ubuntu you can get it by "apt-get install poppler-utils"

* EMF: Inkscape is required for these file types. On ubuntu you can install it by "apt-get install inkscape"

Also if you are planning to use ORCA.jl inside a docker container, then "xvfb-run" is needed and can be installed by "apt-get install xvfb" on ubuntu.
