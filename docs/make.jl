using Laplace
using Documenter

DocMeta.setdocmeta!(Laplace, :DocTestSetup, :(using Laplace); recursive=true)

makedocs(;
    modules=[Laplace],
    authors="Michael Helton",
    repo="https://github.com/heltonmc/Laplace.jl/blob/{commit}{path}#{line}",
    sitename="Laplace.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://heltonmc.github.io/Laplace.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/heltonmc/Laplace.jl",
)
