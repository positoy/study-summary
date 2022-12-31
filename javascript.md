## grapheme-splitter

```js
var Grapheme = require('grapheme-splitter');
var splitter = new Grapheme();
console.log(splitter.splitGraphemes(bio).length);
```

- https://github.com/orling/grapheme-splitter



# 미묘한 자바스크립트

### 바인딩

- 객체의 멤버 함수를 할당 받아서 실행하면 this 가 undefined
- bind, call, apply 를 사용하자!

```javascript
const person = {
  age : 10,
  printAge : function(first,last) {
    console.log(`my name is ${last},${first} and ${this.age} age.`)
  }
}

person.printAge() // 10

// wrong (this undefined)
const func = person.printAge
func('andy','ahn')

// fix (bind)
const func = person.printAge.bind(person)
func('andy','ahn')

// fix (call)
const func = person.printAge
printAge.call(person, 'andy','ahn')

// fix (apply)
const func = person.printAge
printAge.apply(person, ['andy','ahn'])
```



### 메소드 선언 방법에 따라 다른 바인딩

- React 클래스 컴포넌트의 메소드를 functionName(){} 로 선언했는데 바인딩을 안해주면 this 는 undefined
- 클래스 필드 문법을 사용하자!

```javascript
class Mycomponent extends React.Component {
  
  handleClick() {
    console.log(this) // wrong! constructor 에서 바인딩 필요
  }
  
  handleClick = ()=>{
    console.log(this) // work!
  }
  
  render() {
    return <button onClick={this.handleClick}/> // 내부의 this 가 바인딩되지 않음
    return <button onClick={()=>this.handleClick()}/> // 내부의 this가 바인딩 되지만 MyComponent 객체가 모두 다른 콜백을 갖는다. 렌더링 중복 주의
  }
}
```



### promise, async, await

- promise

  - promise 생성자에 전달된 람다는 즉시 실행 됨
  - then 으로 람다에 포함된 async 로직의 결과에 따라 분기할 수 있음
  - then ((resolve,reject)=>result) 으로 콜백을 chaining 함으로써, 콜백지옥을 해결해 줌
  - promise 이후의 코드가 block 되는 것은 아님 주의

  ```javascript
  
  const p = new Promise((resolve,reject)=>{
    setTimeout(()=>resolve(),3000)
  })
  
  console.log("start")
  p.then(()=>console.log("timed out!"))
  console.log("end")
  
  // start
  // end
  // timed out!
  ```

  

- async, await

  - async 함수는 항상 promise 를 반환함

    ```javascript
  async function resolved() {
      return 1 // Promise { 1 }
  }
    
    async function pedning() {
      return Promise.resolve(1) // <pending>
    }
    
    hello().then(console.log) // 1
    ```
  
  - await 은 async 함수 내부에서만 쓸 수 있고, promise 가 settled 될 때까지 기다림
  
    ```javascript
    async function helloworld() {
      const result = await new Promise((resolve, reject) => setTimeout(() => resolve('hello'), 3000))
        console.log(result)
      console.log('world')
    }
    
    helloworld()
    console.log('end')
    
    // <result>
    // end
    // hello
    // world
    ```
  
  - fetch().then().then().then() 문법을 좀 더 자연스럽게 만들어주기 위한 문법



### 자바스크립트 변수는 기본적으로 참조자임

```javascript
const arr = new Array(3).fill({name:null, age:null})
arr[0].name = "Andy"
console.log(arr)
//[
//  {name : "Andy", age:null}, 
//  {name : "Andy", age:null},
//  {name : "Andy", age:null}, 
//]
// new Array(3).fill(Math.random()), new Array(3).fill(1) 도 마찬가지로 반복되는 값이 채워지지만, 최소한 리터럴이라 바꿀 수 있음
```



### 로더, 번들러, 컴파일러

