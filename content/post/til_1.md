---
title: "[TIL #1] ThreeTenABP - 오늘날짜 구하기"
date: 2019-05-21T00:20:21+09:00
draft: false
tags: [TIL, android]
---

# ThreeTenABP

Threen Ten Java8에 포함된 날짜 시간을 계산하는 라이브러리로 보인다.  
찾아보다가 알게된 라이브러리로 Android에서 사용하기 위해서 JakeWharton 님께서  
Android 에 맞게 backport 하신 라이브러리다.  
[링크](https://github.com/JakeWharton/ThreeTenABP)

오늘 사용한 내용은 오늘의 날짜를 가져오는 방법인데 정말 간단하다
```kotlin
val today = LocalDate.now()
val year = today.year
val month = today.monthValue
val day today.dayOfMonth
```

이밖에도 날짜 더하기, 뺴기 등등 편한 API가 많이 제공되고 있다.  
추후 날짜 더하기 및 기타 날짜 관련 추가작업을 진행할 때 사용해 봐야겠다.