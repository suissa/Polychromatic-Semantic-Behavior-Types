use std::collections::HashMap;

#[derive(Debug, PartialEq, Clone)]
pub enum PrimitiveValue {
    String(String),
    Int(i64),
    Float(f64),
    Bool(bool),
    Null,
}

pub struct AtomicBehavior<T> {
    name: String,
    _marker: std::marker::PhantomData<T>,
}

impl<T> AtomicBehavior<T> {
    pub fn new(name: &str) -> Self {
        AtomicBehavior {
            name: name.to_string(),
            _marker: std::marker::PhantomData,
        }
    }

    pub fn get_primitive_type(&self, v: T) -> T {
        v
    }

    pub fn validate(&self, _value: &PrimitiveValue) -> bool {
        false
    }

    fn primitive_string_to_value(&self, val: &str) -> PrimitiveValue {
        let trimmed = val.trim();
        let lower = trimmed.to_lowercase();

        if trimmed.is_empty() {
            return PrimitiveValue::String(val.to_string());
        }
        if val == "{}" || val == "[]" {
            return PrimitiveValue::Int(0);
        }
        if lower == "true" {
            return PrimitiveValue::Bool(true);
        }
        if lower == "false" {
            return PrimitiveValue::Bool(false);
        }
        if lower == "null" || lower == "undefined" {
            return PrimitiveValue::Null;
        }

        let is_float = trimmed.contains('.') || lower.contains('e');
        if is_float {
            if let Ok(f) = trimmed.parse::<f64>() {
                return PrimitiveValue::Float(f);
            }
        } else if let Ok(i) = trimmed.parse::<i64>() {
            return PrimitiveValue::Int(i);
        }

        PrimitiveValue::String(val.to_string())
    }

    pub fn convert_to_primitive(&self, val: &PrimitiveValue) -> PrimitiveValue {
        match val {
            PrimitiveValue::String(s) => self.primitive_string_to_value(s),
            _ => val.clone(),
        }
    }

    pub fn forge(&self, v: T) -> T {
        v
    }

    // Process a hashmap containing standard order properties
    pub fn process_value_map(&self, map: &HashMap<&str, PrimitiveValue>) -> PrimitiveValue {
        let get_val = |key: &str| -> f64 {
            if let Some(v) = map.get(key) {
                match self.convert_to_primitive(v) {
                    PrimitiveValue::Float(f) => f,
                    PrimitiveValue::Int(i) => i as f64,
                    _ => 0.0,
                }
            } else {
                0.0
            }
        };

        if map.contains_key("productPrice") {
            let p_price = get_val("productPrice");
            let p_discount = get_val("productDiscount");
            let d_price = get_val("deliveryPrice");
            let p_fees = get_val("paymentFees");

            return PrimitiveValue::Float(p_price - p_discount + d_price + p_fees);
        }

        PrimitiveValue::Null
    }
}
