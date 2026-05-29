<?php

namespace SemanticTypeForgers;

class AtomicBehavior {
    private $name;

    public function __construct($name) {
        $this->name = $name;
    }

    public function setSemanticType($v) {
        return $v;
    }

    public function getPrimitiveType($v) {
        return $v;
    }

    public function validate($value) {
        if ($this->name === 'PersonEmail') {
            $prim = $this->convertToPrimitive($value);
            if (is_string($prim)) {
                return (bool) preg_match('/^[a-zA-Z0-9_.+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-.]+$/', $prim);
            }
            return false;
        }
        return false;
    }

    private function normalizeString($val) {
        return strtolower(trim($val));
    }

    private function primitiveStringToValue($val) {
        $trimmed = trim($val);
        $lower = $this->normalizeString($val);

        if ($trimmed === "") return $val;
        if ($val === "{}" || $val === "[]") return 0;
        if ($lower === "true") return true;
        if ($lower === "false") return false;
        if ($lower === "null" || $lower === "undefined") return null;

        if (preg_match('/^[+-]?(?:(?:\d+\.?\d*)|(?:\.\d+))(?:e[+-]?\d+)?$/i', $trimmed)) {
            if (strpos($trimmed, '.') !== false || strpos($lower, 'e') !== false) {
                return (float)$trimmed;
            } else {
                return (int)$trimmed;
            }
        }

        return $val;
    }

    private function unwrap($val, &$seen, $depth) {
        if ($depth > 100) {
            throw new \Exception("convertToPrimitive: recursive unwrap limit exceeded");
        }

        if ($val === null) return null;

        if (is_bool($val) || is_int($val) || is_float($val)) return $val;

        if (is_string($val)) return $this->primitiveStringToValue($val);

        if (is_array($val)) {
            if (empty($val)) {
                if (array_keys($val) !== range(0, count($val) - 1)) {
                    return 0; // Assoc array / Object equivalent
                }
                return null;
            }
            return $this->unwrap(reset($val), $seen, $depth + 1);
        }

        if (is_object($val)) {
            $id = spl_object_id($val);
            if (isset($seen[$id])) {
                throw new \Exception("convertToPrimitive: circular reference detected");
            }
            $seen[$id] = true;

            if (method_exists($val, 'getPrimitiveType')) {
                return $this->unwrap($val->getPrimitiveType(), $seen, $depth + 1);
            }

            if ($val instanceof \DateTimeInterface) {
                return $val->getTimestamp() * 1000; // rough JS timestamp equivalent
            }

            $props = get_object_vars($val);
            if (empty($props)) return 0;

            return $this->unwrap(reset($props), $seen, $depth + 1);
        }

        return null;
    }

    public function convertToPrimitive($value) {
        $seen = [];
        return $this->unwrap($value, $seen, 0);
    }

    public function forge($v) {
        if ($this->name === 'PersonEmail' && !$this->validate($v)) {
            throw new \Exception("Validation failed for SemanticType: {$this->name}");
        }
        return $v;
    }

    public function proccessValue($value) {
        if ($this->validate($value)) return $value;

        if (is_array($value) && array_keys($value) !== range(0, count($value) - 1)) {
            $productPrice = $this->convertToPrimitive($value['productPrice'] ?? null);
            $productDiscount = $this->convertToPrimitive($value['productDiscount'] ?? null) ?: 0;
            $deliveryPrice = $this->convertToPrimitive($value['deliveryPrice'] ?? null) ?: 0;
            $paymentFees = $this->convertToPrimitive($value['paymentFees'] ?? null) ?: 0;

            if ($productPrice !== null && (is_int($productPrice) || is_float($productPrice))) {
                $finalPrice = $productPrice - $productDiscount + $deliveryPrice + $paymentFees;
                return $this->forge($finalPrice);
            }
        } elseif (is_object($value)) {
            $productPrice = $this->convertToPrimitive($value->productPrice ?? null);
            $productDiscount = $this->convertToPrimitive($value->productDiscount ?? null) ?: 0;
            $deliveryPrice = $this->convertToPrimitive($value->deliveryPrice ?? null) ?: 0;
            $paymentFees = $this->convertToPrimitive($value->paymentFees ?? null) ?: 0;

            if ($productPrice !== null && (is_int($productPrice) || is_float($productPrice))) {
                $finalPrice = $productPrice - $productDiscount + $deliveryPrice + $paymentFees;
                return $this->forge($finalPrice);
            }
        }

        $primitiveVal = $this->convertToPrimitive($value);
        return $this->forge($primitiveVal);
    }
}
