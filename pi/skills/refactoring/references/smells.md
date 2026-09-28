# Smells to refactorings

Each smell has a short description in our words, and the refactorings that
remove it. The pairing and the page numbers come from the Smells to
Refactorings quick reference by Industrial Logic (2005).

## How to read an entry

```text
- Rename Method [F 273] → Change Function Declaration (`changeFunctionDeclaration`)
- Unify Interfaces with Adapter [K 247]
```

- **The bracket is a book and a page.** F is Martin Fowler, *Refactoring:
  Improving the Design of Existing Code*, first edition, 1999. K is Joshua
  Kerievsky, *Refactoring to Patterns*, 2004. `[F 273]` is page 273 of the
  first. `[F 260, K 301]` appears in both books.
- **An F page is from the first edition.** The second edition has other page
  numbers, so do not look an F page up in it. Use the catalog link instead.
- **The letter tells you where to read.** An F refactoring is in the online
  catalog. The arrow gives its current name and its id in `catalog.md`, and
  the id is the value of the `Refactoring:` trailer. A refactoring with only
  K is a larger move toward a design pattern. It is not in the online
  catalog, so it has no id.
- **A few F refactorings left the second edition.** Those say so, and have no
  id.

## Alternative Classes with Different Interfaces

Two classes do much the same job through different interfaces.

- Unify Interfaces with Adapter [K 247]
- Rename Method [F 273] → Change Function Declaration (`changeFunctionDeclaration`)
- Move Method [F 142] → Move Function (`moveFunction`)

## Combinatorial Explosion

Many pieces of code do the same thing for different combinations of data or behavior.

- Replace Implicit Language with Interpreter [K 269]

## Comments

A comment explains code that could explain itself. Refactor until the comment has nothing left to say.

- Rename Method [F 273] → Change Function Declaration (`changeFunctionDeclaration`)
- Extract Method [F 110] → Extract Function (`extractFunction`)
- Introduce Assertion [F 267] (`introduceAssertion`)

## Conditional Complexity

Conditional logic that grew with each feature until it is hard to follow.

- Introduce Null Object [F 260, K 301] → Introduce Special Case (`introduceSpecialCase`)
- Move Embellishment to Decorator [K 144]
- Replace Conditional Logic with Strategy [K 129]
- Replace State-Altering Conditionals with State [K 166]

## Data Class

A class with fields and accessors and no behavior, while other classes do its work.

- Move Method [F 142] → Move Function (`moveFunction`)
- Encapsulate Field [F 206] → Encapsulate Variable (`encapsulateVariable`)
- Encapsulate Collection [F 208] (`encapsulateCollection`)

## Data Clumps

The same few values travel together everywhere. Remove one: if the rest no longer make sense, they are an object.

- Extract Class [F 149] (`extractClass`)
- Preserve Whole Object [F 288] (`preserveWholeObject`)
- Introduce Parameter Object [F 295] (`introduceParameterObject`)

## Divergent Change

One class changes in different ways, for different reasons.

- Extract Class [F 149] (`extractClass`)

## Duplicated Code

The same logic in two places, either as identical code or as steps that differ in form only.

- Chain Constructors [K 340]
- Extract Composite [K 214]
- Extract Method [F 110] → Extract Function (`extractFunction`)
- Extract Class [F 149] (`extractClass`)
- Form Template Method [F 345, K 205]
- Introduce Null Object [F 260, K 301] → Introduce Special Case (`introduceSpecialCase`)
- Introduce Polymorphic Creation with Factory Method [K 88]
- Pull Up Method [F 322] (`pullUpMethod`)
- Pull Up Field [F 320] (`pullUpField`)
- Replace One/Many Distinctions with Composite [K 224]
- Substitute Algorithm [F 139] (`substituteAlgorithm`)
- Unify Interfaces with Adapter [K 247]

## Feature Envy

A function uses the data of another class more than its own.

- Extract Method [F 110] → Extract Function (`extractFunction`)
- Move Method [F 142] → Move Function (`moveFunction`)
- Move Field [F 146] (`moveField`)

## Freeloader (Lazy Class)

A class that does too little to pay for itself.

- Collapse Hierarchy [F 344] (`collapseHierarchy`)
- Inline Class [F 154] (`inlineClass`)
- Inline Singleton [K 114]

## Inappropriate Intimacy

Two classes reach into each other's private parts.

- Move Method [F 142] → Move Function (`moveFunction`)
- Move Field [F 146] (`moveField`)
- Change Bidirectional Association to Unidirectional Association [F 200], not in the second edition
- Extract Class [F 149] (`extractClass`)
- Hide Delegate [F 157] (`hideDelegate`)
- Replace Inheritance with Delegation [F 352] → Replace Superclass with Delegate (`replaceSuperclassWithDelegate`)

## Incomplete Library Class

Code needs a feature a library lacks, and the library cannot change.

- Introduce Foreign Method [F 162], not in the second edition
- Introduce Local Extension [F 164], not in the second edition

## Indecent Exposure

Code that callers do not need is visible to them.

- Encapsulate Classes with Factory [K 80]

## Large Class

A class with too many fields, and too many responsibilities.

