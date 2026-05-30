# Semantic Behavior Types - standard-lib

1. valor semântico;
2. tipo semântico primitivo;
3. comportamento global;
4. comportamento local de entidade;
5. comportamento relacional entre entidades;
6. comportamento associado a Plane;
7. comportamento de validação/refutação;
8. comportamento de normalização/canonicalização.

A regra principal que eu recomendo é esta:

```txt
PascalCase(...)      = comportamento global da standard-lib
{Entity}.camelCase() = comportamento local da entidade
{Entity}.{Property}.camelCase = comportamento local de propriedade
{EntitySource}.camelCase({EntityGoal}) = comportamento relacional entre entidades
PlaneBehavior(...)   = comportamento global relacionado a Plane
```

Então:

```txt
LengthBetween(10, 13)
IsVector(User)
IsGraph(Order)
IsLog(Payment)
IsUnique(UserEmail)
```

são globais.

Mas:

```txt
User.isValidFor(Order)
Order.has(OrderItems)
User.email.exists
Product.stock.isAvailableFor(OrderItem)
```

são locais, porque dependem da semântica interna da entidade ou da relação entre entidades.

---

# 1. Convenção de nomes da standard-lib

## 1.1 Valores semânticos

Valores semânticos são substantivos canônicos. Devem ser `PascalCase`.

Exemplos:

```txt
EmptyValue
NullValue
UndefinedValue
MissingValue
InvalidValue
UnknownValue
RawValue
CanonicalValue
NormalizedValue
```

Eles não são comportamentos. Eles representam estados semânticos possíveis de um valor.

Exemplo:

```txt
UserPhone ⊣ EmptyValue
UserEmail ⊣ InvalidValue
UserCPF ⊢ CanonicalValue
```

---

## 1.2 Tipos semânticos primitivos

Também usam `PascalCase`.

Exemplos:

```txt
Word
Number
Integer
Decimal
Boolean
Text
Symbol
Token
Identifier
Array
Object
Set
Map
Tuple
Graph
Vector
Log
Event
Trace
Timestamp
DateTime
Money
Email
CPF
Phone
URL
UUID
Hash
Signature
Proof
```

Exemplo:

```txt
UserPhone ⊢ Word(Number)
UserEmail ⊢ Word(Email)
OrderItems ⊢ Array(OrderItem)
OrderTrace ⊢ Trace(Event)
EntityEmbedding ⊢ Vector(Number)
```

---

## 1.3 Comportamentos globais

Comportamentos globais usam `PascalCase(...)`.

Eles não pertencem a uma entidade específica.

Exemplos:

```txt
LengthBetween(10, 13)
GreaterThan(0)
LessThan(100)
IsUnique(UserEmail)
IsVector(User)
IsGraph(Order)
IsLog(Payment)
IsTrace(Order)
IsEvent(UserCreated)
IsCanonical(UserCPF)
IsNormalized(UserPhone)
IsSigned(OrderProof)
```

Fórmula:

```txt
UserPhone ⊢ Word(Number) ∧ LengthBetween(10, 13)
UserEmail ⊢ Word(Email) ∧ IsUnique(UserEmail)
Order ⊢ IsGraph(Order)
```

---

## 1.4 Comportamentos locais de entidade

Comportamentos locais usam:

```txt
{Entity}.camelCase(...)
```

Exemplos:

```txt
User.isActive
User.isVerified
User.isValidFor(Order)
Product.isAvailableFor(OrderItem)
Payment.isValidFor(Order)
Delivery.isValidFor(Order)
Order.canBeCompleted
```

Fórmula:

```txt
Order.complete ⊢
  User.isValidFor(Order)
  ∧ Payment.isValidFor(Order)
  ∧ Product.isValidFor(Order)
  ∧ Delivery.isValidFor(Order)
```

---

## 1.5 Comportamentos locais de propriedade

Comportamentos de propriedade usam:

```txt
{Entity}.{Property}.camelCase
```

Exemplos:

```txt
User.email.exists
User.email.isVerified
User.cpf.exists
User.cpf.isVerified
Product.stock.exists
Product.stock.isAvailable
Order.items.exists
Order.items.isNonEmpty
```

Fórmula:

```txt
User.email.exists ∧ User.email.isVerified
Product.stock.exists ∧ Product.stock.isAvailable
Order.items.exists ∧ Order.items.isNonEmpty
```

---

## 1.6 Comportamentos relacionais entre entidades

Quando correlaciona duas ou mais entidades, deve ser comportamento local, porque a semântica depende do domínio.

Formato:

```txt
{EntitySource}.camelCase({EntityGoal})
```

Exemplos:

```txt
User.isValidFor(Order)
Payment.isValidFor(Order)
Product.isValidFor(Order)
Delivery.isValidFor(Order)
Stock.isAvailableFor(OrderItem)
Address.isValidFor(Delivery)
Coupon.isApplicableTo(Order)
Permission.allows(User, Action)
```

Eu evitaria transformar esses em globais, porque `isValidFor` muda de significado dependendo do domínio.

Exemplo:

```txt
User.isValidFor(Order)
```

pode significar:

```txt
User.isActive ∧ User.cpf.isVerified ∧ User.address.exists
```

Mas:

```txt
Payment.isValidFor(Order)
```

pode significar:

```txt
Payment.isAuthorized ∧ Payment.amount.equals(OrderValue)
```

