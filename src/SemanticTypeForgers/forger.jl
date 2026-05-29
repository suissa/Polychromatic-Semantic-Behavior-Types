module Forger

export AtomicBehavior

struct AtomicBehavior{T}
    name::String
end

function getPrimitiveType(b::AtomicBehavior{T}, v::T) where T
    return v
end

function validate(b::AtomicBehavior, value)
    return false
end

function primitiveStringToValue(val::String)
    trimmed = strip(val)
    lower = lowercase(trimmed)

    if isempty(trimmed)
        return val
    end
    if val == "{}" || val == "[]"
        return 0
    end
    if lower == "true"
        return true
    end
    if lower == "false"
        return false
    end
    if lower == "null" || lower == "undefined"
        return nothing
    end

    if occursin(r"^[+-]?(?:(?:\d+\.?\d*)|(?:\.\d+))(?:e[+-]?\d+)?$"i, trimmed)
        if occursin(".", trimmed) || occursin("e", lower)
            try
                return parse(Float64, trimmed)
            catch
            end
        else
            try
                return parse(Int64, trimmed)
            catch
            end
        end
    end

    return val
end

function unwrap(val, seen=Set{UInt64}(), depth=0)
    if depth > 100
        error("convertToPrimitive: recursive unwrap limit exceeded")
    end

    if val === nothing
        return nothing
    end

    if typeof(val) <: Union{Int, Float64, Bool}
        return val
    end

    if typeof(val) == String
        return primitiveStringToValue(val)
    end

    if typeof(val) <: Array || typeof(val) <: Tuple
        if isempty(val)
            return nothing
        end
        return unwrap(first(val), seen, depth + 1)
    end

    if typeof(val) <: AbstractDict
        if isempty(val)
            return 0
        end
        return unwrap(first(values(val)), seen, depth + 1)
    end

    return nothing
end

function convertToPrimitive(b::AtomicBehavior, value)
    try
        return unwrap(value)
    catch
        return nothing
    end
end

function forge(b::AtomicBehavior{T}, v::T) where T
    return v
end

function proccessValue(b::AtomicBehavior{T}, value) where T
    if validate(b, value)
        return value
    end

    if typeof(value) <: AbstractDict
        pPrice = convertToPrimitive(b, get(value, "productPrice", nothing))
        pDiscount = convertToPrimitive(b, get(value, "productDiscount", nothing))
        dPrice = convertToPrimitive(b, get(value, "deliveryPrice", nothing))
        pFees = convertToPrimitive(b, get(value, "paymentFees", nothing))

        pDiscount = pDiscount === nothing ? 0 : pDiscount
        dPrice = dPrice === nothing ? 0 : dPrice
        pFees = pFees === nothing ? 0 : pFees

        if pPrice !== nothing && typeof(pPrice) <: Number
            finalPrice = pPrice - pDiscount + dPrice + pFees
            return forge(b, convert(T, finalPrice))
        end
    end

    prim = convertToPrimitive(b, value)
    if prim !== nothing
        try
            return forge(b, convert(T, prim))
        catch
        end
    end

    # Return nothing equivalent roughly depending on T, typically test handles union types or Any
    return prim
end

end
