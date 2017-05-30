# This file is part of the IntervalArithmetic.jl package; MIT licensed

type IntervalParameters

    precision_type::Type
    precision::Int
    rounding::Symbol
    pi::Interval{BigFloat}

    IntervalParameters() = new(BigFloat, 256, :narrow)  # leave out pi
end

const parameters = IntervalParameters()


## Precision:

doc"`big53` creates an equivalent `BigFloat` interval to a given `Float64` interval."
function big53(a::Interval{Float64})
    setprecision(Interval, 53) do  # precision of Float64
        convert(Interval{BigFloat}, a)
    end
end
function big53(a::FastInterval{Float64})
    setprecision(FastInterval, 53) do  # precision of Float64
        convert(FastInterval{BigFloat}, a)
    end
end

function big53(x::Float64)
    # BigFloat(x, 53)  # in Julia v0.6

    setprecision(53) do
        BigFloat(x)
    end
end


setprecision(::Type{Interval}, ::Type{Float64}) = parameters.precision_type = Float64
setprecision(::Type{FastInterval}, ::Type{Float64}) = parameters.precision_type = Float64
# does not change the BigFloat precision


function setprecision{T<:AbstractFloat}(::Type{Interval}, ::Type{T}, prec::Integer)
    #println("SETTING BIGFLOAT PRECISION TO $precision")
    setprecision(BigFloat, prec)

    parameters.precision_type = T
    parameters.precision = prec
    parameters.pi = convert(Interval{BigFloat}, pi)

    prec
end
setprecision{T<:AbstractFloat}(::Type{FastInterval}, ::Type{T}, prec::Integer) =
    setprecision(Interval, T, prec)

setprecision{T<:AbstractFloat}(::Type{Interval{T}}, prec) = setprecision(Interval, T, prec)
setprecision{T<:AbstractFloat}(::Type{FastInterval{T}}, prec) = setprecision(Interval, T, prec)

setprecision(::Type{Interval}, prec::Integer) = setprecision(Interval, BigFloat, prec)
setprecision(::Type{FastInterval}, prec::Integer) = setprecision(Interval, BigFloat, prec)

function setprecision(f::Function, ::Type{Interval}, prec::Integer)

    old_precision = precision(Interval)
    setprecision(Interval, prec)

    try
        return f()
    finally
        setprecision(Interval, old_precision)
    end
end
setprecision(f::Function, ::Type{FastInterval}, prec::Integer) =
    setprecision(f, Interval, prec)

# setprecision(::Type{Interval}, precision) = setprecision(Interval, precision)
setprecision(::Type{Interval}, t::Tuple) = setprecision(Interval, t...)
setprecision(::Type{FastInterval}, t::Tuple) = setprecision(Interval, t...)

precision(::Type{Interval}) = (parameters.precision_type, parameters.precision)
precision(::Type{FastInterval}) = (parameters.precision_type, parameters.precision)


const float_interval_pi = convert(Interval{Float64}, pi)  # does not change
const float_fastinterval_pi = convert(FastInterval{Float64}, pi)  # does not change

pi_interval(::Type{BigFloat}) = parameters.pi
pi_interval(::Type{Float64})  = float_interval_pi
pi_fastinterval(::Type{BigFloat}) = FastInterval(parameters.pi.lo, parameters.pi.hi)
pi_fastinterval(::Type{Float64})  = float_fastinterval_pi


function Base.setrounding{T}(f::Function, ::Type{Rational{T}},
    rounding_mode::RoundingMode)
    setrounding(f, float(Rational{T}), rounding_mode)
end



float{T}(x::Interval{T}) = convert( Interval{float(T)}, x)  # https://github.com/dpsanders/IntervalArithmetic.jl/issues/174
float{T}(x::FastInterval{T}) = convert( FastInterval{float(T)}, x)  # https://github.com/dpsanders/IntervalArithmetic.jl/issues/174

big(x::Interval) = convert(Interval{BigFloat}, x)
big(x::FastInterval) = convert(FastInterval{BigFloat}, x)
