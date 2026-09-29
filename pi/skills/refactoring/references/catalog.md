# The refactoring catalog

The 66 refactorings of the second edition of Martin Fowler's *Refactoring*,
as listed at https://refactoring.com/catalog/ on 2026-09-26. Each name links
to its page, which shows a sketch of the code before and after.

The id is the value of the `Refactoring:` commit trailer. Older names come
from the first edition and other sources. A smell that names an old
refactoring still leads here.

**Use it when** is our text, not Fowler's. It says only what the name and the
sketch of the page show. Read the page before you apply the refactoring.
**Smells** lists the smells in `smells.md` that point here. **Inverse** is the
refactoring that undoes this one, as its page names it.

## [Change Function Declaration](https://refactoring.com/catalog/changeFunctionDeclaration.html)

`changeFunctionDeclaration` · older names: Add Parameter, Change Signature, Remove Parameter, Rename Function, Rename Method · tags: basic, rename

Use it when the name or the parameters of a function do not say what it does.

Smells: Alternative Classes with Different Interfaces, Comments, Speculative Generality.

## [Change Reference to Value](https://refactoring.com/catalog/changeReferenceToValue.html)

`changeReferenceToValue` · inverse: Change Value to Reference · tags: organizing-data, variables

Use it when code changes a shared object in place, where a new object with the new value would do.

## [Change Value to Reference](https://refactoring.com/catalog/changeValueToReference.html)

`changeValueToReference` · inverse: Change Reference to Value · tags: organizing-data, immutability, variables

Use it when code makes its own copy of an object that must be one shared object.

## [Collapse Hierarchy](https://refactoring.com/catalog/collapseHierarchy.html)

`collapseHierarchy` · tags: dealing-with-inheritance

Use it when a subclass is no longer different enough from its superclass to keep them apart.

Smells: Freeloader (Lazy Class), Speculative Generality.

## [Combine Functions into Class](https://refactoring.com/catalog/combineFunctionsIntoClass.html)

`combineFunctionsIntoClass` · tags: basic, encapsulation, grouping-function

Use it when several functions take the same data as their first argument.

## [Combine Functions into Transform](https://refactoring.com/catalog/combineFunctionsIntoTransform.html)

`combineFunctionsIntoTransform` · tags: basic, grouping-function, split-phase

Use it when several functions compute values from the same record, and callers need them together.

## [Consolidate Conditional Expression](https://refactoring.com/catalog/consolidateConditionalExpression.html)

`consolidateConditionalExpression` · tags: simplify-conditional-logic

Use it when several checks in a row give the same result.

## [Decompose Conditional](https://refactoring.com/catalog/decomposeConditional.html)

`decomposeConditional` · tags: simplify-conditional-logic

Use it when a condition and its branches are hard to read. A name for each would say what they mean.

Smells: Long Method.

## [Encapsulate Collection](https://refactoring.com/catalog/encapsulateCollection.html)

`encapsulateCollection` · tags: encapsulation

Use it when a getter gives out a collection that callers can change. The class has no add or remove of its own.

Smells: Data Class.

## [Encapsulate Record](https://refactoring.com/catalog/encapsulateRecord.html)

`encapsulateRecord` · older names: Replace Record with Data Class · tags: encapsulation

Use it when code across the system uses a plain data record, with no class around it.

## [Encapsulate Variable](https://refactoring.com/catalog/encapsulateVariable.html)

`encapsulateVariable` · older names: Encapsulate Field, Self-Encapsulate Field · tags: basic, encapsulation

Use it when code across the system reads and writes a variable directly, with no function around it.

Smells: Data Class.

## [Extract Class](https://refactoring.com/catalog/extractClass.html)

`extractClass` · inverse: Inline Class · tags: encapsulation, extract

Use it when some fields and methods of a class belong together, as a concept of their own.

Smells: Data Clumps, Divergent Change, Duplicated Code, Inappropriate Intimacy, Large Class, Primitive Obsession, Temporary Field.

## [Extract Function](https://refactoring.com/catalog/extractFunction.html)

`extractFunction` · older names: Extract Method · inverse: Inline Function · tags: basic, extract

Use it when a part of a function does one thing that a name can explain. Often a comment introduces that part.

Smells: Comments, Duplicated Code, Feature Envy, Long Method, Message Chains.

## [Extract Superclass](https://refactoring.com/catalog/extractSuperclass.html)

`extractSuperclass` · tags: dealing-with-inheritance, extract

Use it when two classes have the same features.

## [Extract Variable](https://refactoring.com/catalog/extractVariable.html)

