
# Wraps a Sobol sequence sampler with a placeholder to avoid allocations as we sample
mutable struct PointSampler{N}
    s::SobolSeq{N}
    p::MVector{N, Float64}
end

function PointSampler(N::Int64 = 2)
    PointSampler(SobolSeq(N), zeros(MVector{N}))
end

function sample!(sampler::PointSampler)
    next!(sampler.s, sampler.p)
end
