module ORCA

using PlotlyBase: savefig

export savefig

function __init__()
    @warn """
    ORCA.jl has been deprecated and all savefig functionality
    has been implemented directly in PlotlyBase itself.

    By implementing in PlotlyBase.jl, the savefig routines are automatically
    available to PlotlyJS.jl also.
    """
end

end # module
