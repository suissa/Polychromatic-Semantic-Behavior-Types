#include "forger.hpp"
#include <iostream>
#include <cassert>

using namespace SemanticTypeForgers;

int main() {
    AtomicBehavior<int> intBehavior("testInt");

    assert(intBehavior.getPrimitiveType(5) == 5);

    PrimitiveType r1 = intBehavior.convertToPrimitive(" 123 ");
    assert(std::holds_alternative<int>(r1) && std::get<int>(r1) == 123);

    PrimitiveType r2 = intBehavior.convertToPrimitive("true");
    assert(std::holds_alternative<bool>(r2) && std::get<bool>(r2) == true);

    PrimitiveType r3 = intBehavior.convertToPrimitive("{}");
    assert(std::holds_alternative<int>(r3) && std::get<int>(r3) == 0);

    AtomicBehavior<double> doubleBehavior("testDouble");
    PrimitiveType r4 = doubleBehavior.convertToPrimitive("10.5");
    assert(std::holds_alternative<double>(r4) && std::get<double>(r4) == 10.5);

    AtomicBehavior<std::string> emailBehavior("PersonEmail");
    assert(emailBehavior.validate("test@example.com") == true);
    assert(emailBehavior.validate("invalid-email") == false);

    std::cout << "C++ tests passed" << std::endl;
    return 0;
}
