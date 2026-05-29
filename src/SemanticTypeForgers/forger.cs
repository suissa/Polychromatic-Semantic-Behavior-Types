using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;

namespace SemanticTypeForgers
{
    public class Forger
    {
        public class AtomicBehavior<T>
        {
            private string name;

            public AtomicBehavior(string name)
            {
                this.name = name;
            }

            public T GetPrimitiveType(T v)
            {
                return v;
            }

            public bool Validate(object value)
            {
                return false;
            }

            private object PrimitiveStringToValue(string val)
            {
                string trimmed = val.Trim();
                string lower = trimmed.ToLower();

                if (string.IsNullOrEmpty(trimmed)) return val;
                if (val == "{}" || val == "[]") return 0;
                if (lower == "true") return true;
                if (lower == "false") return false;
                if (lower == "null" || lower == "undefined") return null;

                if (Regex.IsMatch(trimmed, @"^[+-]?(?:(?:\d+\.?\d*)|(?:\.\d+))(?:e[+-]?\d+)?$", RegexOptions.IgnoreCase))
                {
                    if (trimmed.Contains(".") || lower.Contains("e"))
                    {
                        if (double.TryParse(trimmed, out double d)) return d;
                    }
                    else
                    {
                        if (long.TryParse(trimmed, out long l)) return l;
                    }
                }

                return val;
            }

            private object Unwrap(object val, HashSet<int> seen, int depth)
            {
                if (depth > 100) throw new Exception("convertToPrimitive: recursive unwrap limit exceeded");
                if (val == null) return null;

                if (val is int || val is long || val is double || val is bool) return val;
                if (val is string s) return PrimitiveStringToValue(s);

                // Collections handling could be added here
                return null; // simplification
            }

            public object ConvertToPrimitive(object value)
            {
                try
                {
                    return Unwrap(value, new HashSet<int>(), 0);
                }
                catch
                {
                    return null;
                }
            }

            public T Forge(T v)
            {
                return v;
            }

            public T ProcessValue(object value)
            {
                if (Validate(value)) return (T)value;

                if (value is Dictionary<string, object> obj)
                {
                    double GetVal(string key)
                    {
                        if (obj.TryGetValue(key, out var v))
                        {
                            var p = ConvertToPrimitive(v);
                            if (p is IConvertible c) return c.ToDouble(null);
                        }
                        return 0;
                    }

                    double pPrice = GetVal("productPrice");
                    double pDiscount = GetVal("productDiscount");
                    double dPrice = GetVal("deliveryPrice");
                    double pFees = GetVal("paymentFees");

                    if (obj.ContainsKey("productPrice"))
                    {
                        double finalPrice = pPrice - pDiscount + dPrice + pFees;
                        return Forge((T)Convert.ChangeType(finalPrice, typeof(T)));
                    }
                }

                object primitiveVal = ConvertToPrimitive(value);
                return Forge((T)Convert.ChangeType(primitiveVal, typeof(T)));
            }
        }
    }
}
