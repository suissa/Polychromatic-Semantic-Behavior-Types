package SemanticTypeForgers;

import java.util.HashMap;
import java.util.Map;

public class forger_tests {
    public static void main(String[] args) {
        forger.AtomicBehavior<Object> behavior = new forger.AtomicBehavior<>("test");

        if (!behavior.getPrimitiveType(5).equals(5)) {
            throw new RuntimeException("Test Failed");
        }

        if (!behavior.convertToPrimitive(" 123 ").equals(123L)) {
            throw new RuntimeException("Test Failed");
        }

        if (!behavior.convertToPrimitive("true").equals(true)) {
            throw new RuntimeException("Test Failed");
        }

        Map<String, Object> map = new HashMap<>();
        map.put("productPrice", "10.5");
        map.put("deliveryPrice", 2.5);

        Object val = behavior.proccessValue(map);
        if (!val.equals(13.0)) {
            throw new RuntimeException("Test Failed: expected 13.0 got " + val);
        }

        forger.AtomicBehavior<Object> emailBehavior = new forger.AtomicBehavior<>("PersonEmail");
        if (!emailBehavior.validate("test@example.com")) {
            throw new RuntimeException("Test Failed: valid email not validated");
        }
        if (emailBehavior.validate("invalid-email")) {
            throw new RuntimeException("Test Failed: invalid email validated");
        }

        try {
            emailBehavior.forge("invalid-email");
            throw new RuntimeException("Test Failed: Should have thrown validation exception");
        } catch (Exception e) {
            if (!e.getMessage().contains("Validation failed")) {
                throw new RuntimeException("Test Failed: Wrong exception thrown: " + e.getMessage());
            }
        }

        System.out.println("Java tests passed");
    }
}