Então o nome do comportamento é o mesmo, mas a implementação semântica pertence à entidade.

---

# 2. Tipos semânticos primitivos da standard-lib

Abaixo está um catálogo base completo para a sua primeira versão.

## 2.1 Valores nulos, vazios e ausentes

```txt
EmptyValue
NullValue
UndefinedValue
MissingValue
AbsentValue
BlankValue
WhitespaceValue
ZeroValue
NaNValue
InfiniteValue
UnknownValue
UnresolvedValue
```

Uso:

```txt
UserName ⊣ EmptyValue
UserEmail ⊣ NullValue
UserPhone ⊣ BlankValue
OrderValue ⊣ NaNValue
ProductPrice ⊣ InfiniteValue
```

Diferença semântica:

```txt
EmptyValue      = existe, mas está vazio
NullValue       = existe explicitamente como nulo
UndefinedValue  = não foi definido
MissingValue    = era obrigatório, mas não foi enviado
AbsentValue     = está semanticamente ausente
BlankValue      = string vazia ou visualmente vazia
WhitespaceValue = apenas espaços
UnknownValue    = existe, mas o sistema não sabe interpretar
UnresolvedValue = depende de resolução externa
```

---

## 2.2 Valores brutos, normalizados e canônicos

```txt
RawValue
ParsedValue
SanitizedValue
NormalizedValue
CanonicalValue
FormattedValue
EncodedValue
DecodedValue
EncryptedValue
DecryptedValue
HashedValue
SignedValue
VerifiedValue
ResolvedValue
ProjectedValue
IndexedValue
VectorizedValue
GraphMappedValue
LoggedValue
TracedValue
```

Uso:

```txt
RawUserPhone ↦ NormalizedUserPhone
NormalizedUserCPF ≡ CanonicalUserCPF
UserPassword ↦ HashedValue
CanonicalLabel ↦ VectorizedValue
OrderEvent ↦ LoggedValue
OrderFlow ↦ TracedValue
```

---

## 2.3 Tipos léxicos

```txt
Word
Text
String
Char
Letter
Digit
NumberChar
Symbol
Whitespace
Token
Lexeme
Phrase
Sentence
Slug
Code
Regex
Pattern
```

Uso:

```txt
UserPhone ⊢ Word(Number)
UserName ⊢ Text(Letter)
SlugValue ⊢ Word(Slug)
```

Eu manteria `Word(Number)` porque ele expressa melhor a sua ideia:

```txt
UserPhone ⊢ Word(Number)
```

significa que o valor bruto pode ser uma string, mas sua estrutura semântica é uma palavra composta por números.

---

## 2.4 Tipos numéricos

```txt
Number
Integer
Decimal
Float
Double
PositiveNumber
NegativeNumber
ZeroNumber
NaturalNumber
Percentage
Ratio
Amount
Quantity
Money
Currency
Price
Tax
Discount
Total
Subtotal
```

Uso:

```txt
OrderQuantity ⊢ Integer ∧ GreaterThan(0)
OrderValue ⊢ Money(BRL) ∧ GreaterThan(0)
Discount ⊢ Percentage ∧ Between(0, 100)
```

---

## 2.5 Tipos booleanos e estados

```txt
Boolean
TrueValue
FalseValue
Enabled
Disabled
Active
Inactive
Verified
Unverified
Allowed
Denied
Authorized
Unauthorized
Available
Unavailable
Valid
Invalid
Pending
Completed
Failed
Cancelled
Expired
Locked
Unlocked
Blocked
Unblocked
Visible
Hidden
Public
Private
```

Uso:

```txt
UserStatus ⊢ Active
UserCPFStatus ⊢ Verified
PaymentStatus ⊢ Authorized
OrderStatus ⊢ Completed
```

---

## 2.6 Tipos estruturais

```txt
Array
Object
Set
Map
Tuple
Record
List
Collection
Dictionary
Tree
Graph
Node
Edge
Path
DAG
Queue
Stack
Stream
Buffer
Blob
File
Document
```

Uso:

```txt
OrderItems ⊢ Array(OrderItem)
OrderItems ⊣ Array.EmptyValue
OrderGraph ⊢ Graph(Order)
ExecutionFlow ⊢ DAG(Event)
```

---

## 2.7 EmptyValue especializado por tipo estrutural

Isso é importante. Você deve permitir valores semânticos compostos:

```txt
Array.EmptyValue
Object.EmptyValue
Set.EmptyValue
Map.EmptyValue
String.EmptyValue
Text.EmptyValue
Graph.EmptyValue
Vector.EmptyValue
Log.EmptyValue
Trace.EmptyValue
Event.EmptyValue
File.EmptyValue
Document.EmptyValue
```

Exemplos:

```txt
OrderItems ⊣ Array.EmptyValue
UserProfile ⊣ Object.EmptyValue
EntityVector ⊣ Vector.EmptyValue
OrderTrace ⊣ Trace.EmptyValue
AuditLog ⊣ Log.EmptyValue
```

Diferença:

```txt
OrderItems ⊣ EmptyValue
```

é genérico.

```txt
OrderItems ⊣ Array.EmptyValue
```

é mais preciso.

Eu recomendo usar sempre o especializado quando o tipo estrutural é conhecido.

---

## 2.8 Tipos temporais