- 로더 (CommonJS, AMD, ES6)
  js 파일의 모듈화로 코드가 범용성을 갖고 관리 용이하게 만들어준다. 아래 순서로 탄생했다.

  - CommonJS
    node.js 에서 먼저 채용. 파일 단위로 변수 scope 를 나눌 수 있고, 각 모듈이 파일시스템에 있는 시나리오에서 사용 가능.

    ```javascript
    // fileA.js
    var a = 1
    b = 2
    exports.sum = function(c,d) {
      return a+b+c+d
    }
    
    // fileB.js
    var a = 3
    b = 4
    var moduleA = require("./fileA")
    console.log(moduleA.sum(3,4)) // 10
    ```

  - AMD
    웹 브라우저에서 CommonJS 사용시 비동기 처리가 불가능하여 탄생. closure 를 사용하여 scope 를 생성한다.

    ```javascript
    // fileA.js 
    define(["fileA"], function(fileA){
      return {
        sum : fileA.sum
      }
    })
    
    // fileB.js
    require(["/js/fileA.js"], function(fileA){
      var a = 3
      var b = 4
      console.log(fileA.sum(a,b)) // 10
    })
    ```

  - ES6
    ECMAScript 의 표준 모듈 스타일

    ```javascript
    // fileA.js
    var a = 1
    b = 2
    
    function sum(c,d) {
      return a+b+c+d
    }
    
    export {sum}
    
    // fileB.js
    import {sum} from 'fileA'
    
    var a = 3
    var b = 4
    console.log(sum(a,b)) // 10
    ```



- 컴파일러 (babel)
  - 자바스크립트 문법에 다양한 스타일이 존재하는데, 이 스크립트들이 모두 ES5 위에서 동작할 수 있도록 컴파일타임 또는 런타임에 조작한다.
    - 컴파일타임 : ES5 이후의 새로운 문법을 작성된 스크립트를 구형 브라우저의 ES5 표준에서 동작할 수 있도록 미리 변환
    - 런타임 : 브라우저에 직접 로드되어 미지원 메소드를 각 object 의 protptype 에 붙여준다. (babel-polyfill)
  - .babelrc 파일에 컴파일을 위해 plugins, preset 속성을 지정해줄 수 있다.
    - plugin : 문법 (arrow-functions, classes, react-jsx, typescript, ...)
    - preset : 문법의 집합 (ES2015, @babel/preset-react, @babel/preset-typescript)



- 번들러 (webpack, parcel, browserify)

  - 로더와, 컴파일러를 이용해서 js 파일들을 ES5 스타일로 열고 하나로 합쳐준다.
  - Parcel 은 내부적으로 Babel, PostCSS, PostHTML 을 이용해서 모든 asset 들을 번들링 해준다. 
  - 설정파일
    - webpack :  `webpack.config.js` 
    - babel : `.babel.config.json`, `.babelrc`, `.babelrc.js(확장자)`, `package.json의 'babel' key `
    - typescript : `tsconfig.json`
  - dist 에 생성한 번들파일을 webpack devserver 에서 바로 확인 가능

  ```javascript
  // package.js (node)
  {...
      "scripts": {
          "build": "rimraf dist && webpack && cp src/index.html dist ",
          "devserver": "yarn webpack-cli serve",
          "clean": "rimraf dist"
      },
  ```

  ```javascript
  // webpack.config.js
  const webpack = require('webpack')
  const path = require('path')
  
  module.exports = {
      entry: './src/index.ts',
      output: {
          path: path.resolve(__dirname, 'dist'),
          publicPath: '/dist/',
          filename: 'bundle.js',
      },
      mode: 'production',
      module: {
          rules: [
              {
                  test: /\.ts$/,
                  include: path.join(__dirname),
                  exclude: /(node_modules)|(dist)/,
                  use: {
                      loader: 'babel-loader',
                      options: {
                          presets: ['@babel/typescript'],
                      },
                  },
              },
              {
                  test: /\.js$/,
                  include: path.join(__dirname),
                  exclude: /(node_modules)|(dist)/,
                  use: {
                      loader: 'babel-loader',
                      options: {
                          presets: ['env'],
                      },
                  },
              },
          ],
      },
      devServer: {
          contentBase: path.join(__dirname, 'dist'),
          publicPath: '/',
          compress: true,
          port: 9000,
      },
  }
  ```

  

- 참고
  - https://d2.naver.com/helloworld/12864
  - https://beomi.github.io/2017/10/18/Setup-Babel-with-webpack/