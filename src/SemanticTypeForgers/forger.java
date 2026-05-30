package SemanticTypeForgers;

import java.util.Map;
import java.util.regex.Pattern;
import java.util.Set;
import java.util.HashSet;
import java.util.List;
import java.util.Date;
import java.util.Collection;

public class forger {

    public static class AtomicBehavior<T> {
        private String name;

        public AtomicBehavior(String name) {
            this.name = name;
        }

        public T setSemanticType(T v) {
            return v;
        }

        public T getPrimitiveType(T v) {
            return v;
        }

        public boolean validate(Object value) {
            if ("PersonEmail".equals(this.name)) {
                Object prim = convertToPrimitive(value);
                if (prim instanceof String) {
                    return Pattern.matches("^[a-zA-Z0-9_.+\\-]+@[a-zA-Z0-9\\-]+\\.[a-zA-Z0-9\\-.]+$", (String) prim);
                }
                return false;
            }
            return false;
        }

        private Object primitiveStringToValue(String val) {
            String trimmed = val.trim();
            String lower = trimmed.toLowerCase();

            if (trimmed.isEmpty()) return val;
            if (val.equals("{}") || val.equals("[]")) return 0;
            if (lower.equals("true")) return true;
            if (lower.equals("false")) return false;
            if (lower.equals("null") || lower.equals("undefined")) return null;

            Pattern pattern = Pattern.compile("^[+-]?(?:(?:\\d+\\.?\\d*)|(?:\\.\\d+))(?:e[+-]?\\d+)?$", Pattern.CASE_INSENSITIVE);
            if (pattern.matcher(trimmed).matches()) {
                try {
                    if (trimmed.contains(".") || lower.contains("e")) {
                        return Double.parseDouble(trimmed);
                    }
                    return Long.parseLong(trimmed);
                } catch (NumberFormatException e) {
                    // Fallthrough
                }
            }

            return val;
        }

        private Object unwrap(Object val, Set<Integer> seen, int depth) throws Exception {
            if (depth > 100) {
                throw new Exception("convertToPrimitive: recursive unwrap limit exceeded");
            }

            if (val == null) return null;

            if (val instanceof Number || val instanceof Boolean) {
                return val;
            }

            if (val instanceof String) {
                return primitiveStringToValue((String) val);
            }

            if (val instanceof Collection) {
                Collection<?> c = (Collection<?>) val;
                if (c.isEmpty()) return null;
                return unwrap(c.iterator().next(), seen, depth + 1);
            }

            if (val instanceof Map) {
                Map<?, ?> map = (Map<?, ?>) val;
                if (map.isEmpty()) return 0;
                return unwrap(map.values().iterator().next(), seen, depth + 1);
            }

            if (val instanceof Date) {
                return ((Date) val).getTime();
            }

            // Primitive arrays, objects, circular reference detection
            int id = System.identityHashCode(val);
            if (seen.contains(id)) {
                throw new Exception("convertToPrimitive: circular reference detected");
            }
            seen.add(id);

            // Assume the object doesn't have a getPrimitiveType in simple Java translation unless explicitly interfaced.
            // Simplified return null for unknown complex objects to match JS loosely
            return null;
        }

        public Object convertToPrimitive(Object value) {
            try {
                return unwrap(value, new HashSet<>(), 0);
            } catch (Exception e) {
                return null;
            }
        }

        public T forge(T v) {
            if ("PersonEmail".equals(this.name) && !validate(v)) {
                throw new RuntimeException("Validation failed for SemanticType: " + this.name);
            }
            return v;
        }

        @SuppressWarnings("unchecked")
        public T proccessValue(Object value) {
            if (validate(value)) {
                return (T) value;
            }

            if (value != null && value instanceof Map) {
                Map<String, Object> obj = (Map<String, Object>) value;
                Object pPrice = convertToPrimitive(obj.get("productPrice"));
                Object pDiscount = convertToPrimitive(obj.get("productDiscount"));
                Object dPrice = convertToPrimitive(obj.get("deliveryPrice"));
                Object pFees = convertToPrimitive(obj.get("paymentFees"));

                double discount = (pDiscount instanceof Number) ? ((Number) pDiscount).doubleValue() : 0.0;
                double delivery = (dPrice instanceof Number) ? ((Number) dPrice).doubleValue() : 0.0;
                double fees = (pFees instanceof Number) ? ((Number) pFees).doubleValue() : 0.0;

                if (pPrice instanceof Number) {
                    double price = ((Number) pPrice).doubleValue();
                    double finalPrice = price - discount + delivery + fees;
                    return forge((T) Double.valueOf(finalPrice));
                }
            }

            Object primitiveVal = convertToPrimitive(value);
            return forge((T) primitiveVal);
        }
    }
}
