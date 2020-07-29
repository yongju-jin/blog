---
title: "Hugo에서 새로운 post를 작성하는 방법"
date: 2019-08-30T23:32:55+09:00
draft: false
tags: [blog, post]
---
1. blog 폴더에서 아래 명령어를 실행하면  
contents/post 아래에 입력한 파일 이름의 파일이 생성됨.

        hugo new post/how_to_new_post_using_hugo.md

1. 새로 생성된 파일에서 글 작성.  
1. local server에서 확인.  

        // 내용이 변경되면 local 에서 바로 변경내용을 확인 할 수 있음.
        hugo server -D

1. github blog respository에 push
1. 추가된 post를 gitub blog repository에 적용.

        hugo -d path

1. github blog respository push