`extractVariable` · older names: Introduce Explaining Variable · inverse: Inline Variable · tags: basic, extract, variables

Use it when an expression is hard to read, and names for its parts would explain it.

## [Hide Delegate](https://refactoring.com/catalog/hideDelegate.html)

`hideDelegate` · inverse: Remove Middle Man · tags: encapsulation, delegation

Use it when callers go through one object to get to another object.

Smells: Inappropriate Intimacy, Message Chains.

## [Inline Class](https://refactoring.com/catalog/inlineClass.html)

`inlineClass` · inverse: Extract Class · tags: encapsulation, inline

Use it when a class does too little to stand alone. The class that uses it can take its features.

Smells: Freeloader (Lazy Class), Shotgun Surgery, Speculative Generality.

## [Inline Function](https://refactoring.com/catalog/inlineFunction.html)

`inlineFunction` · older names: Inline Method · inverse: Extract Function · tags: basic, inline

Use it when the body of a function says as much as its name.

Smells: Middle Man.

## [Inline Variable](https://refactoring.com/catalog/inlineVariable.html)

`inlineVariable` · older names: Inline Temp · inverse: Extract Variable · tags: basic, inline, variables

Use it when the name of a variable says no more than the expression it holds.

## [Introduce Assertion](https://refactoring.com/catalog/introduceAssertion.html)

`introduceAssertion` · tags: simplify-conditional-logic, errors

Use it when code is correct only when a condition is true, and nothing states that condition.

Smells: Comments.

## [Introduce Parameter Object](https://refactoring.com/catalog/introduceParameterObject.html)

`introduceParameterObject` · tags: basic

Use it when the same group of parameters goes together to several functions.

Smells: Data Clumps, Long Method, Long Parameter List, Primitive Obsession.

## [Introduce Special Case](https://refactoring.com/catalog/introduceSpecialCase.html)

`introduceSpecialCase` · older names: Introduce Null Object · tags: simplify-conditional-logic

Use it when many places check for the same special value and do the same thing for it.

Smells: Conditional Complexity, Duplicated Code, Switch Statement, Temporary Field.

## [Move Field](https://refactoring.com/catalog/moveField.html)

`moveField` · tags: moving-features, variables

Use it when a field belongs with another class or record than the one that holds it.

Smells: Feature Envy, Inappropriate Intimacy, Parallel Inheritance Hierarchies, Shotgun Surgery.

## [Move Function](https://refactoring.com/catalog/moveFunction.html)

`moveFunction` · older names: Move Method · tags: moving-features, grouping-function

Use it when a function belongs with another class or module than the one that holds it.

Smells: Alternative Classes with Different Interfaces, Data Class, Feature Envy, Inappropriate Intimacy, Message Chains, Parallel Inheritance Hierarchies, Shotgun Surgery.

## [Move Statements into Function](https://refactoring.com/catalog/moveStatementsIntoFunction.html)

`moveStatementsIntoFunction` · inverse: Move Statements to Callers · tags: moving-features, fragments

Use it when the same statements come next to each call of a function.

## [Move Statements to Callers](https://refactoring.com/catalog/moveStatementsToCallers.html)

`moveStatementsToCallers` · inverse: Move Statements into Function · tags: moving-features, fragments

Use it when a function does a part of its work that some callers must do in another way.

## [Parameterize Function](https://refactoring.com/catalog/parameterizeFunction.html)

`parameterizeFunction` · older names: Parameterize Method · tags: refactoring-apis

Use it when several functions do the same thing, and only a value is different.

## [Preserve Whole Object](https://refactoring.com/catalog/preserveWholeObject.html)

`preserveWholeObject` · tags: refactoring-apis, parameters

Use it when code takes values out of an object only to give them to a function together.

Smells: Data Clumps, Long Method, Long Parameter List.

## [Pull Up Constructor Body](https://refactoring.com/catalog/pullUpConstructorBody.html)

`pullUpConstructorBody` · tags: dealing-with-inheritance

Use it when the constructors of subclasses set the same fields.

## [Pull Up Field](https://refactoring.com/catalog/pullUpField.html)

`pullUpField` · inverse: Push Down Field · tags: dealing-with-inheritance, variables

Use it when subclasses declare the same field.

Smells: Duplicated Code.

## [Pull Up Method](https://refactoring.com/catalog/pullUpMethod.html)

`pullUpMethod` · inverse: Push Down Method · tags: dealing-with-inheritance

Use it when subclasses have the same method.

Smells: Duplicated Code.

## [Push Down Field](https://refactoring.com/catalog/pushDownField.html)

