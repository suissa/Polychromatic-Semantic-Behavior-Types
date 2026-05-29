using System;
using System.Collections.Generic;

namespace SemanticTypeForgers
{
    class ForgerTests
    {
        static void Main(string[] args)
        {
            var behavior = new Forger.AtomicBehavior<object>("test");

            if (!behavior.GetPrimitiveType(5).Equals(5)) throw new Exception("Test failed");
            if (!behavior.ConvertToPrimitive(" 123 ").Equals(123L)) throw new Exception("Test failed");
            if (!behavior.ConvertToPrimitive("true").Equals(true)) throw new Exception("Test failed");
            if (!behavior.ConvertToPrimitive("{}").Equals(0)) throw new Exception("Test failed");

            var map = new Dictionary<string, object>
            {
                { "productPrice", "10.5" },
                { "deliveryPrice", 2.5 }
            };

            var val = behavior.ProcessValue(map);
            if (!val.Equals(13.0)) throw new Exception($"Test failed: Expected 13.0 got {val}");

            Console.WriteLine("C# tests passed");
        }
    }
}
