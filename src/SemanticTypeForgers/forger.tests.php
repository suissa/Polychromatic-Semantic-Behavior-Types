<?php

require_once __DIR__ . '/forger.php';

use SemanticTypeForgers\AtomicBehavior;

$behavior = new AtomicBehavior("test");

if ($behavior->getPrimitiveType(5) !== 5) throw new Exception("Test failed");
if ($behavior->convertToPrimitive(" 123 ") !== 123) throw new Exception("Test failed");
if ($behavior->convertToPrimitive("true") !== true) throw new Exception("Test failed");
if ($behavior->convertToPrimitive("{}") !== 0) throw new Exception("Test failed");

$val = $behavior->proccessValue([
    "productPrice" => "10.5",
    "deliveryPrice" => 2.5
]);

if ($val !== 13.0) throw new Exception("Test failed: expected 13.0 got " . $val);

$emailBehavior = new AtomicBehavior("PersonEmail");
if ($emailBehavior->validate("test@example.com") !== true) throw new Exception("Test failed: valid email");
if ($emailBehavior->validate("invalid-email") !== false) throw new Exception("Test failed: invalid email");

try {
    $emailBehavior->forge("invalid-email");
    throw new Exception("Test failed: should have thrown on invalid forge");
} catch (Exception $e) {
    if (strpos($e->getMessage(), "Validation failed") === false) {
        throw $e;
    }
}

echo "PHP tests passed\n";
