---
title: "Dagger With Codelab #2"
date: 2019-11-26T18:20:23+09:00
draft: false
tags: [Android, codelab, dagger, di]
---

[Dagger CodeLab](https://codelabs.developers.google.com/codelabs/android-dagger/index.html?index=..%2F..ads19#0)을 하면서 공부한 내용을 요약, 정리

## 1. Injecting the graph in an Activity

보통 Dagger 그래프는 Application 클래스 안에서 생성한다. 앱이 실행되는 동안 메모리에 그래프의 객체가 존재하길 원하기 때문이다.
이런 방법으로 그래프는 앱의 lifecycle에 종속되게 된다.

```kotlin
open class MyApplication : Application() {

    // Instance of the AppComponent that will be used by all the Activities in the project
    val appComponent: AppComponent by lazy {
        // Creates an instance of AppComponent using its Factory constructor
        // We pass the applicationContext that will be used as Context in the graph
        DaggerAppComponent.factory().create(applicationContext)
    }

    open val userManager by lazy {
        UserManager(SharedPreferencesStorage(this))
    }
}
```

- Dagger는 `AppComponent` 그래프 구현을 포함하고 있는 `DaggerAppComponent`를 만든다.
- 이 전에 정의한 `@Component.Factory` 어노테이션이 붙였던 interface가 `DaggerAppComponent`에서 static method로 `.factory()`로 생성되었다.
- `create` method를 통해서 `context`를 전달할 수 있다.

***Build를 해야지 `Dagger annotation processor`에 의해서 `DaggerComponent`가 만들어진다.***  

```kotlin
class RegistrationActivity : AppCompatActivity() {

    // @Inject annotated fields will be provided by Dagger
    @Inject
    lateinit var registrationViewModel: RegistrationViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        // Grabs instance of the application graph
        // and populates @Inject fields with objects from the graph
        (application as MyApplication).appComponent.inject(this)

        super.onCreate(savedInstanceState)
        ...
    }
```

- `RegistrationActivity`에서 그래프의 인스턴스를 사용해서 `@Inject` 어노테이션이 붙은 필드를 Dagger가 주입하게 할 수 있다.
- `appcomponent.inject(this)`를 호출함으로써 Dagger로부터 `RegistrationViewModel`을 주입받을 수 있다.


***Activity에서 Dagger를 사용할 때 fragment의 복구 이슈를 피하기 위해서는 `onCreate`메소드에서 `super.onCreate` 를 호출하기 전에 `inject`를 해야한다.  
`super.onCreate`에서 복구하는 중에 activity에 접근하려는 fragment를 attach 할 수도 있기 때문이다.***

## 2. Using Scopes

`Component`에서 `Unique 객체`를 갖기 위해서는 `Scope`을 사용해야 한다. Component lifecycle에 타입의 범위를 지정 한다는 것은 그 타입의 동일한 객체가 타입이 제공되어야 할 때마다 사용되어 진다는 것을 의미한다.

```kotlin
@Singleton
@Component(modules = [StorageModule::class])
interface AppComponent { ... }
```

- `@Singleton` 어노테이션을 Component에 붙이면, `@Singleton` 어노테이션이 붙은 다른 클래스들은 어노테이션이 붙은 Component로 범위가 지정된다.

```kotlin
@Singleton
class UserManager @Inject constructor(private val storage: Storage) {
    ...
}
```

- `@Singleton` 어노테이션이 붙은 `UserManager` 객체는 application 그래프에서 unique한 객체를 갖게 된다.

## 3. Subcomponents

***Activity에서는 `onCreate`안에서 `super` 전에 inject를 하고 Fragment에서는 `onAttach`안에서 `super` 이 후에 inject를 해라.***

`RegistrationViewModel`을 사용하는 클래스 `RegistrationActivity`, `EnterDetailFragment`, `TermsAndConditionsFragment`에서 모두 주입을 받을 경우 동일한 객체를 사용하기 위해서 `SubComponents`를 사용한다.

- `RegistrationViewModel`을 `@Singleton`으로 사용할 수 있지만, 다른 문제가 발생한다.
    - `Registration` 과정이 끝난 후에도 `RegistrationViewModel`이 메모리에 남아있게 된다.
    - 서로 다른 `Registration` 과정에서는 다른 `RegistrationViewModel` 객체를 사용하길 원한다. 즉, 이 전 `Registration`과정에서 사용한 데이터가 현재 `Registration`에 영향을 미치지 않길 원한다.

`RegistrationFragment`에서 `RegistrationActivity`와 동일한 `ViewModel`을 사용하길 원하고, `RegistrationActivity`가 변경되었을 때 다른 `ViewModel`객체를 사용하길 원한다. `RegistrationViewModel`의 범위가 `RegistrationActivity` 에 종속이 되길 원할 때 `SubComponents`를 사용한다.

`SubComponents`는 parent component의 그래프를 extend하고 상속을 받는 component다. 그래서 parent component가 제공받는 모든 객체를 subcomponent도 제공받을 수 있다.
이런 방식으로 subcomponent의 객체는 parent component에 의해 제공되는 객체에 의존할 수 있다.

```kotlin
// Definition of a Dagger subcomponent
@Subcomponent
interface RegistrationComponent {

    // Factory to create instances of RegistrationComponent
    @Subcomponent.Factory
    interface Factory {
        fun create(): RegistrationComponent
    }

    // Classes that can be injected by this Component
    fun inject(activity: RegistrationActivity)
    fun inject(fragment: EnterDetailsFragment)
    fun inject(fragment: TermsAndConditionsFragment)
}
```

```kotlin
@Singleton
@Component(modules = [StorageModule::class])
interface AppComponent {

    @Component.Factory
    interface Factory {
        fun create(@BindsInstance context: Context): AppComponent
    }

    // Expose RegistrationComponent factory from the graph
    fun registrationComponent(): RegistrationComponent.Factory

    fun inject(activity: MainActivity)
}
```

- `RegistrationComponent` factory를 return type으로 갖는 함수를 하나 추가해 준다.
- `AppComponent`가 `RegistrationComponent`가 subcomponent이고 `RegistrationComponent`를 위하 code generate 할 수 있게 만들어야 하고, 이를 위해서는 `Dagger Module`을 만들어야 한다.

```kotlin
// This module tells AppComponent which are its subcomponents
@Module(subcomponents = [RegistrationComponent::class])
class AppSubcomponents
```

- `AppSubcomponenets`라고 클래스에 `@Module` 어노테이션과 subcomponents class 를 추가해 준다.

```kotlin
@Singleton
@Component(modules = [StorageModule::class, AppSubcomponents::class])
interface AppComponent { ... }
```

- `AppComponent`에서 `Componenet`에 `AppSubcomponents` module을 추가해준다.

***`Dagger graph`와 interact 할 수 있는 방법이 2가지 있다.***    
***1. return type을 `Unit`으로 하고 parameter로 field injection을 하는 클래스를 받는 함수를 선언하는 방법(e.g. `fun inject(activity: MainActivity)`)***  
***2. return type을 그래프로부터 제공받을 수 있는 type으로 지정하는 함수를 선언하는 방법(e.g. `fun registrationComponent(): RegistrationComponent.Factory`)***  

## 4. Scoping Subcomponents

`RegistrationViewModel`을 activity와 fragment에서 동일한 객체를 사용하기 위해서 `Subcomponent`를 만들었다.
Component와 class들에 같은 scope 어노테이션을 붙인다면 각 Component에서 해당 타입의 유일한 객체를 가질 수 있다.

그러나 `@Singletone` 어노테이션은 사용할 없는데, 이미 `AppComponent`에서 사용했기 때문이다.

우리는 이것을 `@RegistrationScope` 라고 부를 수 있지만 좋은 예제가 아니다. scope 어노테이션의 이름은 목적을 나타내는 이름 보다는 siblings Component들도 재사용할 수 있는 lifetime에 의존적으로 이름을 지어야 한다.

***Scoping rules***  
***1. `type`에 scope 어노테이션을 붙일 때는 오직 같은 scope이 붙은 `Componenets`에 의해서 사용되어질 수 있다.***  
***2. `Componenets`에 scope 어노테이션을 붙일 때는 어노테이션이 없는 type과 동일한 scope 어노테이션을 붙인 타입만 제공할 수 있다.***  
***3. `subcomponent`는 parent Component 들에서 사용중인 어노테이션은 사용할 수 없다.***  

```kotlin
@Scope
@MustBeDocumented
@Retention(value = AnnotationRetention.RUNTIME)
annotation class ActivityScope

// Scopes ViewModel to components that use @ActivityScope
@ActivityScope
class RegistrationViewModel @Inject constructor(val userManager: UserManager) {
    ...
}

// Scope annotation that the RegistrationComponent uses
// Classes annotated with @ActivityScope will have a unique instance in this Component
@ActivityScope
@Subcomponent
interface RegistrationComponent { ... }
```

### Subcomponents의 lifecycle

`AppComponent`는 Application의 lifecycle에 붙어있다. application이 memory에 있는 동안에 동일한 graph의 객체를 사용하기 원하기 때문이다.

`RegistrationComponent`의 lifecycle은 어떻게 될까? `RegistrationComponent`의 알맞는 lifetime은 `RegistrationAcitivty` 이다. 새로운 `RegistrationActivity`가 생성될 떄마다 새로운 `RegistrationComponent`가 생성되고 Fragment와 Activity는 `RegistrationComponent`의 객체를 사용할 수 있다.

`RegistrationComponent`가 `RegistrationActivity`의 lifecycle에 붙어야 하기 때문에 `AppComponenet`를 Application class에서 참조하는 것처럼 `RegistrationComponent`를 `RegistrationActivity` class에서 참조하도록 해야 한다.

```kotlin
class RegistrationActivity : AppCompatActivity() {
    ...

    override fun onCreate(savedInstanceState: Bundle?) {

        // Remove lines 
        (application as MyApplication).appComponent.inject(this)

        // Add these lines

        // Creates an instance of Registration component by grabbing the factory from the app graph
        registrationComponent = (application as MyApplication).appComponent.registrationComponent().create() 
        // Injects this activity to the just created registration component
        registrationComponent.inject(this)

        super.onCreate(savedInstanceState)
        ...
    }
    ...
}

class EnterDetailsFragment : Fragment() {
    ...
    override fun onAttach(context: Context) {
        super.onAttach(context)

        (activity as RegistrationActivity).registrationComponent.inject(this)
    }
    ...
}

class TermsAndConditionsFragment : Fragment() {
    ...
    override fun onAttach(context: Context) {
        super.onAttach(context)

        (activity as RegistrationActivity).registrationComponent.inject(this)
    }
}
```
