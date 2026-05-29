declare const __SemanticType: unique symbol;

type PrimitiveUnwrapped =
| string
| number
| boolean
| null
| undefined;

export type SemanticType<T, Name extends string> = T & { readonly [__SemanticType]: Name };

export function AtomicBehavior<Name extends string>() {
  const getPrimitiveType = <T>(v: SemanticType<T, Name>): T => v as unknown as T;

  const validate = <T>(value: unknown): value is SemanticType<T, Name> => {
    // "Desempacota" o valor estaticamente para permitir testes com typeof
    const _unpacked = value as T;
    
    // @ts-ignore
    if (typeof `${value}` === `${T}`) {
      // implement here
    }

    return false;
  };

  // a função convertToPrimitive precisa ser recursiva até receber 1 valor primitivo de primeira ordem
  const convertToPrimitive = (value: unknown): PrimitiveUnwrapped => {
    const primitiveStringToValue = (val: string): PrimitiveUnwrapped => {
      const trimmed = val.trim();
      const lower = trimmed.toLowerCase();

      // string vazia é falsy, então para aqui
      if (trimmed === "") return val;

      // boolean primitives
      if (lower === "true") return true;
      if (lower === "false") return false;

      // nullish primitives
      if (lower === "null") return null;
      if (lower === "undefined") return undefined;

      // number primitive
      // aceita: "1", "-1", "1.5", ".5", "1e3", "-1.2e-3"
      // não aceita: "abc1", "1abc", "true false"
      const isNumberLike =
        /^[+-]?(?:(?:\d+\.?\d*)|(?:\.\d+))(?:e[+-]?\d+)?$/i.test(trimmed);

      if (isNumberLike) {
        return Number(trimmed);
      }

      // Se a string não contém EXATAMENTE um valor primitivo,
      // ela permanece string.
      return val;
    };

    const unwrap = (
      val: unknown,
      seen = new WeakSet<object>(),
      depth = 0,
    ): PrimitiveUnwrapped => {
      if (depth > 100) {
        throw new Error("convertToPrimitive: recursive unwrap limit exceeded");
      }

      // nullish
      if (val === null || val === undefined) return val;

      // falsy primitives: false, 0, "", NaN
      if (!val && typeof val !== "object") {
        return val as PrimitiveUnwrapped;
      }

      switch (typeof val) {
        case "number":
        case "boolean":
          return val;

        case "string":
          return primitiveStringToValue(val);

        case "bigint":
          return Number(val);

        case "symbol":
          return String(val);

        case "function":
          return unwrap(val(), seen, depth + 1);

        case "object": {
          const obj = val as any;

          if (seen.has(obj)) {
            throw new Error("convertToPrimitive: circular reference detected");
          }

          seen.add(obj);

          // Suporte para objetos/classes que sabem devolver seu valor primitivo
          if (typeof obj.getPrimitiveType === "function") {
            return unwrap(obj.getPrimitiveType(), seen, depth + 1);
          }

          // Suporte para Symbol.toPrimitive
          if (typeof obj[Symbol.toPrimitive] === "function") {
            return unwrap(obj[Symbol.toPrimitive]("default"), seen, depth + 1);
          }

          // Wrappers nativos: new Number(1), new Boolean(false), new String("1")
          if (
            obj instanceof Number ||
            obj instanceof Boolean ||
            obj instanceof String
          ) {
            return unwrap(obj.valueOf(), seen, depth + 1);
          }

          // Date vira number timestamp
          if (obj instanceof Date) {
            return unwrap(obj.getTime(), seen, depth + 1);
          }

          // RegExp vira string
          if (obj instanceof RegExp) {
            return unwrap(obj.toString(), seen, depth + 1);
          }

          // Array: pega o primeiro valor semanticamente disponível
          if (Array.isArray(obj)) {
            if (obj.length === 0) return undefined;
            return unwrap(obj[0], seen, depth + 1);
          }

          // Objeto comum: pega o primeiro valor
          const values = Object.values(obj);

          if (values.length === 0) return undefined;

          return unwrap(values[0], seen, depth + 1);
        }

        default:
          return undefined;
      }
    };

    return unwrap(value);
  };

  const forge = <T>(v: T): SemanticType<T, Name> => {
    if (!validate<T>(v)) {
      throw new Error(`Validation failed for SemanticType: ${Name}`);
    }
    return v as SemanticType<T, Name>;
  };
  
  const proccessValue = <T>(value: unknown): SemanticType<T, Name> => {
    if (validate<T>(value)) {
      return value;
    }
    
    if (value !== null && typeof value === "object") {
      const obj = value as any;
      const productPrice = convertToPrimitive(obj.productPrice);
      const productDiscount = convertToPrimitive(obj.productDiscount) || 0;
      const deliveryPrice = convertToPrimitive(obj.deliveryPrice) || 0;
      const paymentFees = convertToPrimitive(obj.paymentFees) || 0;

      // Se for um cálculo de preço de pedido (OrderPrice)
      if (productPrice !== undefined && typeof productPrice === "number") {
        const finalPrice = productPrice - productDiscount + deliveryPrice + paymentFees;
        return forge(finalPrice as unknown as T);
      }
    }
    
    // Processamento padrão (extrai o primitivo do envelope se necessário)
    const primitiveVal = convertToPrimitive(value);
    return forge(primitiveVal as unknown as T);
  };

  return {
    setSemanticType: <T>(v: T) => v as SemanticType<T, Name>,
    getPrimitiveType,
    validate,
    convertToPrimitive,
    forge,
    proccessValue,
  };
}

// Exemplo de teste de tipagem estática (Compile-time Type Verification)
type Assert<T, Expected> = T extends Expected ? (Expected extends T ? true : false) : false;
type TestUnwrap = Assert<ReturnType<typeof AtomicBehavior<"test">["getPrimitiveType"]>, unknown>; // true
