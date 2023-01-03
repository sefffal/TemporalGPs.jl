module TemporalGPs

    using AbstractGPs
    using BlockDiagonals
    using ChainRulesCore
    using FillArrays
    using LinearAlgebra
    using KernelFunctions
    using Random
    using StaticArrays
    using StructArrays
    using Zygote

    using FillArrays: AbstractFill
    using Zygote: _pullback, AContext

    import AbstractGPs: mean, cov, logpdf, FiniteGP, AbstractGP, posterior, dtc, elbo

    using KernelFunctions:
        SimpleKernel,
        KernelSum,
        ScaleTransform,
        ScaledKernel,
        TransformedKernel

    export
        to_sde,
        SArrayStorage,
        ArrayStorage,
        RegularSpacing,
        checkpointed,
        posterior,
        logpdf_and_rand,
        Separable

    # Various bits-and-bobs. Often commiting some type piracy.
    include(joinpath("util", "harmonise.jl"))
    include(joinpath("util", "linear_algebra.jl"))
    include(joinpath("util", "scan.jl"))
    include(joinpath("util", "zygote_friendly_map.jl"))
    # zygote_friendly_map = map
    # Implementation of the matrix exponential that assumes one doesn't require access to the
    # gradient w.r.t. `A`, only `t`. The former is a bit compute-intensive to get at, while the
    # latter is very cheap.

    time_exp(A, t) = exp(A * t)
    function ChainRulesCore.rrule(::typeof(time_exp), A, t)
        B = exp(A * t)
        time_exp_pullback(Ω̄) = (NoTangent(), NoTangent(), sum(Ω̄ .*  (A * B)))
        return B, time_exp_pullback
    end

    include(joinpath("util", "zygote_rules.jl"))
    include(joinpath("util", "gaussian.jl"))
    include(joinpath("util", "mul.jl"))
    include(joinpath("util", "storage_types.jl"))
    include(joinpath("util", "regular_data.jl"))

    # Linear-Gaussian State Space Models.
    include(joinpath("models", "linear_gaussian_conditionals.jl"))
    include(joinpath("models", "gauss_markov_model.jl"))
    include(joinpath("models", "lgssm.jl"))
    include(joinpath("models", "missings.jl"))

    # Converting GPs to Linear-Gaussian SSMs.
    include(joinpath("gp", "data_representations.jl"))
    include(joinpath("gp", "lti_sde.jl"))
    include(joinpath("gp", "posterior_lti_sde.jl"))

    # Converting space-time GPs to Linear-Gaussian SSMs.
    include(joinpath("space_time", "rectilinear_grid.jl"))
    include(joinpath("space_time", "regular_in_time.jl"))
    include(joinpath("space_time", "separable_kernel.jl"))
    include(joinpath("space_time", "to_gauss_markov.jl"))
    include(joinpath("space_time", "pseudo_point.jl"))
end # module
