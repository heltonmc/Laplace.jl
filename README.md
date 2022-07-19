<h1 align="center">
Laplace.jl
</h1>
<p align="center">Numerical procedures to perform inverse Laplace transforms
  
 <div align="center">


[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://heltonmc.github.io/Laplace.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://heltonmc.github.io/Laplace.jl/dev)
[![Build Status](https://github.com/heltonmc/Laplace.jl/workflows/CI/badge.svg)](https://github.com/heltonmc/Laplace.jl/actions)
[![Coverage](https://codecov.io/gh/heltonmc/Laplace.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/heltonmc/Laplace.jl)
 
</div>  
  
## Overview

Numerical implementations to numerically invert the Laplace transform

$$ \mathscr{L}^{-1} \\{ \bar{f}(s) \\} = f(t) = \frac{1}{2 \pi i} {\int_{\sigma - i \infty}^{\sigma + i \infty} \bar{f}(s) e^{st} \\, ds} $$

### Current algorithms

#### Real arguments
- Gaver-Stehfest method

#### Complex arguments
- Bromwich contour integration
  - Hyperbola
  - Fixed hyperbola (inversion at many time points)
  - Improved talbot
