import re
from datetime import datetime

def AtomicBehavior(name):
    def getPrimitiveType(v):
        return v

    def validate(value):
        return False

    def convertToPrimitive(value):
        def normalizeString(val):
            return val.strip().lower()

        def primitiveStringToValue(val):
            trimmed = val.strip()
            lower = normalizeString(val)

            if trimmed == "":
                return val
            if val == "{}" or val == "[]":
                return 0
            if lower == "true":
                return True
            if lower == "false":
                return False
            if lower == "null":
                return None
            if lower == "undefined":
                return None

            isNumberLike = re.match(r'^[+-]?(?:(?:\d+\.?\d*)|(?:\.\d+))(?:e[+-]?\d+)?$', trimmed, re.IGNORECASE)
            if isNumberLike:
                try:
                    if '.' in trimmed or 'e' in trimmed.lower():
                        return float(trimmed)
                    return int(trimmed)
                except ValueError:
                    pass
            return val

        def unwrap(val, seen=None, depth=0):
            if seen is None:
                seen = set()

            if depth > 100:
                raise Exception("convertToPrimitive: recursive unwrap limit exceeded")

            if val is None:
                return val

            if not val and not isinstance(val, (dict, list, set, tuple, object)) and type(val) not in (int, float, bool, str):
                return val

            if type(val) in (int, float, bool):
                return val

            if isinstance(val, str):
                return primitiveStringToValue(val)

            if callable(val):
                return unwrap(val(), seen, depth + 1)

            if isinstance(val, (list, tuple)):
                if len(val) == 0:
                    return None
                return unwrap(val[0], seen, depth + 1)

            if isinstance(val, dict):
                if not val:
                    return 0
                values = list(val.values())
                if len(values) == 0:
                    return None
                return unwrap(values[0], seen, depth + 1)

            if hasattr(val, "__class__") and val.__class__.__name__ not in ("int", "float", "str", "bool", "list", "dict", "tuple", "set", "NoneType"):
                if id(val) in seen:
                    raise Exception("convertToPrimitive: circular reference detected")
                seen.add(id(val))

                if hasattr(val, "getPrimitiveType") and callable(getattr(val, "getPrimitiveType")):
                    return unwrap(val.getPrimitiveType(), seen, depth + 1)

                if isinstance(val, datetime):
                    return unwrap(val.timestamp() * 1000, seen, depth + 1)

                if hasattr(val, "__dict__"):
                    props = [v for k, v in val.__dict__.items() if not k.startswith('_')]
                    if not props:
                        return 0
                    return unwrap(props[0], seen, depth + 1)

            return None

        return unwrap(value)

    def forge(v):
        return v

    def proccessValue(value):
        if validate(value):
            return value

        if value is not None and isinstance(value, dict):
            obj = value
            productPrice = convertToPrimitive(obj.get("productPrice"))
            productDiscount = convertToPrimitive(obj.get("productDiscount")) or 0
            deliveryPrice = convertToPrimitive(obj.get("deliveryPrice")) or 0
            paymentFees = convertToPrimitive(obj.get("paymentFees")) or 0

            if productPrice is not None and isinstance(productPrice, (int, float)):
                finalPrice = productPrice - productDiscount + deliveryPrice + paymentFees
                return forge(finalPrice)
        elif value is not None and hasattr(value, "__dict__"):
            productPrice = convertToPrimitive(getattr(value, "productPrice", None))
            productDiscount = convertToPrimitive(getattr(value, "productDiscount", None)) or 0
            deliveryPrice = convertToPrimitive(getattr(value, "deliveryPrice", None)) or 0
            paymentFees = convertToPrimitive(getattr(value, "paymentFees", None)) or 0

            if productPrice is not None and isinstance(productPrice, (int, float)):
                finalPrice = productPrice - productDiscount + deliveryPrice + paymentFees
                return forge(finalPrice)

        primitiveVal = convertToPrimitive(value)
        return forge(primitiveVal)

    return {
        "setSemanticType": lambda v: v,
        "getPrimitiveType": getPrimitiveType,
        "validate": validate,
        "convertToPrimitive": convertToPrimitive,
        "forge": forge,
        "proccessValue": proccessValue,
    }
