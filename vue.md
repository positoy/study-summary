# Vue.js



### 설치

```html
<script src="https://cdn.jsdelivr.net/npm/vue/dist/vue.js"></script>
```



### 시작

컴포넌트와 선언적 렌더링을 이용하여, 코드를 재사용하고 DOM 과 인스턴스를 연동할 수 있음

- 선언적 렌더링

  ```html
  <div id="app">
    <span>{{message}}</span>
  </div>
  ```

  ```js
  var app = new Vue({
    el : "#app",
    data : {
      message : "hello world!"
    }  
  })
  ```

- 컴포넌트

  ````js
  Vue.component("todo-item", {
    template: "<span>{{message}}</span>",
    props: ["message"]
  });
  ````



### 컴포넌트

템플릿을 찍어낼 수 있음

```js
Vue.component("todo-item", {
  props: ["todo"],
	template: "<li>{todo.text}</li>" // "#todoitem" 으로 지정하고, <script type="text/x-template" id="todoitem"> 로 분리할 수 있음
  data:,
  computed:,
  methods:
})
```

```html
<div id="app">
  <ul>
    <todo-item
      v-for="item in groceryList"
      v-bind:todo="item"
      v-bind:key="item.id" />
  </ul>
</div>
```



### 선언적 렌더링

DOM과 데이터를 연결할 수 있음

```
new Vue({
el:"#app",
data:{
  groceryList:[
    {id:1, text:"sesami"},
    {id:2, text:"meat"},
    {id:3, text:"noodles"}
  ]
})
```



### 사용방법

DOM 과 바인딩 된 자바스크립트 객체는 그 자체로 DOM 과 연동됨

```js
app.message = "yellow world!" // DOM 에 반영됨
```

```html
<div id="app">
  
  // v-if, v-else
  <span v-if="seen">you see me</span>
  <span v-else>i see you</span>
  
  // v-for
  <span v-for="todo in todos">
    {{todo.title}}
  </span>
  
  // v-bind (js 사용가능)
  <span v-bind:title="'titleMsg' + '!!'">
    you will see span title when you mouse over this text.
  </span>
  
  // new Vue({
    el:"#app",
    data: {
      message: "reverse me"
    },
    methods: {
      reverseMessage: function(){
        this.message = this.message.split('').reverse('').join()
      }
    }
  })
  <button v-on:click="reverseMessage">
    {{reverse me}}
  </button>
  // app.message 와 양방향 동기화되는 input
  <input v-model="message">
</div>
```



### 그 외

```html
// 문자를 태그로 출력하기
<div id="app">
  <span>{{message}}</span>
  <span v-html="rawHtml"></span>  
</div>
```

