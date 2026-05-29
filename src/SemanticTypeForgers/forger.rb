module SemanticTypeForgers
  class AtomicBehavior
    def initialize(name)
      @name = name
    end

    def setSemanticType(v)
      v
    end

    def getPrimitiveType(v)
      v
    end

    def validate(value)
      false
    end

    def primitiveStringToValue(val)
      trimmed = val.strip
      lower = trimmed.downcase

      return val if trimmed.empty?
      return 0 if val == "{}" || val == "[]"
      return true if lower == "true"
      return false if lower == "false"
      return nil if lower == "null" || lower == "undefined"

      if trimmed.match?(/^[+-]?(?:(?:\d+\.?\d*)|(?:\.\d+))(?:e[+-]?\d+)?$/i)
        if trimmed.include?(".") || lower.include?("e")
          return trimmed.to_f
        else
          return trimmed.to_i
        end
      end

      val
    end

    def unwrap(val, seen, depth)
      raise "convertToPrimitive: recursive unwrap limit exceeded" if depth > 100

      return nil if val.nil?
      return val if val.is_a?(Integer) || val.is_a?(Float) || val.is_a?(TrueClass) || val.is_a?(FalseClass)
      return primitiveStringToValue(val) if val.is_a?(String)

      if val.is_a?(Array)
        return nil if val.empty?
        return unwrap(val.first, seen, depth + 1)
      end

      if val.is_a?(Hash)
        return 0 if val.empty?
        return unwrap(val.values.first, seen, depth + 1)
      end

      if val.is_a?(Time) || val.is_a?(Date)
        return val.to_time.to_i * 1000
      end

      raise "convertToPrimitive: circular reference detected" if seen.include?(val.object_id)
      seen.add(val.object_id)

      if val.respond_to?(:getPrimitiveType)
        return unwrap(val.getPrimitiveType, seen, depth + 1)
      end

      nil
    end

    def convertToPrimitive(value)
      unwrap(value, Set.new, 0)
    rescue
      nil
    end

    def forge(v)
      v
    end

    def proccessValue(value)
      return value if validate(value)

      if value.is_a?(Hash)
        product_price = convertToPrimitive(value["productPrice"] || value[:productPrice])
        product_discount = convertToPrimitive(value["productDiscount"] || value[:productDiscount]) || 0
        delivery_price = convertToPrimitive(value["deliveryPrice"] || value[:deliveryPrice]) || 0
        payment_fees = convertToPrimitive(value["paymentFees"] || value[:paymentFees]) || 0

        if product_price.is_a?(Numeric)
          final_price = product_price - product_discount + delivery_price + payment_fees
          return forge(final_price)
        end
      end

      primitive_val = convertToPrimitive(value)
      forge(primitive_val)
    end
  end
end
