using Laplace
using Documenter

makedocs(
    modules=[Laplace],
    authors="Michael Helton",
    sitename="Laplace.jl",
    format = Documenter.HTML(),
    pages=[
        "Home" => "index.md",
    ]
)

deploydocs(
    repo="github.com/heltonmc/Laplace.jl.git"
)