```txt
Date
Time
DateTime
Timestamp
Duration
Interval
Period
Timezone
Expiration
Deadline
Schedule
Recurrence
VersionTime
EventTime
ProcessingTime
CreatedAt
UpdatedAt
DeletedAt
OccurredAt
ReceivedAt
ProcessedAt
```

Uso:

```txt
TokenExpiration ⊢ FutureTimestamp
OrderCreatedAt ⊢ Timestamp
EventOccurredAt ⊢ EventTime
```

---

## 2.9 Tipos de identidade

```txt
Identifier
UUID
ULID
Hash
Fingerprint
CanonicalId
SemanticId
EntityId
AggregateId
CorrelationId
CausationId
TraceId
SpanId
SessionId
RequestId
EventId
UserId
TenantId
DeviceId
AgentId
PlaneId
IntentId
BehaviorId
ProofId
```

Uso:

```txt
UserId ⊢ UUID
EntityFingerprint ⊢ Hash(SHA256)
OrderEvent ⊢ EventId ∧ CorrelationId ∧ CausationId
```

---

## 2.10 Tipos de comunicação e evento

```txt
Event
Command
Query
Message
Signal
Notification
Request
Response
Reply
Callback
Webhook
Broadcast
Emission
Consumption
Subscription
Publication
Topic
Channel
Stream
Envelope
Payload
Header
Metadata
```

Uso:

```txt
ValidateUserPhone ⇢ UserPhone.validated
ValidateUserPhone ⇢ UserPhone.error
UserUIValidatorAgent ⇠ UserPhone.validationRequested
```

---

## 2.11 Tipos de prova e validação

```txt
Proof
Evidence
Witness
Receipt
Certificate
Signature
Attestation
ValidationProof
RefutationProof
IntegrityProof
CausalityProof
ReplayProof
AuthorizationProof
ComplianceProof
TypeProof
SemanticProof
```

Uso:

```txt
UserPhone.success ⇔ SemanticProof(UserPhone)
Order.complete ⇔ IntegrityProof(Order)
Payment.authorized ⇔ AuthorizationProof(Payment)
```

---

## 2.12 Tipos de erro e refutação

```txt
Error
Failure
Violation
Contradiction
Inconsistency
InvalidState
InvalidTransition
InvalidType
InvalidFormat
InvalidLength
InvalidChecksum
InvalidRange
InvalidReference
InvalidRelation
InvalidCapability
InvalidPermission
InvalidSignature
InvalidProof
InvalidCausality
InvalidReplay
InvalidCompliance
ExhaustedRepair
```

Uso:

```txt
UserCPF ⊣ InvalidChecksum
UserPhone ⊣ InvalidLength
OrderTransition ⊣ InvalidTransition
Payment ⊣ InvalidCapability
```

---

# 3. Comportamentos globais da standard-lib

Comportamentos globais devem ser independentes de entidade. Eles funcionam sobre tipos, valores e estruturas.

## 3.1 Existência e presença

```txt
Exists(x)
NotExists(x)
IsPresent(x)
IsMissing(x)
IsEmpty(x)
IsNotEmpty(x)
IsNull(x)
IsNotNull(x)
IsUndefined(x)
IsDefined(x)
IsBlank(x)
IsNotBlank(x)
IsUnknown(x)
IsResolved(x)
IsUnresolved(x)
```

Exemplos:

```txt
UserEmail ⊢ IsPresent(UserEmail)
UserPhone ⊣ IsBlank(UserPhone)
OrderItems ⊢ IsNotEmpty(OrderItems)
```

Para propriedade local, prefira:

```txt
User.email.exists
Order.items.isNonEmpty
```

Mas para fórmula genérica de tipo, use:

```txt
Exists(UserEmail)
IsNotEmpty(OrderItems)
```

---

## 3.2 Tipo e forma

```txt
IsType(x, T)
IsSemanticType(x, T)
IsRawType(x, T)
IsPrimitive(x)
IsComposite(x)
IsScalar(x)
IsCollection(x)
IsObject(x)
IsArray(x)
IsSet(x)
IsMap(x)
IsTuple(x)
IsGraph(x)
IsVector(x)
IsLog(x)
IsTrace(x)
IsEvent(x)
IsProof(x)
```

Exemplos:

```txt
UserPhone ⊢ IsSemanticType(UserPhone, Word(Number))
OrderItems ⊢ IsArray(OrderItems)
OrderFlow ⊢ IsGraph(OrderFlow)
EntityEmbedding ⊢ IsVector(EntityEmbedding)
```

---

## 3.3 Texto, palavra e padrão

```txt
Matches(pattern)
NotMatches(pattern)
Contains(value)
NotContains(value)
StartsWith(value)
EndsWith(value)
Includes(value)
Excludes(value)
Only(value)
OnlyLetters
OnlyNumbers
OnlyAlphanumeric
OnlySymbols
HasLetters
HasNumbers
HasSymbols
HasWhitespace
Trimmed
Lowercase
Uppercase
CamelCase
PascalCase
SnakeCase
KebabCase
SlugCase
```

Exemplos:

```txt
UserPhone ⊢ OnlyNumbers ∧ LengthBetween(10, 13)
UserName ⊢ OnlyLetters
EntityName ⊢ PascalCase
PropertyName ⊢ CamelCase
```

---

## 3.4 Tamanho, comprimento e cardinalidade

