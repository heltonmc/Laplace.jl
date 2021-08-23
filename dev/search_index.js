var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = Laplace","category":"page"},{"location":"#Laplace","page":"Home","title":"Laplace","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for Laplace.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [Laplace]","category":"page"},{"location":"#Laplace.hyper_fixed-Tuple{Function,AbstractArray}","page":"Home","title":"Laplace.hyper_fixed","text":"hyper_fixed(f::Function, t::AbstractArray; N = 24)\n\nEvaluate the inverse Laplace transform of f at an array of t by approximating the Bromwhich integral with a fixed hyperbola contour. A real valued time-domain signal is assumed with the integral being calculated by a computable series applying the midpoint rule. In contrast to hyperbola where the contour is dependent on 't', here we fix the contour for the entire array of t values. This function should be considered when F(s) is complex and costly to compute where we want to minimize the number of evaulations of F(s). This operates under the assumption that f(t) is needed for many values of t over some interval t ∈ (t1:t2). The parameters are now time independent. The angle value of the contour defaults to ϕ = 1.09. ϕ and the number of nodes N can be adjusted for accuracy. This approach will in general be less accurate than hyperbola as we are using the same contour over an array of time values, instead of an optimized contour at each time. Bromwhich contour approaches should only be applied for t > 0.\n\nExample\n\n```jldoctest julia> InverseLaplace.hyper_fixed(s -> 1/(s + 1), 2.0:3.0) 2-element Vector{Float64}:  0.1353352832366098  0.04978706836781721\n\n\n\n\n\n","category":"method"},{"location":"#Laplace.hyperbola-Tuple{Function,AbstractFloat}","page":"Home","title":"Laplace.hyperbola","text":"hyperbola(f::Function, t::AbstractFloat; N::Int = 16)\n\nEvaluate the inverse Laplace transform of f at the point t by approximating the Bromwhich integral with a hyperbola contour. A real valued time-domain signal is assumed with the integral being calculated by a computable series applying the midpoint rule. The contour is defined by several parameters. μ controls the extreme nodes with a larger parameter moving the outlier nodes further into left half plane. h is the uniform node spacing with N being the number of nodes on the contour. The parameters depend on both t and N such that the function must be computed N times for each t. This is very inefficient especially if f is computational expensive, so this approach is recommended when only a few values of t are needed. However, this method will provide more accurate results at the cost of computational time compared to fixed contour approaches. The number of nodes, N, defaults to 16. The optimal N is case dependent and arbitrarily increasing N will not result in more accurate results. Smaller values of N will be faster. Bromwhich contour approaches should only be applied for t > 0. We are aiming to optimize the convergence as N -> inf so our parameters are ~ N / t. In other words we want the Bromwhich integral to converge rapidly, and this can be done by starting and ending our integration path in the left hand plane causing exp(st) to decay. If t = 0, the exponential factor does not cause good convergence. If you want to evaluate for t = 0, you should try a small positive value like 1e-30.\n\nExample\n\n```jldoctest julia> InverseLaplace.hyperbola(s -> 1/(s + 1), 2.0) 0.13533528323665164\n\n\n\n\n\n","category":"method"},{"location":"#Laplace.postwid-Tuple{Function,AbstractArray}","page":"Home","title":"Laplace.postwid","text":"postwid(func::Function, t::AbstractArray, v::Array{AbstractFloat,1}=_PWcoeffs(N))\n\nEvaluate the inverse Laplace transform of func over an array of t using the Gaver-Stehfest \"Post-Widder\" algorithm. Computes coefficients once and calculates f(t) across available threads.\n\nExample\n\njulia> setprecision(53); postwid(s -> 1/(s + 1), 2.0:4.0)\n 0.1353356835639731\n 0.049786688998390505\n 0.01831327193414956\n\n\n\n\n\n","category":"method"},{"location":"#Laplace.postwid-Tuple{Function,AbstractFloat}","page":"Home","title":"Laplace.postwid","text":"postwid(func::Function, t::AbstractFloat, v::Array{AbstractFloat,1}=_PWcoeffs(N))\n\nEvaluate the inverse Laplace transform of func at the point t using the Gaver-Stehfest \"Post-Widder\" algorithm. Vk coefficients only depend on the number of expansion terms so can be computed once. N (which must be even) defaults to 18. In general the accuracy in double precision is poor, so arbitrary precision is used throughout. Increasing precision should be accompanied by an increase in the number of coefficients used. Increasing precision without increasing number of coefficients will not yield better accuracy. The inverse is generally true as well. This method is not robust to oscillating F(t) and must be smooth.\n\nExample\n\njulia> setprecision(53); InverseLaplace.postwid(s -> 1/(s + 1), 2.0)\n0.1353356835639731\n\n\n\n\n\n","category":"method"}]
}