- Extract Class [F 149] (`extractClass`)
- Extract Subclass [F 330] → Replace Type Code with Subclasses (`replaceTypeCodeWithSubclasses`)
- Extract Interface [F 341], not in the second edition
- Replace Data Value with Object [F 175] → Replace Primitive with Object (`replacePrimitiveWithObject`)
- Replace Conditional Dispatcher with Command [K 191]
- Replace Implicit Language with Interpreter [K 269]
- Replace State-Altering Conditionals with State [K 166]

## Long Method

A function too long to understand at a glance. Small, well-named functions explain and share logic.

- Extract Method [F 110] → Extract Function (`extractFunction`)
- Compose Method [K 123]
- Introduce Parameter Object [F 295] (`introduceParameterObject`)
- Move Accumulation to Collecting Parameter [K 313]
- Move Accumulation to Visitor [K 320]
- Decompose Conditional [F 238] (`decomposeConditional`)
- Preserve Whole Object [F 288] (`preserveWholeObject`)
- Replace Conditional Dispatcher with Command [K 191]
- Replace Conditional Logic with Strategy [K 129]
- Replace Method with Method Object [F 135] → Replace Function with Command (`replaceFunctionWithCommand`)
- Replace Temp with Query [F 120] (`replaceTempWithQuery`)

## Long Parameter List

A function that takes many parameters. Let it find more of what it needs itself.

- Replace Parameter with Method [F 292] → Replace Parameter with Query (`replaceParameterWithQuery`)
- Introduce Parameter Object [F 295] (`introduceParameterObject`)
- Preserve Whole Object [F 288] (`preserveWholeObject`)

## Message Chains

A long chain of calls to reach some data, which ties the caller to every link.

- Hide Delegate [F 157] (`hideDelegate`)
- Extract Method [F 110] → Extract Function (`extractFunction`)
- Move Method [F 142] → Move Function (`moveFunction`)

## Middle Man

A class that only passes calls on to another class.

- Remove Middle Man [F 160] (`removeMiddleMan`)
- Inline Method [F 117] → Inline Function (`inlineFunction`)
- Replace Delegation with Inheritance [F 355], not in the second edition

## Oddball Solution

One problem solved one way in most places and another way in one place.

- Unify Interfaces with Adapter [K 247]

## Parallel Inheritance Hierarchies

Each new subclass in one hierarchy forces a new subclass in another.

- Move Method [F 142] → Move Function (`moveFunction`)
- Move Field [F 146] (`moveField`)

## Primitive Obsession

Strings, numbers and arrays stand in for concepts that deserve their own type.

- Replace Data Value with Object [F 175] → Replace Primitive with Object (`replacePrimitiveWithObject`)
- Encapsulate Composite with Builder [K 96]
- Introduce Parameter Object [F 295] (`introduceParameterObject`)
- Extract Class [F 149] (`extractClass`)
- Move Embellishment to Decorator [K 144]
- Replace Conditional Logic with Strategy [K 129]
- Replace Implicit Language with Interpreter [K 269]
- Replace Implicit Tree with Composite [K 178]
- Replace State-Altering Conditionals with State [K 166]
- Replace Type Code with Class [F 218, K 286] → Replace Primitive with Object (`replacePrimitiveWithObject`)
- Replace Type Code with State/Strategy [F 227] → Replace Type Code with Subclasses (`replaceTypeCodeWithSubclasses`)
- Replace Type Code with Subclasses [F 223] (`replaceTypeCodeWithSubclasses`)
- Replace Array with Object [F 186], not in the second edition

## Refused Bequest

A subclass inherits what it does not want, and works against it.

- Push Down Field [F 329] (`pushDownField`)
- Push Down Method [F 322] (`pushDownMethod`)
- Replace Inheritance with Delegation [F 352] → Replace Superclass with Delegate (`replaceSuperclassWithDelegate`)

## Shotgun Surgery

One change needs small edits in many places.

- Move Method [F 142] → Move Function (`moveFunction`)
- Move Field [F 146] (`moveField`)
- Inline Class [F 154] (`inlineClass`)

## Solution Sprawl

The code for one responsibility spreads across many classes.

- Move Creation Knowledge to Factory [K 68]

## Speculative Generality

Abstraction built for a future that has not come.

- Collapse Hierarchy [F 344] (`collapseHierarchy`)
- Rename Method [F 273] → Change Function Declaration (`changeFunctionDeclaration`)
- Remove Parameter [F 277] → Change Function Declaration (`changeFunctionDeclaration`)
- Inline Class [F 154] (`inlineClass`)

## Switch Statement

The same switch or if-else chain repeats across the code.

- Move Accumulation to Visitor [K 320]
- Replace Conditional Dispatcher with Command [K 191]
- Replace Conditional with Polymorphism [F 255] (`replaceConditionalWithPolymorphism`)
- Replace Type Code with Subclasses [F 223] (`replaceTypeCodeWithSubclasses`)
- Replace Type Code with State/Strategy [F 227] → Replace Type Code with Subclasses (`replaceTypeCodeWithSubclasses`)
- Replace Parameter with Explicit Methods [F 285] → Remove Flag Argument (`removeFlagArgument`)
- Introduce Null Object [F 260, K 301] → Introduce Special Case (`introduceSpecialCase`)

## Temporary Field

A field that holds a value only some of the time.

- Extract Class [F 149] (`extractClass`)
- Introduce Null Object [F 260, K 301] → Introduce Special Case (`introduceSpecialCase`)