```txt
Length(n)
LengthMin(n)
LengthMax(n)
LengthBetween(start, end)
Size(n)
SizeMin(n)
SizeMax(n)
SizeBetween(start, end)
Count(n)
CountMin(n)
CountMax(n)
CountBetween(start, end)
Cardinality(n)
CardinalityMin(n)
CardinalityMax(n)
CardinalityBetween(start, end)
```

Exemplos:

```txt
UserCPF ⊢ Length(11)
UserPhone ⊢ LengthBetween(10, 13)
OrderItems ⊢ CountMin(1)
```

Eu usaria:

```txt
Length*
```

para texto.

```txt
Count*
```

para coleções.

```txt
Cardinality*
```

para conjuntos e relações.

---

## 3.5 Comparação numérica

```txt
Equals(value)
NotEquals(value)
GreaterThan(value)
GreaterThanOrEqual(value)
LessThan(value)
LessThanOrEqual(value)
Between(start, end)
Outside(start, end)
Positive
Negative
NonNegative
NonPositive
Zero
NonZero
Even
Odd
MultipleOf(value)
DivisibleBy(value)
```

Exemplos:

```txt
OrderValue ⊢ GreaterThan(0)
Discount ⊢ Between(0, 100)
StockQuantity ⊢ GreaterThanOrEqual(OrderItemQuantity)
```

---

## 3.6 Dinheiro e quantidade

```txt
IsMoney(x)
IsCurrency(x, currency)
HasCurrency(currency)
SameCurrency(x, y)
AmountEquals(x, y)
AmountGreaterThan(x, y)
AmountLessThan(x, y)
SumOf(values)
TotalOf(values)
SubtotalOf(values)
TaxOf(value)
DiscountOf(value)
PriceOf(value)
```

Exemplos:

```txt
OrderValue ⊢ Money(BRL) ∧ GreaterThan(0)
OrderTotal = SumOf(OrderItemValue) + PaymentTaxes + DeliveryPrice
PaymentAmount ⊢ AmountEquals(OrderValue)
```

---

## 3.7 Coleções

```txt
ContainsItem(item)
NotContainsItem(item)
ContainsAll(items)
ContainsAny(items)
ContainsNone(items)
AllSatisfy(predicate)
AnySatisfy(predicate)
NoneSatisfy(predicate)
HasDuplicates
HasNoDuplicates
IsUniqueCollection
IsOrdered
IsUnordered
IsSorted
IsDistinct
First
Last
Head
Tail
```

Exemplos:

```txt
OrderItems ⊢ Array(OrderItem) ∧ CountMin(1)
OrderItems ⊢ AllSatisfy(OrderItem.isValid)
OrderItems ⊣ HasDuplicates
```

---

## 3.8 Unicidade e identidade

```txt
IsUnique(x)
IsGloballyUnique(x)
IsLocallyUnique(x)
IsDeterministic(x)
IsStable(x)
IsCanonical(x)
HasIdentity(x)
HasFingerprint(x)
HasHash(x)
HasStableId(x)
HasCanonicalId(x)
SameIdentity(x, y)
DifferentIdentity(x, y)
```

Exemplos:

```txt
UserEmail ⊢ IsUnique(UserEmail)
Entity ⊢ HasFingerprint(Entity)
CanonicalLabel ⊢ IsStable(CanonicalLabel)
```

---

## 3.9 Normalização e canonicalização

```txt
Normalize(x)
Canonicalize(x)
Sanitize(x)
Parse(x)
Format(x)
Encode(x)
Decode(x)
Hash(x)
Sign(x)
Verify(x)
Encrypt(x)
Decrypt(x)
Resolve(x)
Project(x)
Index(x)
Vectorize(x)
GraphMap(x)
Log(x)
Trace(x)
```

Exemplo:

```txt
RawUserPhone ↦ Normalize(UserPhone)
NormalizedUserPhone ≡ Canonicalize(UserPhone)
CanonicalLabel ↦ Vectorize(CanonicalLabel)
OrderEvent ↦ Log(OrderEvent)
OrderFlow ↦ Trace(OrderFlow)
```

---

## 3.10 Plane-related globais

Sua regra está certa: qualquer comportamento que se refira a um Plane deve ser global, porque o Plane é uma capacidade da arquitetura, não uma entidade de domínio.

```txt
IsUIPlane(x)
IsDomainPlane(x)
IsValidationPlane(x)
IsTypePlane(x)
IsEventPlane(x)
IsGraphPlane(x)
IsVectorPlane(x)
IsLogPlane(x)
IsTracePlane(x)
IsMetricsPlane(x)
IsCompliancePlane(x)
IsSecurityPlane(x)
IsPersistencePlane(x)
IsProjectionPlane(x)
IsGatewayPlane(x)
IsAgentPlane(x)
```

E também:

```txt
BelongsToPlane(x, Plane)
RequiresPlane(x, Plane)
ValidatedByPlane(x, Plane)
ProjectedToPlane(x, Plane)
IndexedByPlane(x, Plane)
LoggedByPlane(x, Plane)
TracedByPlane(x, Plane)
ObservedByPlane(x, Plane)
GovernedByPlane(x, Plane)
```

Exemplos:

```txt
UserPhone ⊢ ValidatedByPlane(UserPhone, UIPlane)
UserCPF ⊢ ValidatedByPlane(UserCPF, TypePlane)
OrderEvent ⊢ LoggedByPlane(OrderEvent, EventPlane)
Order ⊢ ProjectedToPlane(Order, ReadDataPlane)
Entity ⊢ IndexedByPlane(Entity, VectorPlane)
```

---

# 4. Comportamentos globais específicos que você citou

Esses eu colocaria oficialmente na standard-lib.

```txt
IsVector(Entity)
IsGraph(Entity)
IsLog(Entity)
IsTrace(Entity)
IsEvent(Entity)
IsProjection(Entity)
IsIndex(Entity)
IsAggregate(Entity)
IsEntity(Entity)
IsAgent(Entity)
IsPlane(Entity)
IsIntent(Entity)
IsBehavior(Entity)
IsProof(Entity)
```

Exemplos:

```txt
User ⊢ IsVector(User)
Order ⊢ IsGraph(Order)
Payment ⊢ IsLog(Payment)
OrderExecution ⊢ IsTrace(OrderExecution)
UserCreated ⊢ IsEvent(UserCreated)
```

Mas talvez a forma mais correta seja:

```txt
HasVector(Entity)
HasGraph(Entity)
HasLog(Entity)
HasTrace(Entity)
HasProjection(Entity)
HasIndex(Entity)
```

Diferença:

```txt
IsVector(User)
```

soa como “User é um vetor”.

```txt
HasVector(User)
```

soa como “User possui representação vetorial”.

Então eu recomendo:

```txt
HasVector(User)
HasGraph(User)
HasLog(User)
HasTrace(User)
```

E reservar `IsVector(x)` para quando o próprio valor é um vetor:

```txt
UserEmbedding ⊢ IsVector(UserEmbedding)
User ⊢ HasVector(User)
```

Isso evita ambiguidade.

Portanto:

```txt
IsVector(EntityVector) = o valor é um vetor
HasVector(Entity) = a entidade possui representação vetorial
```

---

# 5. Comportamentos de entidade da standard-lib

Agora os comportamentos locais.

## 5.1 Existência e posse

```txt
{Entity}.exists
{Entity}.notExists
{Entity}.has({Property})
{Entity}.hasNot({Property})
{Entity}.hasRequired({Property})
{Entity}.hasOptional({Property})
{Entity}.hasAll({Properties})
{Entity}.hasAny({Properties})
{Entity}.hasNone({Properties})
```

Exemplos:

```txt
User.exists
User.has(UserEmail)
User.has(UserCPF)
Order.has(OrderItems)
Product.has(ProductPrice)
```

---

## 5.2 Propriedade local

```txt
{Entity}.{Property}.exists
{Entity}.{Property}.notExists
{Entity}.{Property}.isEmpty
{Entity}.{Property}.isNotEmpty
{Entity}.{Property}.isVerified
{Entity}.{Property}.isUnverified
{Entity}.{Property}.isValid
{Entity}.{Property}.isInvalid
{Entity}.{Property}.isUnique
{Entity}.{Property}.isCanonical
{Entity}.{Property}.isNormalized
{Entity}.{Property}.isRequired
{Entity}.{Property}.isOptional
```

Exemplos:

```txt
User.email.exists
User.email.isVerified
User.cpf.exists
User.cpf.isVerified
Product.stock.exists
Product.stock.isAvailable
Order.items.exists
Order.items.isNotEmpty
```

---

## 5.3 Estado de entidade

```txt
{Entity}.isActive
{Entity}.isInactive
{Entity}.isEnabled
{Entity}.isDisabled
{Entity}.isBlocked
{Entity}.isUnblocked
{Entity}.isLocked
{Entity}.isUnlocked
{Entity}.isVerified
{Entity}.isUnverified
{Entity}.isPending
{Entity}.isCompleted
{Entity}.isFailed
{Entity}.isCancelled
{Entity}.isExpired
{Entity}.isDeleted
{Entity}.isArchived
```

Exemplos:

```txt
User.isActive
Product.isActive
Payment.isAuthorized
Order.isCompleted
Session.isExpired
```

---

## 5.4 Validade contextual

```txt
{EntitySource}.isValidFor({EntityGoal})
{EntitySource}.isInvalidFor({EntityGoal})
{EntitySource}.isCompatibleWith({EntityGoal})
{EntitySource}.isIncompatibleWith({EntityGoal})
{EntitySource}.isEligibleFor({EntityGoal})
{EntitySource}.isNotEligibleFor({EntityGoal})
{EntitySource}.isAllowedFor({EntityGoal})
{EntitySource}.isDeniedFor({EntityGoal})
{EntitySource}.canBeUsedFor({EntityGoal})
{EntitySource}.cannotBeUsedFor({EntityGoal})
```

Exemplos:

```txt
User.isValidFor(Order)
Payment.isValidFor(Order)
Product.isValidFor(Order)
Delivery.isValidFor(Order)
Coupon.isApplicableTo(Order)
Address.isValidFor(Delivery)
```

---

## 5.5 Capacidade e permissão

```txt
{Entity}.can({Action})
{Entity}.cannot({Action})
{Entity}.may({Action})
{Entity}.must({Action})
{Entity}.mustNot({Action})
{Entity}.allows({Action})
{Entity}.denies({Action})
{Entity}.hasPermission({Permission})
{Entity}.hasCapability({Capability})
{Entity}.lacksCapability({Capability})
```

Exemplos:

