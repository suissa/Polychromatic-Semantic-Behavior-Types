local forger = {}

function forger.AtomicBehavior(name)
    local self = {}
    self.name = name

    function self.setSemanticType(v)
        return v
    end

    function self.getPrimitiveType(v)
        return v
    end

    function self.validate(value)
        return false
    end

    local function normalizeString(val)
        return val:match("^%s*(.-)%s*$"):lower()
    end

    local function primitiveStringToValue(val)
        local trimmed = val:match("^%s*(.-)%s*$")
        local lower = normalizeString(val)

        if trimmed == "" then return val end
        if val == "{}" or val == "[]" then return 0 end
        if lower == "true" then return true end
        if lower == "false" then return false end
        if lower == "null" or lower == "undefined" then return nil end

        if trimmed:match("^[+-]?(%d+%.?%d*e?[+-]?%d*)$") or trimmed:match("^[+-]?(%.%d+e?[+-]?%d*)$") then
            local num = tonumber(trimmed)
            if num then return num end
        end

        return val
    end

    local function unwrap(val, seen, depth)
        seen = seen or {}
        depth = depth or 0

        if depth > 100 then
            error("convertToPrimitive: recursive unwrap limit exceeded")
        end

        if val == nil then return nil end

        local t = type(val)
        if t == "number" or t == "boolean" then return val end
        if t == "string" then return primitiveStringToValue(val) end

        if t == "table" then
            if next(val) == nil then
                -- Lua doesn't distinguish between {} and [], using 0 as per logic
                return 0
            end

            -- Circular reference check for tables
            if seen[val] then
                error("convertToPrimitive: circular reference detected")
            end
            seen[val] = true

            if val.getPrimitiveType and type(val.getPrimitiveType) == "function" then
                return unwrap(val:getPrimitiveType(), seen, depth + 1)
            end

            -- Return first value
            for _, v in pairs(val) do
                return unwrap(v, seen, depth + 1)
            end
        end

        return nil
    end

    function self.convertToPrimitive(value)
        local status, res = pcall(unwrap, value)
        if status then
            return res
        else
            return nil
        end
    end

    function self.forge(v)
        return v
    end

    function self.proccessValue(value)
        if self.validate(value) then return value end

        if type(value) == "table" then
            local productPrice = self.convertToPrimitive(value.productPrice)
            local productDiscount = self.convertToPrimitive(value.productDiscount) or 0
            local deliveryPrice = self.convertToPrimitive(value.deliveryPrice) or 0
            local paymentFees = self.convertToPrimitive(value.paymentFees) or 0

            if productPrice ~= nil and type(productPrice) == "number" then
                local finalPrice = productPrice - productDiscount + deliveryPrice + paymentFees
                return self.forge(finalPrice)
            end
        end

        local primitiveVal = self.convertToPrimitive(value)
        return self.forge(primitiveVal)
    end

    return self
end

return forger
