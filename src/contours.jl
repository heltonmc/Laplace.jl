### Implement Laplace transform along a hyperbola contour ###

# 1.
# Weideman, J., and L. Trefethen.
# Parabolic and hyperbolic contours for computing the Bromwich integral.
# Mathematics of Computation 76.259 (2007): 1341-1356.

# 2.
# Liemert, André, and Alwin Kienle.
# Application of the Laplace transform in time-domain optical spectroscopy and imaging.
# Journal of biomedical optics 20.11 (2015): 110502.

### adaptive contour for each time point (can't precompute f(s) or sk)

# parameterized hyperbola contour
# parameters are given by ref [2] which are given in increased precision from calculations given in [1]
function s(θ, N, t)
    μ = 4.492075287 * N / t
    ϕ = 1.172104229 
    return μ + im * μ * sinh(θ + im * ϕ)
end
# derivitive of hyperbola contour
function ds(θ, N, t)
    μ = 4.492075287 * N / t
    ϕ = 1.172104229
    return im * μ * cosh(θ + im * ϕ)
end

# compute the laplace transform along a hyperbola contour fixed time point
"""
    hyperbola(f::Function, t::AbstractFloat; N::Int = 16)
Evaluate the inverse Laplace transform of `f` at the point `t` by approximating the Bromwhich integral with a hyperbola contour.
A real valued time-domain signal is assumed with the integral being calculated by a computable series applying the midpoint rule.
The contour is defined by several parameters. μ controls the extreme nodes with a larger parameter moving the outlier nodes further into left half plane.
h is the uniform node spacing with N being the number of nodes on the contour. The parameters depend on both t and N such that the function must be computed N times for each t.
This is very inefficient especially if f is computational expensive, so this approach is recommended when only a few values of t are needed.
However, this method will provide more accurate results at the cost of computational time compared to fixed contour approaches.
The number of nodes, N, defaults to 16. The optimal N is case dependent and arbitrarily increasing N will not result in more accurate results. Smaller values of N will be faster.
Bromwhich contour approaches should only be applied for t > 0. We are aiming to optimize the convergence as N -> inf so our parameters are ~ N / t.
In other words we want the Bromwhich integral to converge rapidly, and this can be done by starting and ending our integration path in the left hand plane causing exp(st) to decay.
If t = 0, the exponential factor does not cause good convergence. If you want to evaluate for t = 0, you should try a small positive value like 1e-30.
# Example
```jldoctest
julia> InverseLaplace.hyperbola(s -> 1/(s + 1), 2.0)
0.13533528323665164
"""
function hyperbola(f::Function, t::AbstractFloat; N = 16)
    a =  zero(Complex{eltype(t)})
    h = 1.081792140 / N
    for k in 0:N-1
        sk = s((k + 1/2) * h, N, t)
        dsk = ds((k + 1/2) * h, N, t)
        a += f(sk) * exp(sk * t) * dsk
    end
    return imag(a) * h / pi
end

# loop through an entire time array with multithreads
function hyperbola(f::Function, t::AbstractArray; N = 16)
    out = similar(t)
    Threads.@threads for ind in eachindex(t)
        out[ind] = hyperbola(f, t[ind], N = N)
    end
    return out
end

#### fixed integration path (can precompute) ####

# get the fixed integration components
function hyper_coef(N, t::AbstractArray; ϕ = 1.09)
    A = acosh(((π - 2 * ϕ) * t[end] / t[1] + 4 * ϕ - π) / ((4 * ϕ - π) * sin(ϕ)))
    μ = (4 * π * ϕ - π^2) * N / t[end] / A
    h = A / N
    return μ, h
end

# compute the fixed hyperbola contour
s_fixed(θ, μ; ϕ = 1.09) = μ + im * μ * sinh(θ + im * ϕ)
ds_fixed(θ, μ; ϕ = 1.09) = im * μ * cosh(θ + im * ϕ)