```txt
User.can(CreateOrder)
User.hasPermission(CompleteOrder)
Payment.hasCapability(AuthorizePayment)
Agent.canEmit(Order.completed)
```

---

## 5.6 Transição de estado

```txt
{Entity}.canTransitionTo({State})
{Entity}.cannotTransitionTo({State})
{Entity}.transitionIsValid({FromState}, {ToState})
{Entity}.transitionIsInvalid({FromState}, {ToState})
{Entity}.hasReached({State})
{Entity}.hasNotReached({State})
```

Exemplos:

```txt
Order.canTransitionTo(Completed)
Payment.canTransitionTo(Authorized)
Session.canTransitionTo(Expired)
```

Fórmula:

```txt
Order.complete ⇢ Order.completed ⇔ Order.canTransitionTo(Completed)
```

---

## 5.7 Evento

```txt
{Entity}.emits({Event})
{Entity}.consumes({Event})
{Entity}.canEmit({Event})
{Entity}.cannotEmit({Event})
{Entity}.hasEmitted({Event})
{Entity}.hasConsumed({Event})
{Entity}.awaits({Event})
{Entity}.received({Event})
```

Exemplos:

```txt
ValidateUserPhone.emits(UserPhone.success)
ValidateUserPhone.emits(UserPhone.error)
UserUIValidatorAgent.consumes(UserPhone.validationRequested)
```

Mas na fórmula eu manteria o símbolo:

```txt
ValidateUserPhone ⇢ UserPhone.success
ValidateUserPhone ⇢ UserPhone.error
UserUIValidatorAgent ⇠ UserPhone.validationRequested
```

---

## 5.8 Prova, validação e refutação

```txt
{Entity}.hasProof({Proof})
{Entity}.hasValidProof({Proof})
{Entity}.hasInvalidProof({Proof})
{Entity}.hasSemanticProof
{Entity}.hasTypeProof
{Entity}.hasIntegrityProof
{Entity}.hasRefutationProof
{Entity}.isProven
{Entity}.isRefuted
{Entity}.satisfies({Formula})
{Entity}.refutes({Formula})
```

Exemplos:

```txt
UserPhone.hasSemanticProof
Order.hasIntegrityProof
Payment.hasAuthorizationProof
UserCPF.hasRefutationProof
```

Fórmula:

```txt
UserPhone.success ⇔ UserPhone.hasSemanticProof
Order.completed ⇔ Order.hasIntegrityProof
```

---

## 5.9 Observabilidade

```txt
{Entity}.hasLog
{Entity}.hasTrace
{Entity}.hasMetrics
{Entity}.hasSpan
{Entity}.hasEventLog
{Entity}.hasCausalTrace
{Entity}.hasReplayTrace
{Entity}.hasAuditLog
{Entity}.isObservable
{Entity}.isReplayable
{Entity}.isAuditable
```

Exemplos:

```txt
Order.hasCausalTrace
Payment.hasAuditLog
AgentExecution.hasReplayTrace
```

---

## 5.10 Representação semântica

```txt
{Entity}.hasVector
{Entity}.hasGraph
{Entity}.hasProjection
{Entity}.hasIndex
{Entity}.hasCanonicalLabel
{Entity}.hasSemanticId
{Entity}.hasFingerprint
{Entity}.hasEmbedding
{Entity}.hasSearchIndex
```

Exemplos:

```txt
User.hasVector
Order.hasGraph
Product.hasSearchIndex
Entity.hasCanonicalLabel
```

Esse ponto é importante para sua arquitetura:

```txt
Entity.hasCanonicalLabel ∧ Entity.hasVector
```

significa que a entidade é semanticamente achável por similaridade.

---

# 6. Valores semânticos de erro/refutação

Aqui está uma lista base forte para a sua standard-lib.

```txt
InvalidValue
InvalidType
InvalidSemanticType
InvalidRawType
InvalidFormat
InvalidPattern
InvalidLength
InvalidSize
InvalidCount
InvalidRange
InvalidNumber
InvalidInteger
InvalidDecimal
InvalidMoney
InvalidCurrency
InvalidEmail
InvalidCPF
InvalidPhone
InvalidURL
InvalidUUID
InvalidDate
InvalidTimestamp
InvalidTimezone
InvalidChecksum
InvalidSignature
InvalidHash
InvalidProof
InvalidReference
InvalidRelation
InvalidIdentity
InvalidPermission
InvalidCapability
InvalidState
InvalidTransition
InvalidEvent
InvalidPayload
InvalidEnvelope
InvalidCausality
InvalidReplay
InvalidOrder
InvalidSequence
InvalidGraph
InvalidVector
InvalidLog
InvalidTrace
InvalidPlane
InvalidAgent
InvalidIntent
InvalidBehavior
InvalidCompliance
InvalidPolicy
InvalidLaw
InvalidContract
```

Exemplos:

```txt
UserEmail ⊣ InvalidEmail
UserCPF ⊣ InvalidCPF ∨ InvalidChecksum
OrderTransition ⊣ InvalidTransition
EventTrace ⊣ InvalidCausality
UserEmbedding ⊣ InvalidVector
```

---

# 7. Semantic values de lifecycle

Esses ajudam a padronizar estados de qualquer Entity.

