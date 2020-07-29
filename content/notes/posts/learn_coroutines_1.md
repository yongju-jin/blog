---
title: "코루틴 공부 #1"
date: 2019-09-11T21:41:27+09:00
draft: false
tags: [android, kotlin]
---
스스로 공부한 코루틴에 대한 내용 정리.

## 1. 특징

-------------

### 1. 비동기 프로그래밍을 쉽게 할 수 있도록 도와줌  

아래 코드처럼 쉽게 비동기 수행을 작성할 수 있음.

```kotlin
lauch {

}

async {

}

withContext {

}
```

### 2. 쓰레드를 사용하는 것보다 가벼움

쓰레드, 코루틴을 1대1로 비교한다면 코루틴은 새로운 쓰레드를 생성하지 않기 때문에 쓰레드를 사용하는 것보단 비교적 가볍다.  

### 3. 일반적인 형태의 소스코도와 동일한 방식으로 코드 작성이 가능함  

아래와 같이 일반적인 형태의 코드로 작성이 가능함.

```kotlin
suspend fun fetchDocs() {                      // Dispatchers.Main
    val result = get("developer.android.com")  // Dispatchers.Main
    show(result)                               // Dispatchers.Main
}

suspend fun get(url: String) =                 // Dispatchers.Main
    withContext(Dispatchers.IO) {              // Dispatchers.IO (main-safety block)
        /* perform network IO here */          // Dispatchers.IO (main-safety block)
    }                                          // Dispatchers.Main
}
```

## 2. 어려운 점

-------------

### 1. 러닝커브

간단하게 실행해 보는 것은 간단하지만, 잘 사용하기 위해선 세부적인 내용의 대한 이해가 필요한데 여기서 러닝코브가 크다고 생각됨.  
아래 참고링크를 잘 읽어봐도 이해가 잘 되지 않음. ㅠ  
ex) CoroutineContext, CoroutineScope 등등

### 2. 예외처리에 대한 부분

에러 및 예외처리에 대한 부분이

1. `try-catch`
2. `Result` 클래스에서 체크
3. `CoroutineExceptionHandler`

이런 방법이 보였었는데,  
1번 방법은 기존의 `try-catch`라서 익숙한 방식이고,  
2벙 방법은 딱히 사용할 일이 없을 거 같고,  
3번 방법은 하나의 `CoroutineExceptionHandler` 객체에서 예외처리가 가능할 것으로 보이긴 하지만,  
개인적으로 생각하기에는 Rx에서 처리하는 방식이 더 좋은것처럼 보인다.  

-------------
코루틴에 대해서 블로그, 정식 문서를 이것 저것 읽고 있는데, 정리를 하면서 읽는 편이 좋을 것으로 보여서 정리 중.

앞으로 기존 문서와 다른 문서를 보면서 추가로 알게된 내용을 내가 이해한 대로 정리가 필요할 거 같음.

### *참고링크*

- <https://kotlinlang.org/docs/reference/coroutines-overview.html>
- <https://developer.android.com/kotlin/coroutines>
- <https://medium.com/androiddevelopers/coroutines-on-android-part-ii-getting-started-3bff117176dd>
- <https://proandroiddev.com/android-coroutine-recipes-33467a4302e9>
