---
title: "Dagger with Codelab #1"
date: 2019-11-22T00:09:03+09:00
draft: false
tags: [Android, codelab, dagger, di]
---

[Dagger CodeLab](https://codelabs.developers.google.com/codelabs/android-dagger/index.html?index=..%2F..ads19#0)을 하면서 공부한 내용을 요약, 정리

## 1. Dagger 설정

```groovy
dependencies {
    def dagger_version = "2.25.2"
    implementation "com.google.dagger:dagger:$dagger_version"
    kapt "com.google.dagger:dagger-compiler:$dagger_version"
}
```
`app/build.gradle`에 위와 같이 dagger 관련 depency 설정을 추가.

## 2. @Inject

> In order to build the application graph automatically for us, Dagger needs to know how to create instances for the classes in the graph. One way to do this is by annotating the constructor of classes with @Inject. The constructor parameters will be the dependencies of that type.

Dagger가 그래프를 만들기 위해서 각 클래스들의 객체를 어떻게 생성하는지 알아야 하는데, 이 방법 중에 하나가 바로 `@Inject`를 생성자에 annotating 하는 것이다.  
생성자 파라미터는 그 타입의 의존성이 될 것이다.

```kotlin
// @Inject tells Dagger how to provide instances of this type
// Dagger also knows that UserManager is a dependency
class RegistrationViewModel @Inject constructor(val userManager: UserManager) {
    ...
}
``` 
- dagger 가 `RegistrationViewModel` 객체를 어떻게 생성해야 하는지 안다.
- `RegistrationViewModel` 이 `UserManager`에 의존성이 있는지 안다.

## 3. @Component

> We want Dagger to create the graph of dependencies of our project, manage them for us and be able to get dependencies from the graph. To make Dagger do it, we need to create an interface and annotate it with @Component. Dagger will create a Container as we would have done with manual dependency injection.

Dagger가 의존성의 그래프를 생성하고, manage하고, 그래프로부터 의존성을 가져오게 하기 위해서 `@Commponent`가 붙은 interface를 생성해야 한다.  
Dagger는 직접 의존성을 주입하는 것과 같은 일을 하는 `Container`를 생성할 것이다.

```kotlin
// Definition of a Dagger component
@Component
interface AppComponent {
    // Classes that can be injected by this Component
    fun inject(activity: RegistrationActivity)
}
```

- `fun inject(activity: RegistrationActivity)` method는 Dagger에게`RegistratinActivity`가 의존성 주입을 요청하고 필요한 의존성을 제공해야 한다고 알려주는 것이다.
- `@Component` interface는 `Compile-time`에 그래프를 생성하는데 필요한 정보를 준다. interface method의 parameter는 어떤 클래스가 주입을 요청하는지 정의한다.

## 4. @Module, @BindsInstance, @Binds

> Another way to tell Dagger how to provide instances of a type is with information in Dagger Modules. A Dagger Module is a class that is annotated with @Module. There, you can define how to provide dependencies with the @Provides or @Binds annotations.

Dagger에게 타입의 객체를 전달하는 방법을 알려줄 수 있는 또 다른 방법이 `Dagger Module`이다. `Dagger Module`은 `@Module` 어노테이션이 붙은 클래스이다.  
`@Provide`와 `@Binds`를 사용해서 어떻게 의존성을 제공할 수 있는지 정의 할 수 있다.

- `StorageModule`은 `storage`에 대한 정보를 가지고 있는 모듈이다.
- `@Binds` 어노테이션을 사용해서 Dagger에게 어떠한 interface를 제공하기 위한 구현체를 알려 줄 수 있다.
- `@Binds` 어노테이션은 반드시 추상화 함수에 사용되어야 한다.

```kotlin
// Tells Dagger this is a Dagger module
// Because of @Binds, StorageModule needs to be an abstract class
@Module
abstract class StorageModule {

    // Makes Dagger provide SharedPreferencesStorage when a Storage type is requested
    @Binds
    abstract fun provideStorage(storage: SharedPreferencesStorage): Storage
}

// @Inject tells Dagger how to provide instances of this type
class SharedPreferencesStorage @Inject constructor(context: Context) : Storage { ... }

// Definition of a Dagger component that adds info from the StorageModule to the graph
@Component(modules = [StorageModule::class])
interface AppComponent {
    
    // Classes that can be injected by this Component
    fun inject(activity: RegistrationActivity)
}
```

- `Storage` interface와 `SharedPreferenceStorage`를 연결시켰다.
- `AppComponent`에 'StorageMolue`를 포함시켜서 `AppComponent`에서 `StorageModule`의 정보에 접근 할 수 있다.

Dagger 그래프 밖에서 생생되거나, `Context`처럼 `Andorid`에서 제공하는 것들을 제공해 주려면 `Component Factory`와 `@BindsInstance`를 사용해야 한다.

```kotlin

@Component(modules = [StorageModule::class])
interface AppComponent {

    // Factory to create instances of the AppComponent
    @Component.Factory
    interface Factory {
        // With @BindsInstance, the Context passed in will be available in the graph
        fun create(@BindsInstance context: Context): AppComponent
    }
}
```

- `@Component.Factory` 어노테이션이 붙은 interface는 `Appcomponent` 를 리턴하고 `@BindsInstace`가 붙은 `Context`를 파라미터로 받는 함수를 가지고 있다. 
- `@BindsInstance`는 Dagger에세 그래프에 `Context`를 추가할 필요가 있고, `Context`가 필요할 때마다 이 객체를 제공하라고 알려준다.
  
  
나머지 내용은 다음 포스트에서