```txt
Created
Initialized
Received
Parsed
Sanitized
Normalized
Canonicalized
Validated
Refuted
Rejected
Accepted
Resolved
Unresolved
Authorized
Unauthorized
Authenticated
Unauthenticated
Indexed
Vectorized
GraphMapped
Projected
Persisted
Logged
Traced
Observed
Emitted
Consumed
Processed
Completed
Failed
Cancelled
Expired
Archived
Deleted
Replayed
Recovered
Healed
Exhausted
```

Exemplos:

```txt
UserPhone ⊢ Normalized
UserCPF ⊢ Canonicalized
Order ⊢ Completed
Payment ⊢ Authorized
OrderTrace ⊢ Replayed
```

---

# 8. Standard-lib de fórmulas primitivas

Eu estruturaria assim:

```txt
SemanticValue
SemanticPrimitive
SemanticStructure
SemanticPredicate
SemanticBehavior
SemanticRefutation
SemanticPlaneBehavior
SemanticEntityBehavior
```

## 8.1 SemanticValue

```txt
EmptyValue
NullValue
UndefinedValue
MissingValue
InvalidValue
RawValue
NormalizedValue
CanonicalValue
VerifiedValue
RefutedValue
```

## 8.2 SemanticPrimitive

```txt
Word
Text
Number
Integer
Decimal
Boolean
DateTime
Money
Identifier
Event
Proof
Vector
Graph
Log
Trace
```

## 8.3 SemanticStructure

```txt
Array
Object
Set
Map
Tuple
Record
Collection
Tree
DAG
Stream
Envelope
Payload
Metadata
```

## 8.4 SemanticPredicate

```txt
Exists
IsPresent
IsEmpty
IsNotEmpty
Length
LengthBetween
CountMin
GreaterThan
Between
Matches
OnlyNumbers
OnlyLetters
IsUnique
IsCanonical
IsNormalized
IsVector
IsGraph
IsLog
IsTrace
```

## 8.5 SemanticEntityBehavior

```txt
{Entity}.exists
{Entity}.has({Property})
{Entity}.isActive
{Entity}.isVerified
{Entity}.isValidFor({EntityGoal})
{Entity}.can({Action})
{Entity}.canEmit({Event})
{Entity}.hasProof({Proof})
{Entity}.hasTrace
{Entity}.hasVector
{Entity}.hasGraph
```

---

# 9. Como ficaria seu exemplo com a lib padronizada

A fórmula:

```yaml
success_when: UserPhone ⊢ Word(Number) ∧ UserPhone ⊢ LengthBetween(10, 13) ∧ ¬(UserPhone ⊣ EmptyValue)
```

pode ser normalizada para:

```yaml
success_when: UserPhone ⊢ Word(Number) ∧ LengthBetween(10, 13) ∧ IsNotEmpty(UserPhone)
```

Mas eu manteria a versão com refutação quando o objetivo é governança:

```yaml
success_when: UserPhone ⊢ Word(Number) ∧ LengthBetween(10, 13) ∧ ¬(UserPhone ⊣ EmptyValue)
```

Porque ela deixa explícito que o success só ocorre se nenhuma regra de refutação essencial foi provada.

A versão mais completa:

```yaml
semantic_formulas:
  - UserPhone ⊢ Word(Number)
  - UserPhone ⊢ LengthBetween(10, 13)
  - UserPhone ⊢ NormalizedValue

refutation_formulas:
  - UserPhone ⊣ EmptyValue
  - UserPhone ⊣ BlankValue
  - UserPhone ⊣ Word(Letter)
  - UserPhone ⊣ InvalidLength
  - UserPhone ⊣ InvalidPhone

event_rules:
  - behavior: ValidateUserPhone
    success_when: UserPhone ⊢ Word(Number) ∧ LengthBetween(10, 13) ∧ ¬(UserPhone ⊣ EmptyValue ∨ BlankValue ∨ Word(Letter) ∨ InvalidLength)
    error_when: UserPhone ⊣ EmptyValue ∨ BlankValue ∨ Word(Letter) ∨ InvalidLength ∨ InvalidPhone
```

---

# 10. Regras finais de nomeação

Eu fecharia a standard-lib assim:

```txt
1. Semantic values are PascalCase nouns.
   Example: EmptyValue, InvalidChecksum, CanonicalValue.

2. Semantic primitives are PascalCase type constructors.
   Example: Word(Number), Array(OrderItem), Vector(Number).

3. Global behaviors are PascalCase predicates or functions.
   Example: LengthBetween(10, 13), IsUnique(UserEmail), HasVector(User).

4. Entity behaviors are local and use camelCase.
   Example: User.isValidFor(Order), Product.has(StockQuantity).

5. Property behaviors are local and use Entity.Property.camelCase.
   Example: User.email.exists, Product.stock.isAvailable.

6. Plane-related behaviors are always global.
   Example: ValidatedByPlane(UserCPF, TypePlane), IndexedByPlane(User, VectorPlane).

7. Cross-entity domain behavior is local to the source entity.
   Example: Payment.isValidFor(Order), Stock.isAvailableFor(OrderItem).

8. `IsX(value)` means the value itself is X.
   Example: IsVector(UserEmbedding).

9. `HasX(entity)` means the entity has a representation/capability X.
   Example: HasVector(User).

10. `⊢` means satisfies.
    Example: UserPhone ⊢ Word(Number).

11. `⊣` means refutes.
    Example: UserPhone ⊣ Word(Letter).

12. `⇔` must be used for success/error event eligibility.
    Example: ValidateUserPhone ⇢ UserPhone.success ⇔ UserPhone ⊢ ValidUserPhone.
```