`pushDownField` · inverse: Pull Up Field · tags: dealing-with-inheritance, variables

Use it when only one subclass uses a field of the superclass.

Smells: Refused Bequest.

## [Push Down Method](https://refactoring.com/catalog/pushDownMethod.html)

`pushDownMethod` · inverse: Pull Up Method · tags: dealing-with-inheritance

Use it when only one subclass uses a method of the superclass.

Smells: Refused Bequest.

## [Remove Dead Code](https://refactoring.com/catalog/removeDeadCode.html)

`removeDeadCode` · tags: moving-features, remove

Use it when code never runs, or nothing uses what it gives.

## [Remove Flag Argument](https://refactoring.com/catalog/removeFlagArgument.html)

`removeFlagArgument` · older names: Replace Parameter with Explicit Methods · tags: refactoring-apis, remove

Use it when a caller gives an argument only to select which branch of the function runs.

Smells: Switch Statement.

## [Remove Middle Man](https://refactoring.com/catalog/removeMiddleMan.html)

`removeMiddleMan` · inverse: Hide Delegate · tags: encapsulation, delegation, inline, remove

Use it when a class does little more than send calls on to another class.

Smells: Middle Man.

## [Remove Setting Method](https://refactoring.com/catalog/removeSettingMethod.html)

`removeSettingMethod` · tags: refactoring-apis, parameters, immutability, remove

Use it when a field has a setter, but the field must not change after the object exists.

## [Remove Subclass](https://refactoring.com/catalog/removeSubclass.html)

`removeSubclass` · older names: Replace Subclass with Fields · inverse: Replace Type Code with Subclasses · tags: dealing-with-inheritance, remove

Use it when subclasses are different only in a value they return.

## [Rename Field](https://refactoring.com/catalog/renameField.html)

`renameField` · tags: organizing-data, rename, variables

Use it when the name of a field does not say what it holds.

## [Rename Variable](https://refactoring.com/catalog/renameVariable.html)

`renameVariable` · tags: basic, rename, variables

Use it when the name of a variable does not say what it holds.

## [Replace Command with Function](https://refactoring.com/catalog/replaceCommandWithFunction.html)

`replaceCommandWithFunction` · inverse: Replace Function with Command · tags: refactoring-apis

Use it when a command object only keeps its arguments and does one short calculation.

## [Replace Conditional with Polymorphism](https://refactoring.com/catalog/replaceConditionalWithPolymorphism.html)

`replaceConditionalWithPolymorphism` · tags: simplify-conditional-logic

Use it when a switch or a chain of checks on a type selects the behavior. Each case can be its own class.

Smells: Switch Statement.

## [Replace Constructor with Factory Function](https://refactoring.com/catalog/replaceConstructorWithFactoryFunction.html)

`replaceConstructorWithFactoryFunction` · older names: Replace Constructor with Factory Method · tags: refactoring-apis, grouping-function

Use it when a constructor call needs a special code or a better name than the class gives.

## [Replace Control Flag with Break](https://refactoring.com/catalog/replaceControlFlagWithBreak.html)

`replaceControlFlagWithBreak` · older names: Remove Control Flag · tags: simplify-conditional-logic

Use it when a flag variable only stops a loop from doing more work.

## [Replace Derived Variable with Query](https://refactoring.com/catalog/replaceDerivedVariableWithQuery.html)

`replaceDerivedVariableWithQuery` · tags: organizing-data

Use it when code keeps a stored value in step with other data by hand. It can calculate the value from that data.

## [Replace Error Code with Exception](https://refactoring.com/catalog/replaceErrorCodeWithException.html)

`replaceErrorCodeWithException` · tags: refactoring-apis, errors

Use it when a function returns a special code to report an error.

## [Replace Exception with Precheck](https://refactoring.com/catalog/replaceExceptionWithPrecheck.html)

`replaceExceptionWithPrecheck` · older names: Replace Exception with Test · tags: refactoring-apis, errors

Use it when code catches an exception for a case that a simple check can find first.

## [Replace Function with Command](https://refactoring.com/catalog/replaceFunctionWithCommand.html)

`replaceFunctionWithCommand` · older names: Replace Method with Method Object · inverse: Replace Command with Function · tags: refactoring-apis

Use it when a long function has many local variables, and fields of an object would let you divide it.

Smells: Long Method.

## [Replace Inline Code with Function Call](https://refactoring.com/catalog/replaceInlineCodeWithFunctionCall.html)

`replaceInlineCodeWithFunctionCall` · tags: moving-features

Use it when code does by hand what a library or language function already does.

