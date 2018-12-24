---
title: "FRP에서의 STREAM"
date: 2017-10-02T17:56:29+09:00
draft: false
tagss: [FRP, Rx]
---
함수형 반응형 프로그래밍: FRP 입문자를 위한 종합 안내서.

2장의 내용을 정리한 자료 입니다.

------

# 2.FRP의 핵심

### 1. 스트림 타입: 이벤트의 흐름

> 이벤트의 흐름을 표현한다.

**책에서는 데이터의 흐름을 Cell, 이벤트의 흐름을 Stream이라고 표현하지만 다른 곳에서는 모두 데이트와 이벤트의 흐름을 모두 Strean이라고 말하고 두 가지를 분류하지 않음.**

- Streams are cheap and ubiquitous, anything can be a stream: variables, user inputs, properties, caches, data structures.
- [Rx에서 Observable이 아닐까?](http://reactivex.io/documentation/observable.html)

example 1.  

> sodium

> ```java
> SButton clear = new SButton("Clear");
>
> final Stream<Unit> sClicked = clear.sClicked;
>
> Stream<String> sClearIt = sClicked.map(u -> "");
>
> STextField text = new STextField(sClearIt, "Hello");
> ```

> RxBinding(android, kotlin)  

> ```kotlin
> val sClicked = RxView.clicks(clear)
>
> val sClearIt = sClicked.map { "" }
>
> sClearIt.subscribe(
>
>     editText::setText,
>
>     Throwable::printStackTrace
>
> )
> ```

> (물론 실제 코드라면 이런식으로?)

> ```kotlin
> RxView.clicks(clear).subscribe({
>
>     editText.setText("")
>
> }, Throwable::printStackTrace)
> ```

- Unit - 아무것도 아닌 값.

FRP가 내부적으로 항상 인자를 하나만 밷는 핸들러를 사용한다(?)  

왜 인자를 항상 전달해야 하는지는 잘 모르겠음..  

전달할 값이 없을 경우 사용.  

Rx(RxBinding)에서는 Unit 같은것이 있는지?? 있다. ex) Notification.

- sodium

  ```java
  package nz.sodium;
  public enum Unit {
    UNIT;
    private Unit() {
    }
  }
  ```


- RxBinding

  ```java
  @RestrictTo(LIBRARY_GROUP)
  public enum Notification {
    INSTANCE
  }
  ```

### 2. map

- [map](http://reactivex.io/documentation/operators/map.html)

### 3. FRP 시스템의 구성요소

- 연산: 스트림이나 셀을 다른 스트림이나 셀로 변환하는 함수나 코드 (operator?)
- 기본연산: 다른 연산자를 조합해 표현할 수 없는 연산. (제공되는 operator?)

​    ex) map, merge, filter...

### 4. 참조 투명성

프로그램 동작의 변경없이 관련 값을 대체할 수 있다면 표현식을 참조 상 투명하다고 할 수 있다. 그 결과, 참조 상 투명한 함수를 평가하게 되면 동일한 인자에 대해 동일한 값을 반환해야 한다. 그러한 함수를 `순수 함수`라고 부른다. - [wiki](https://ko.wikipedia.org/wiki/%EC%B0%B8%EC%A1%B0_%ED%88%AC%EB%AA%85%EC%84%B1)

- `I/O`를 수행해서는 안된다.  
- 예외처리는 내부에서. 외부로 던지지 말 것.  
- 함수 내부에서 `전역변수` 사용 X.  

### 5. Cell 타입: 시간에 따라 변하는 값.

> Cell: 시간에 따라 변할 수 있는 값을 표현한다.

example 2.

> sodium

> ```java
> STextField msg = new STextField("Hello");
> SLabel lbl = new SLabel(msg.text);
> // msg.text => Cell<String> type
> ```

> RxBinding(android, kotlin)

> ```kotlin
> RxTextView.textChanges(editText)
>    .subscribe(
>        textView::setText,
>        Throwable::printStackTrace
>    ).apply {
>        disposables.add(this)
>    }
> ```

- Cell 매핑하기.  

`Cell`도 `Stream`과 동일하게 `map`을 사용할 수 있음.

​    example 3.

> sodium

> ```java
> STextField msg = new STextField("Hello");
> Cell<String> reversed = msg.text.map(t ->
>    new StringBuilder(t).reverse().toString());
> SLabel lbl = new SLabel(reversed);
> ```

> RxBinding(android, kotlin)

> ```kotlin
> val textChanges = RxTextView.textChanges(editText)
> val textChagesMap = textChanges.map { StringBuilder(it).reverse().toString() }
> textChagesMap.subscribe(
>    textView2::setText,
>    Throwable::printStackTrace
> ).apply {
>    disposables.add(this)
> }
> ```

> ```kotlin
> RxTextView.textChanges(editText)
>    .subscribe(
>        {
>            textView2.text = it.reversed()
>        },
>        Throwable::printStackTrace
>    ).apply {
>        disposables.add(this)
>    }
> ```

markdown 어렵네요 ㅠ

## *참조 link*

[The introduction to Reactive Programming you've been missing](https://gist.github.com/staltz/868e7e9bc2a7b8c1f754)   

[Reactive Programming](https://brunch.co.kr/@oemilk/79)
