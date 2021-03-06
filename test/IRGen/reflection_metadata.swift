// RUN: %target-swift-frontend -enable-reflection-metadata -enable-reflection-names -emit-ir %s | FileCheck %s
// RUN: %target-swift-frontend -enable-reflection-metadata -emit-ir %s | FileCheck %s --check-prefix=STRIP_REFLECTION_NAMES
// RUN: %target-swift-frontend -emit-ir %s | FileCheck %s --check-prefix=STRIP_REFLECTION_METADATA

// STRIP_REFLECTION_NAMES_DAG: {{.*}}swift3_reflect
// STRIP_REFLECTION_NAMES_DAG: {{.*}}swift3_fieldmd
// STRIP_REFLECTION_NAMES_DAG: {{.*}}swift3_assocty
// STRIP_REFLECTION_NAMES-DAG: {{.*}}swift3_capture
// STRIP_REFLECTION_NAMES-DAG: {{.*}}swift3_typeref
// STRIP_REFLECTION_NAMES-NOT: {{.*}}swift3_reflstr
// STRIP_REFLECTION_NAMES-NOT: {{.*}}swift3_builtin

// STRIP_REFLECTION_NAMES-DAG: @"\01l__swift3_reflection_metadata"

// STRIP_REFLECTION_METADATA-NOT: {{.*}}swift3_reflect
// STRIP_REFLECTION_METADATA-NOT: {{.*}}swift3_fieldmd
// STRIP_REFLECTION_METADATA-NOT: {{.*}}swift3_assocty
// STRIP_REFLECTION_METADATA-NOT: {{.*}}swift3_capture
// STRIP_REFLECTION_METADATA-NOT: {{.*}}swift3_typeref
// STRIP_REFLECTION_METADATA-NOT: {{.*}}swift3_reflstr
// STRIP_REFLECTION_METADATA-NOT: {{.*}}swift3_builtin

// STRIP_REFLECTION_METADATA-NOT: @"\01l__swift3_reflection_metadata"

// CHECK-DAG: private constant [2 x i8] c"i\00", section "{{[^"]*}}swift3_reflstr{{[^"]*}}"
// CHECK-DAG: private constant [3 x i8] c"ms\00", section "{{[^"]*}}swift3_reflstr{{[^"]*}}"
// CHECK-DAG: private constant [3 x i8] c"me\00", section "{{[^"]*}}swift3_reflstr{{[^"]*}}"
// CHECK-DAG: private constant [3 x i8] c"mc\00", section "{{[^"]*}}swift3_reflstr{{[^"]*}}"
// CHECK-DAG: private constant [2 x i8] c"C\00", section "{{[^"]*}}swift3_reflstr{{[^"]*}}"
// CHECK-DAG: private constant [2 x i8] c"S\00", section "{{[^"]*}}swift3_reflstr{{[^"]*}}"
// CHECK-DAG: private constant [2 x i8] c"E\00", section "{{[^"]*}}swift3_reflstr{{[^"]*}}"
// CHECK-DAG: private constant [2 x i8] c"I\00", section "{{[^"]*}}swift3_reflstr{{[^"]*}}"
// CHECK-DAG: private constant [2 x i8] c"t\00", section "{{[^"]*}}swift3_reflstr{{[^"]*}}"
// CHECK-DAG: private constant [4 x i8] c"mgs\00", section "{{[^"]*}}swift3_reflstr{{[^"]*}}"
// CHECK-DAG: private constant [4 x i8] c"mge\00", section "{{[^"]*}}swift3_reflstr{{[^"]*}}"
// CHECK-DAG: private constant [4 x i8] c"mgc\00", section "{{[^"]*}}swift3_reflstr{{[^"]*}}"
// CHECK-DAG: private constant [3 x i8] c"GC\00", section "{{[^"]*}}swift3_reflstr{{[^"]*}}"
// CHECK-DAG: private constant [3 x i8] c"GS\00", section "{{[^"]*}}swift3_reflstr{{[^"]*}}"
// CHECK-DAG: private constant [3 x i8] c"GE\00", section "{{[^"]*}}swift3_reflstr{{[^"]*}}"

// CHECK: @"\01l__swift3_reflection_metadata{{.*}}" = private constant <{ {{.*}} }>

public protocol MyProtocol {
  associatedtype Inner
  var inner: Inner { get }
}

public class MyClass {
  let i: Int
  let ms: MyStruct
  let me: MyEnum
  public init(i: Int, ms: MyStruct, me: MyEnum) {
    self.i = i
    self.ms = ms
    self.me = me
  }
}

public struct Conformance : MyProtocol {
  public var inner: Int = 0
}

public struct MyStruct {
  let i: Int
  let mc: MyClass
  let me: MyEnum
}

public enum MyEnum {
  case C(MyClass)
  indirect case S(MyStruct)
  indirect case E(MyEnum)
  case I(Int)
}

public class MyGenericClass<T : MyProtocol> {
  let t: T
  let i: T.Inner
  let mgs: MyGenericStruct<T>
  let mge: MyGenericEnum<T>

  public init(t: T, i: T.Inner, mgs: MyGenericStruct<T>, mge: MyGenericEnum<T>) {
    self.t = t
    self.i = i
    self.mgs = mgs
    self.mge = mge
  }
}

public struct MyGenericStruct<T : MyProtocol> {
  let t: T
  let i: T.Inner
  let mgc: MyGenericClass<T>
  let mge: MyGenericEnum<T>
}

public enum MyGenericEnum<T : MyProtocol> {
  case GC(MyGenericClass<T>)
  indirect case GS(MyGenericStruct<T>)
  indirect case GE(MyGenericEnum<T>)
  case I(Int)
}

public func makeSomeClosures<T, U>(t: T, x: Int, y: MyGenericStruct<U>)
    -> (() -> (), () -> (), () -> ()) {
  return ({ _ = t }, { _ = x }, { _ = y })
}
