defmodule SemanticTypeForgers.Forger do
  defmodule AtomicBehavior do
    def new(name) do
      %{name: name}
    end

    def set_semantic_type(v), do: v
    def get_primitive_type(v), do: v
    def validate(behavior, value) do
      if behavior.name == "PersonEmail" do
        prim = convert_to_primitive(value)
        if is_binary(prim) do
          Regex.match?(~r/^[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+$/, prim)
        else
          false
        end
      else
        false
      end
    end

    def primitive_string_to_value(val) do
      trimmed = String.trim(val)
      lower = String.downcase(trimmed)

      cond do
        trimmed == "" -> val
        val == "{}" or val == "[]" -> 0
        lower == "true" -> true
        lower == "false" -> false
        lower == "null" or lower == "undefined" -> nil
        true ->
          if Regex.match?(~r/^[+-]?(?:(?:\d+\.?\d*)|(?:\.\d+))(?:e[+-]?\d+)?$/i, trimmed) do
            if String.contains?(trimmed, ".") or String.contains?(lower, "e") do
              {f, _} = Float.parse(trimmed)
              f
            else
              {i, _} = Integer.parse(trimmed)
              i
            end
          else
            val
          end
      end
    end

    def unwrap(val, _seen \\ MapSet.new(), depth \\ 0) do
      if depth > 100 do
        raise "convertToPrimitive: recursive unwrap limit exceeded"
      end

      cond do
        is_nil(val) -> nil
        is_integer(val) or is_float(val) or is_boolean(val) -> val
        is_binary(val) -> primitive_string_to_value(val)
        is_list(val) ->
          if length(val) == 0, do: nil, else: unwrap(hd(val), _seen, depth + 1)
        is_map(val) ->
          if map_size(val) == 0 do
            0
          else
            [first | _] = Map.values(val)
            unwrap(first, _seen, depth + 1)
          end
        true -> nil
      end
    end

    def convert_to_primitive(value) do
      try do
        unwrap(value)
      rescue
        _ -> nil
      end
    end

    def forge(behavior, v) do
      if behavior.name == "PersonEmail" and not validate(behavior, v) do
        raise "Validation failed for SemanticType: #{behavior.name}"
      end
      v
    end

    def proccess_value(behavior, value) do
      if validate(behavior, value) do
        value
      else
        if is_map(value) and map_size(value) > 0 and (Map.has_key?(value, "productPrice") or Map.has_key?(value, :productPrice)) do
          p_price = convert_to_primitive(Map.get(value, "productPrice") || Map.get(value, :productPrice))
          p_discount = convert_to_primitive(Map.get(value, "productDiscount") || Map.get(value, :productDiscount)) || 0
          d_price = convert_to_primitive(Map.get(value, "deliveryPrice") || Map.get(value, :deliveryPrice)) || 0
          p_fees = convert_to_primitive(Map.get(value, "paymentFees") || Map.get(value, :paymentFees)) || 0

          if is_number(p_price) do
            forge(behavior, p_price - p_discount + d_price + p_fees)
          else
            forge(behavior, convert_to_primitive(value))
          end
        else
          forge(behavior, convert_to_primitive(value))
        end
      end
    end
  end
end
