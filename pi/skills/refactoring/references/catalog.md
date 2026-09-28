# The refactoring catalog

The 66 refactorings of the second edition of Martin Fowler's *Refactoring*,
as listed at https://refactoring.com/catalog/ on 2026-09-26. Each name links
to its page, which shows the motivation, the mechanics and an example.

The id is the value of the `Refactoring:` commit trailer. Older names are
the names the first edition and other sources use, so a smell that names an
old refactoring still leads here.

| Refactoring | Id | Older names | Tags |
|---|---|---|---|
| [Change Function Declaration](https://refactoring.com/catalog/changeFunctionDeclaration.html) | `changeFunctionDeclaration` | Add Parameter, Change Signature, Remove Parameter, Rename Function, Rename Method | basic, rename |
| [Change Reference to Value](https://refactoring.com/catalog/changeReferenceToValue.html) | `changeReferenceToValue` |  | organizing-data, variables |
| [Change Value to Reference](https://refactoring.com/catalog/changeValueToReference.html) | `changeValueToReference` |  | organizing-data, immutability, variables |
| [Collapse Hierarchy](https://refactoring.com/catalog/collapseHierarchy.html) | `collapseHierarchy` |  | dealing-with-inheritance |
| [Combine Functions into Class](https://refactoring.com/catalog/combineFunctionsIntoClass.html) | `combineFunctionsIntoClass` |  | basic, encapsulation, grouping-function |
| [Combine Functions into Transform](https://refactoring.com/catalog/combineFunctionsIntoTransform.html) | `combineFunctionsIntoTransform` |  | basic, grouping-function, split-phase |
| [Consolidate Conditional Expression](https://refactoring.com/catalog/consolidateConditionalExpression.html) | `consolidateConditionalExpression` |  | simplify-conditional-logic |
| [Decompose Conditional](https://refactoring.com/catalog/decomposeConditional.html) | `decomposeConditional` |  | simplify-conditional-logic |
| [Encapsulate Collection](https://refactoring.com/catalog/encapsulateCollection.html) | `encapsulateCollection` |  | encapsulation |
| [Encapsulate Record](https://refactoring.com/catalog/encapsulateRecord.html) | `encapsulateRecord` | Replace Record with Data Class | encapsulation |
| [Encapsulate Variable](https://refactoring.com/catalog/encapsulateVariable.html) | `encapsulateVariable` | Encapsulate Field, Self-Encapsulate Field | basic, encapsulation |
| [Extract Class](https://refactoring.com/catalog/extractClass.html) | `extractClass` |  | encapsulation, extract |
| [Extract Function](https://refactoring.com/catalog/extractFunction.html) | `extractFunction` | Extract Method | basic, extract |
| [Extract Superclass](https://refactoring.com/catalog/extractSuperclass.html) | `extractSuperclass` |  | dealing-with-inheritance, extract |
| [Extract Variable](https://refactoring.com/catalog/extractVariable.html) | `extractVariable` | Introduce Explaining Variable | basic, extract, variables |
| [Hide Delegate](https://refactoring.com/catalog/hideDelegate.html) | `hideDelegate` |  | encapsulation, delegation |
| [Inline Class](https://refactoring.com/catalog/inlineClass.html) | `inlineClass` |  | encapsulation, inline |
| [Inline Function](https://refactoring.com/catalog/inlineFunction.html) | `inlineFunction` | Inline Method | basic, inline |
| [Inline Variable](https://refactoring.com/catalog/inlineVariable.html) | `inlineVariable` | Inline Temp | basic, inline, variables |
| [Introduce Assertion](https://refactoring.com/catalog/introduceAssertion.html) | `introduceAssertion` |  | simplify-conditional-logic, errors |
| [Introduce Parameter Object](https://refactoring.com/catalog/introduceParameterObject.html) | `introduceParameterObject` |  | basic |
| [Introduce Special Case](https://refactoring.com/catalog/introduceSpecialCase.html) | `introduceSpecialCase` | Introduce Null Object | simplify-conditional-logic |
| [Move Field](https://refactoring.com/catalog/moveField.html) | `moveField` |  | moving-features, variables |
| [Move Function](https://refactoring.com/catalog/moveFunction.html) | `moveFunction` | Move Method | moving-features, grouping-function |
| [Move Statements into Function](https://refactoring.com/catalog/moveStatementsIntoFunction.html) | `moveStatementsIntoFunction` |  | moving-features, fragments |
| [Move Statements to Callers](https://refactoring.com/catalog/moveStatementsToCallers.html) | `moveStatementsToCallers` |  | moving-features, fragments |
| [Parameterize Function](https://refactoring.com/catalog/parameterizeFunction.html) | `parameterizeFunction` | Parameterize Method | refactoring-apis |
| [Preserve Whole Object](https://refactoring.com/catalog/preserveWholeObject.html) | `preserveWholeObject` |  | refactoring-apis, parameters |
| [Pull Up Constructor Body](https://refactoring.com/catalog/pullUpConstructorBody.html) | `pullUpConstructorBody` |  | dealing-with-inheritance |
| [Pull Up Field](https://refactoring.com/catalog/pullUpField.html) | `pullUpField` |  | dealing-with-inheritance, variables |
| [Pull Up Method](https://refactoring.com/catalog/pullUpMethod.html) | `pullUpMethod` |  | dealing-with-inheritance |
| [Push Down Field](https://refactoring.com/catalog/pushDownField.html) | `pushDownField` |  | dealing-with-inheritance, variables |
| [Push Down Method](https://refactoring.com/catalog/pushDownMethod.html) | `pushDownMethod` |  | dealing-with-inheritance |
| [Remove Dead Code](https://refactoring.com/catalog/removeDeadCode.html) | `removeDeadCode` |  | moving-features, remove |
| [Remove Flag Argument](https://refactoring.com/catalog/removeFlagArgument.html) | `removeFlagArgument` | Replace Parameter with Explicit Methods | refactoring-apis, remove |
| [Remove Middle Man](https://refactoring.com/catalog/removeMiddleMan.html) | `removeMiddleMan` |  | encapsulation, delegation, inline, remove |
| [Remove Setting Method](https://refactoring.com/catalog/removeSettingMethod.html) | `removeSettingMethod` |  | refactoring-apis, parameters, immutability, remove |
| [Remove Subclass](https://refactoring.com/catalog/removeSubclass.html) | `removeSubclass` | Replace Subclass with Fields | dealing-with-inheritance, remove |
| [Rename Field](https://refactoring.com/catalog/renameField.html) | `renameField` |  | organizing-data, rename, variables |
| [Rename Variable](https://refactoring.com/catalog/renameVariable.html) | `renameVariable` |  | basic, rename, variables |
| [Replace Command with Function](https://refactoring.com/catalog/replaceCommandWithFunction.html) | `replaceCommandWithFunction` |  | refactoring-apis |
| [Replace Conditional with Polymorphism](https://refactoring.com/catalog/replaceConditionalWithPolymorphism.html) | `replaceConditionalWithPolymorphism` |  | simplify-conditional-logic |
| [Replace Constructor with Factory Function](https://refactoring.com/catalog/replaceConstructorWithFactoryFunction.html) | `replaceConstructorWithFactoryFunction` | Replace Constructor with Factory Method | refactoring-apis, grouping-function |
| [Replace Control Flag with Break](https://refactoring.com/catalog/replaceControlFlagWithBreak.html) | `replaceControlFlagWithBreak` | Remove Control Flag | simplify-conditional-logic |
| [Replace Derived Variable with Query](https://refactoring.com/catalog/replaceDerivedVariableWithQuery.html) | `replaceDerivedVariableWithQuery` |  | organizing-data |
| [Replace Error Code with Exception](https://refactoring.com/catalog/replaceErrorCodeWithException.html) | `replaceErrorCodeWithException` |  | refactoring-apis, errors |
| [Replace Exception with Precheck](https://refactoring.com/catalog/replaceExceptionWithPrecheck.html) | `replaceExceptionWithPrecheck` | Replace Exception with Test | refactoring-apis, errors |
| [Replace Function with Command](https://refactoring.com/catalog/replaceFunctionWithCommand.html) | `replaceFunctionWithCommand` | Replace Method with Method Object | refactoring-apis |
| [Replace Inline Code with Function Call](https://refactoring.com/catalog/replaceInlineCodeWithFunctionCall.html) | `replaceInlineCodeWithFunctionCall` |  | moving-features |
| [Replace Loop with Pipeline](https://refactoring.com/catalog/replaceLoopWithPipeline.html) | `replaceLoopWithPipeline` |  | moving-features, collections |
| [Replace Magic Literal](https://refactoring.com/catalog/replaceMagicLiteral.html) | `replaceMagicLiteral` | Replace Magic Number with Symbolic Constant | organizing-data, variables |
| [Replace Nested Conditional with Guard Clauses](https://refactoring.com/catalog/replaceNestedConditionalWithGuardClauses.html) | `replaceNestedConditionalWithGuardClauses` |  | simplify-conditional-logic |
| [Replace Parameter with Query](https://refactoring.com/catalog/replaceParameterWithQuery.html) | `replaceParameterWithQuery` | Replace Parameter with Method | refactoring-apis, parameters |
| [Replace Primitive with Object](https://refactoring.com/catalog/replacePrimitiveWithObject.html) | `replacePrimitiveWithObject` | Replace Data Value with Object, Replace Type Code with Class | encapsulation |
| [Replace Query with Parameter](https://refactoring.com/catalog/replaceQueryWithParameter.html) | `replaceQueryWithParameter` |  | refactoring-apis, parameters |
| [Replace Subclass with Delegate](https://refactoring.com/catalog/replaceSubclassWithDelegate.html) | `replaceSubclassWithDelegate` |  | dealing-with-inheritance, delegation |
| [Replace Superclass with Delegate](https://refactoring.com/catalog/replaceSuperclassWithDelegate.html) | `replaceSuperclassWithDelegate` | Replace Inheritance with Delegation | dealing-with-inheritance, delegation |
| [Replace Temp with Query](https://refactoring.com/catalog/replaceTempWithQuery.html) | `replaceTempWithQuery` |  | encapsulation, variables |
| [Replace Type Code with Subclasses](https://refactoring.com/catalog/replaceTypeCodeWithSubclasses.html) | `replaceTypeCodeWithSubclasses` | Extract Subclass, Replace Type Code with State/Strategy | dealing-with-inheritance, variables |
| [Return Modified Value](https://refactoring.com/catalog/returnModifiedValue.html) | `returnModifiedValue` |  | refactoring-apis, immutability |
| [Separate Query from Modifier](https://refactoring.com/catalog/separateQueryFromModifier.html) | `separateQueryFromModifier` |  | refactoring-apis, immutability |
| [Slide Statements](https://refactoring.com/catalog/slideStatements.html) | `slideStatements` | Consolidate Duplicate Conditional Fragments | moving-features, fragments |
| [Split Loop](https://refactoring.com/catalog/splitLoop.html) | `splitLoop` |  | moving-features, collections |
| [Split Phase](https://refactoring.com/catalog/splitPhase.html) | `splitPhase` |  | moving-features, split-phase |
| [Split Variable](https://refactoring.com/catalog/splitVariable.html) | `splitVariable` | Remove Assignments to Parameters, Split Temp | organizing-data, variables |
| [Substitute Algorithm](https://refactoring.com/catalog/substituteAlgorithm.html) | `substituteAlgorithm` |  | encapsulation |