# compute the function values over the fixed contour nodes
function fixed_sk(f::Function, N, t::AbstractArray)
    μ, h = hyper_coef(N, t)
    a = zeros(Complex{eltype(h)}, Int(N))
    sk = similar(a)
    Threads.@threads for k in 0:Int(N)-1
        sk[k+1] = s_fixed((k + 1/2) * h, μ)
        dsk = ds_fixed((k + 1/2) * h, μ)
        a[k+1] = f(sk[k + 1]) * dsk
    end
    return a, sk, h
end

function hyper_fixed_points(a, sk, h, t::AbstractFloat)
    b = zero(eltype(a))
    for ind in eachindex(sk)
        b += a[ind] * exp(sk[ind] * t)
    end
    return imag(b) * h / π
end

"""
    hyper_fixed(f::Function, t::AbstractArray; N = 24)
Evaluate the inverse Laplace transform of `f` at an array of `t` by approximating the Bromwhich integral with a fixed hyperbola contour.
A real valued time-domain signal is assumed with the integral being calculated by a computable series applying the midpoint rule.
In contrast to `hyperbola` where the contour is dependent on 't', here we fix the contour for the entire array of `t` values.
This function should be considered when F(s) is complex and costly to compute where we want to minimize the number of evaulations of F(s).
This operates under the assumption that f(t) is needed for many values of `t` over some interval `t ∈ (t1:t2)`. The parameters are now time independent.
The angle value of the contour defaults to `ϕ = 1.09`. `ϕ` and the number of nodes `N` can be adjusted for accuracy.
This approach will in general be less accurate than `hyperbola` as we are using the same contour over an array of time values, instead of an optimized contour at each time.
Bromwhich contour approaches should only be applied for t > 0.
# Example
```jldoctest
julia> InverseLaplace.hyper_fixed(s -> 1/(s + 1), 2.0:3.0)
2-element Vector{Float64}:
 0.1353352832366098
 0.04978706836781721
"""
function hyper_fixed(f::Function, t::AbstractArray; N = 24)
    a, sk, h = fixed_sk(f, N, t)
    out = zeros(eltype(h), length(t))
    Threads.@threads for ind in eachindex(t)
        out[ind] = hyper_fixed_points(a, sk, h, t[ind])
    end
    return out
end

#=

### Implement Laplace transform along improved Talbot contour ###

## adaptive contour for each time point (can't precompute f(ω) or sk)

function z(θ, N, t; α = 0.6407, c = 1.3580)
    B = c*(sin(α*pi))^2 / ( 2*α*c^2 * (sin(α*pi))^2 - pi*sin(2*α*pi)*(sinh(α*c))^2)
    σ = 2*α*c^2 * B
    μ = 2*(sinh(α*c))^2 * B
    ν = (sinh(2*α*c) - 2*α*c)*B

    # return both z(θ) and z'(θ)
    return N/t * (-σ + μ*θ*cot(α*θ) + ν*im*θ), N/t * (ν*im  + μ*(cot(α*θ) - α*θ*(csc(α*θ))^2))
end

# compute the laplace transform along a hyperbola contour fixed time point
function talbot_improved(f::Function, N, t::AbstractFloat)
    a =  zero(Complex{eltype(N)})
    h = 2*π/N
    for k in 1:N
        zk, dzk = z(-π + (k - 1/2)*h, N, t)       
        a += f(zk)*exp(zk*t)*dzk
    end
    return a/N/im
end

function talbot_improved(f::Function, N, t::AbstractFloat)
    a =  zero(Complex{eltype(N)})
    h = 2*π/N
    for k in 1:N/2 # for real-valued f(t) need only to consider half of
        zk, dzk = z(-π + (k - 1/2)*h, N, t)       
        a += f(zk)*exp(zk*t)*dzk
        println(-π + (k - 1/2)*h)
    end
    return 2*a/N/im
end


function talbot_improved(f::Function, N, t::AbstractFloat)
    a =  zero(Complex{eltype(N)})
    h = π/N
    for k in 1:N # for real-valued f(t) need only to consider half of evaluations
        zk, dzk = z(-π + (k - 1/2)*2*h, N, t)       
        a += f(zk)*exp(zk*t)*dzk
    end
    return real(a/N/im)
end

=#
