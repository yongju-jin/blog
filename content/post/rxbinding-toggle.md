---
title: "[RxBinding2] ToggleButton에서 on/off Observable 생성하기."
date: 2017-11-12T17:56:29+09:00
tags: [Rx, Android]
---
# [RxBinding2] ToggleButton에서 on/off Observable 생성하기.

toggle button 에서 on/off Observabel을 분리하기 위해서 아래와 같이 하면 

```kotlin
val obFuel1 = tb_fuel1.checkedChanges()
obFuel1.filter {
  Log.d(TAG, "[whenFueLift] $it")
  it
}.subscribe {
  Log.d(TAG, "[whenFueLiftSub] $it")
}

obFuel1.filter {
  Log.d(TAG, "[whenFueDown] $it")
  !it
}.subscribe {
  Log.d(TAG, "[whenFueDownSub] $it")
}
```

```log
D/FuelPump01: [whenFueLift] false
D/FuelPump01: [whenFueDown] false
D/FuelPump01: [whenFueDownSub] false
D/FuelPump01: [whenFueDown] true
D/FuelPump01: [whenFueDown] false
D/FuelPump01: [whenFueDownSub] false
```

위와 같은 결과를 얻게 된다.
하나의 Observabe에 여러개의 subscriber가 붙을 수는 없다. 나중에 subscriber가 등록된다면 먼저 등록된 subscriber로는 data가 전달이 되지 않는다.

```kotlin
val obFuel1 = tb_fuel1.checkedChanges().share()
obFuel1.filter {
  Log.d(TAG, "[whenFueLift] $it")
  it
}.subscribe {
  Log.d(TAG, "[whenFueLiftSub] $it")
}

obFuel1.filter {
  Log.d(TAG, "[whenFueDown] $it")
  !it
}.subscribe {
  Log.d(TAG, "[whenFueDownSub] $it")
}
```

이런 경우는 위 코드처럼 `share()` 를 사용하면 된다.

```log
D/FuelPump01: [whenFueLift] true
D/FuelPump01: [whenFueLiftSub] true
D/FuelPump01: [whenFueDown] true
D/FuelPump01: [whenFueLift] false
D/FuelPump01: [whenFueDown] false
D/FuelPump01: [whenFueDownSub] false
```

위 로그처럼 on/off obsevable을 생성할 수 있다.
아래 내용은 `share()` 에 대한 java doc 내용이다.

```doc
Returns a new Observable that multicasts (shares) the original Observable. 
As long as there is at least one Subscriber this Observable will be subscribed and emitting data. 
When all subscribers have unsubscribed it will unsubscribe from the source Observable.
This is an alias for publish().ConnectableObservable.refCount().
```
## *참조 link*

[share()](http://reactivex.io/RxJava/javadoc/rx/Observable.html#share--)

[How to user RXjava share() operator?](https://blog.mindorks.com/how-to-use-rxjava-share-operator-26b08973771a)