---

# 11. Núcleo mínimo da standard-semantic-typed-lib v0.1

Se você quiser começar com uma base pequena, eu começaria com isto:

```txt
Semantic values:
EmptyValue
NullValue
UndefinedValue
MissingValue
BlankValue
InvalidValue
RawValue
NormalizedValue
CanonicalValue
VerifiedValue
RefutedValue

Primitive types:
Word
Text
Number
Integer
Decimal
Boolean
DateTime
Money
Identifier
Array
Object
Set
Map
Graph
Vector
Log
Trace
Event
Proof

Structural empty values:
Array.EmptyValue
Object.EmptyValue
Set.EmptyValue
Map.EmptyValue
Graph.EmptyValue
Vector.EmptyValue
Log.EmptyValue
Trace.EmptyValue

Global behaviors:
Exists(x)
IsPresent(x)
IsEmpty(x)
IsNotEmpty(x)
Length(n)
LengthBetween(start, end)
CountMin(n)
GreaterThan(value)
GreaterThanOrEqual(value)
LessThan(value)
LessThanOrEqual(value)
Between(start, end)
Matches(pattern)
OnlyNumbers
OnlyLetters
OnlyAlphanumeric
IsUnique(x)
IsCanonical(x)
IsNormalized(x)
IsVector(x)
IsGraph(x)
IsLog(x)
IsTrace(x)
HasVector(entity)
HasGraph(entity)
HasLog(entity)
HasTrace(entity)
ValidatedByPlane(x, Plane)
IndexedByPlane(x, Plane)
LoggedByPlane(x, Plane)
TracedByPlane(x, Plane)

Entity behaviors:
{Entity}.exists
{Entity}.has({Property})
{Entity}.isActive
{Entity}.isVerified
{Entity}.isValid
{Entity}.isInvalid
{Entity}.isValidFor({EntityGoal})
{Entity}.isCompatibleWith({EntityGoal})
{Entity}.can({Action})
{Entity}.canEmit({Event})
{Entity}.hasProof({Proof})
{Entity}.hasSemanticProof
{Entity}.hasIntegrityProof
{Entity}.hasVector
{Entity}.hasGraph
{Entity}.hasLog
{Entity}.hasTrace

Property behaviors:
{Entity}.{Property}.exists
{Entity}.{Property}.isEmpty
{Entity}.{Property}.isNotEmpty
{Entity}.{Property}.isVerified
{Entity}.{Property}.isUnique
{Entity}.{Property}.isCanonical
{Entity}.{Property}.isNormalized
{Entity}.{Property}.isValid
{Entity}.{Property}.isInvalid
```

---

# 12. Exemplo canônico final

```yaml
behavior: ValidateUserPhone

property_bindings:
  User.phone:
    semantic_type: UserPhone
    raw_type: Text
    canonical_type: NormalizedUserPhone

semantic_formulas:
  - UserPhone ⊢ Word(Number)
  - UserPhone ⊢ LengthBetween(10, 13)
  - UserPhone ⊢ NormalizedValue

refutation_formulas:
  - UserPhone ⊣ EmptyValue
  - UserPhone ⊣ BlankValue
  - UserPhone ⊣ Word(Letter)
  - UserPhone ⊣ InvalidLength
  - UserPhone ⊣ InvalidPhone

event_rules:
  consumes:
    - UserPhone.validationRequested

  emits_success:
    - UserPhone.success

  emits_error:
    - UserPhone.error

  success_when: UserPhone ⊢ Word(Number) ∧ LengthBetween(10, 13) ∧ NormalizedValue ∧ ¬(UserPhone ⊣ EmptyValue ∨ BlankValue ∨ Word(Letter) ∨ InvalidLength)

  error_when: UserPhone ⊣ EmptyValue ∨ BlankValue ∨ Word(Letter) ∨ InvalidLength ∨ InvalidPhone

frontend_execution:
  validator_agent: UserUIValidatorAgent
  type_validator_agent: UserUITypeValidatorAgent
  rule_validator_agent: UserUIRuleValidatorAgent
  engines:
    - HaskellWASM
    - PrologWASM

backend_execution:
  revalidate: true
  same_formulas: true
```

A regra mais importante para manter a lib limpa é esta:

```txt
Use `IsX(value)` when the value itself must be X.
Use `{Entity}.hasX` or `HasX(Entity)` when the entity only has a representation X.
Use `{Entity}.camelCase` when the behavior depends on domain semantics.
Use `PascalCase(...)` when the behavior is globally reusable and domain-independent.
```

Com isso, você evita ambiguidade entre:

```txt
IsVector(User)
```

e:

```txt
User.hasVector
```

A forma correta para o seu sistema provavelmente é:

```txt
User.hasVector
User.hasGraph
User.hasLog
User.hasTrace
```

ou, na forma global padronizada:

```txt
HasVector(User)
HasGraph(User)
HasLog(User)
HasTrace(User)
```

E reservar:

```txt
IsVector(UserEmbedding)
IsGraph(OrderExecutionGraph)
IsLog(OrderAuditLog)
IsTrace(OrderCausalTrace)
```

para quando o próprio valor é daquele tipo.
