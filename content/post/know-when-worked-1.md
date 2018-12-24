---
title: "하면서 배운것들 #1"
date: 2018-11-12T17:56:29+09:00
tags: [android, databinding]
---
## Databinding & drawable
databindig에서 drawable을 지정해줘야 할 필요가 있는 경우 아래와 같이 사용할 수 있음.
```xml
app:imageRes="@{vm.isListType ? @drawable/list : @drawable/card}"
``` 
drawable을 지정할 떄는 @drawable/*filename* 이렇게 사용할 수 있음.  
위와 같이 isLisType이 변경될 떄 drawable resource도 변경되도록 할 수 있음.

imageRes adapter는
```kotlin
@BindingAdapter("imageRes")
fun ImageView.setImageRes(drawable: Drawable?) {
    GlideApp.with(this.context).load(drawable)
        .error(R.drawable.circle_wrap)
        .diskCacheStrategy(DiskCacheStrategy.AUTOMATIC).into(this)
}
```
parameter를 Drawable로 받아서 처리하면 됨.
