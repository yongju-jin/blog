---
title: "[TIL-React] #1"
date: 2019-11-07T22:50:34+09:00
draft: false
tags: [til, react]
---
### component props 가져오기

```js
var GreeterWord = React.createClass({
  render: function () {
    var name = this.props.name;
    return (
      <div>
        <h1>
          Hello React From GreeterWord {name}
        </h1>
        <p>
          this is form a component
        </p>
      </div>
    );
  }
});

ReactDOM.render(
  <GreeterWord name="yongu"/>,
  document.getElementById('app')
);
```

`this.props.name`으로 `name`에 접근해서 `{name}` 으로 사용

### Default Value

```js
var GreeterWord = React.createClass({
  getDefaultProps: function () {
    return {
      name: 'React',
    };
  },
  render: function () {

```

Default 값을 설정할 때는 `getDefaultPros`를 설정

### JS에서 받은 값을 prop에 설정

```js
var firstName = 'jin';
var paragraph = 'paragraph';

ReactDOM.render(
  <GreeterWord name={firstName} paragraph={paragraph}/>,
  document.getElementById('app')
);
```

JS에서 `firstName` 변수로 받은 값을 `{firstName}` 값으로 전달할 수 있음

### input 받기

```js
var GreeterWord = React.createClass({
  getDefaultProps: function () {
    return {
    };
  },
  onButtonClick: function (e) {
    e.preventDefault();

    var name=this.refs.name.value;
    alert(name);
  },
  render: function () {
    var name = this.props.name;
    var para = this.props.paragraph
    return (
      <div>
        <h1>
          App_2.jsx
        </h1>
        <form onSubmit={this.onButtonClick}>
          <input type="text" ref="name"/>
          <button>Set Name</button>
        </form>
      </div>
    );
  }
});
```

1. `onSubmit={this.onButtonClick}` 에서 호출할 함수 지정.
1. component에 함수를 같이 넘김.

    ```js
    onButtonClick: function (e) {
      e.preventDefault();

      var name=this.refs.name.value;
      alert(name);
    },
    ```

1. `this.refs.name.value` 를 통해서 값을 전달받음.
1. `e.preventDefault()` 의 역할은 페이지 전체가 reload 되는 것을 막음.  
   기본적으로 form에서 onSubmit()을 통해 submit 하면 이벤트 완료 후 refresh가 됨