## [Replace Loop with Pipeline](https://refactoring.com/catalog/replaceLoopWithPipeline.html)

`replaceLoopWithPipeline` · tags: moving-features, collections

Use it when a loop filters, maps or collects items, which a chain of collection operations can state.

## [Replace Magic Literal](https://refactoring.com/catalog/replaceMagicLiteral.html)

`replaceMagicLiteral` · older names: Replace Magic Number with Symbolic Constant · tags: organizing-data, variables

Use it when a literal value in the code has a meaning that a name would state.

## [Replace Nested Conditional with Guard Clauses](https://refactoring.com/catalog/replaceNestedConditionalWithGuardClauses.html)

`replaceNestedConditionalWithGuardClauses` · tags: simplify-conditional-logic

Use it when nested conditions hide that most branches are special cases that end the function.

## [Replace Parameter with Query](https://refactoring.com/catalog/replaceParameterWithQuery.html)

`replaceParameterWithQuery` · older names: Replace Parameter with Method · inverse: Replace Query with Parameter · tags: refactoring-apis, parameters

Use it when a caller gives a value that the function can get from another argument.

Smells: Long Parameter List.

## [Replace Primitive with Object](https://refactoring.com/catalog/replacePrimitiveWithObject.html)

`replacePrimitiveWithObject` · older names: Replace Data Value with Object, Replace Type Code with Class · tags: encapsulation

Use it when a string or a number stands for a concept with rules of its own.

Smells: Large Class, Primitive Obsession.

## [Replace Query with Parameter](https://refactoring.com/catalog/replaceQueryWithParameter.html)

`replaceQueryWithParameter` · inverse: Replace Parameter with Query · tags: refactoring-apis, parameters

Use it when a function reads a value from outside state that the caller can give it.

## [Replace Subclass with Delegate](https://refactoring.com/catalog/replaceSubclassWithDelegate.html)

`replaceSubclassWithDelegate` · tags: dealing-with-inheritance, delegation

Use it when a subclass changes one part of the behavior. An object that the class holds can carry that part.

## [Replace Superclass with Delegate](https://refactoring.com/catalog/replaceSuperclassWithDelegate.html)

`replaceSuperclassWithDelegate` · older names: Replace Inheritance with Delegation · tags: dealing-with-inheritance, delegation

Use it when a class inherits operations from its superclass that it must not offer.

Smells: Inappropriate Intimacy, Refused Bequest.

## [Replace Temp with Query](https://refactoring.com/catalog/replaceTempWithQuery.html)

`replaceTempWithQuery` · tags: encapsulation, variables

Use it when a local variable keeps a calculated value that a method can give.

Smells: Long Method.

## [Replace Type Code with Subclasses](https://refactoring.com/catalog/replaceTypeCodeWithSubclasses.html)

`replaceTypeCodeWithSubclasses` · older names: Extract Subclass, Replace Type Code with State/Strategy · inverse: Remove Subclass · tags: dealing-with-inheritance, variables

Use it when a type code selects the behavior of an object.

Smells: Large Class, Primitive Obsession, Switch Statement.

## [Return Modified Value](https://refactoring.com/catalog/returnModifiedValue.html)

`returnModifiedValue` · tags: refactoring-apis, immutability

Use it when a function changes a variable outside it, when it can return the value.

## [Separate Query from Modifier](https://refactoring.com/catalog/separateQueryFromModifier.html)

`separateQueryFromModifier` · tags: refactoring-apis, immutability

Use it when a function returns a value and also changes something.

## [Slide Statements](https://refactoring.com/catalog/slideStatements.html)

`slideStatements` · older names: Consolidate Duplicate Conditional Fragments · tags: moving-features, fragments

Use it when statements that belong together have other statements between them.

## [Split Loop](https://refactoring.com/catalog/splitLoop.html)

`splitLoop` · tags: moving-features, collections

Use it when one loop does two things that do not depend on each other.

## [Split Phase](https://refactoring.com/catalog/splitPhase.html)

`splitPhase` · tags: moving-features, split-phase

Use it when code mixes two stages, such as reading the input and calculating with it.

## [Split Variable](https://refactoring.com/catalog/splitVariable.html)

`splitVariable` · older names: Remove Assignments to Parameters, Split Temp · tags: organizing-data, variables

Use it when one variable holds different things at different times.

## [Substitute Algorithm](https://refactoring.com/catalog/substituteAlgorithm.html)

`substituteAlgorithm` · tags: encapsulation

Use it when a clearer way to calculate the same result exists.

Smells: Duplicated Code.
