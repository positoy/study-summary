

# React

## Getting Started

- https://www.taniarascia.com/getting-started-with-react/

  - React, ReactDom, Babel

  - Simple Component, Class Component

    ```javascript
    export const simple = (props) => {
      return <h1>My name is {props.name}</h!>  
    }
    
    export const moreSimple = ({name}) => {
      return <h1>My name is {name}</h1>
    }
    ```

  - Props (defaultProps), State
    props 는 파라미터를 전달할 때, state 는 컨텍스트를 관리할 때 주로 사용. setState 호출시 재귀적으로 render 가 다시 호출되어 뷰를 갱신할 수 있음

    ```javascript
    class MyComponent extends React.Component {
      static defaultProps = {
        name : 'Andy'
      }
      render() {
        return <h1>My name is {this.props.name}</h1>
      }
    }
    
    class App extends React.Component {
      render() {
        return <MyComponent name='Candy'/>
      }
    }
    ```

    ```javascript
    export default class App extends React.Component {
      state = { count : 0 }
    
      increaseCount = () => {
        this.setState({count : this.state.count + 1})
      }
    
      decreaseCount = () => {
        this.setState({count : this.state.count - 1})
      }
    
      render() {
        return (
        <div>
          <h1>count number : {this.state.count}</h1>
          <button onClick={this.increaseCount}>increase</button>
          <button onClick={this.decreaseCount}>decrease</button>
        </div>
        )
      }
    }
    ```

  - DOM != virtual DOM (this.props)

  - App, Table, Form 예제 => App 을 중심으로 하위 컴포넌트들이 App의 state를 조작하며 이벤트가 App을 거쳐서 전파 되도록 설계

  - lifecycle
  
    - 시계의 초침 타이머 생성/삭제처럼 한 번만 수행해야 하는 것들은 lifecycle을 고려한다. (componentDidMount, componentWillUnmount)
    - context, defaultPros, state 저장 → componentWillMount → render → componentDidMount  ...
    - 2개만 
      deprecated since react 17 : componentWillMount, componentWillUpdate, componentWillReceiveProps
  
  - ![React LifeCycle](https://cdn.filestackcontent.com/ApNH7030SAG1wAycdj3H)

### 이벤트 콜백의 this 바인딩

- 결론1 : 함수 컴포넌트를 사용하면 고민할 일이 없다

- 결론2 : 클래스 컴포넌트를 사용할 때에는 클래스 필드 문법으로 작성하자

- 클래스 필드 문법 사용시 생성자에서 바인딩 필요 없음

  ```javascript
  class MyComponent extends React.Component {
  
    handleOnclick = () => {
      console.log(this)
    }
    
    render() {
  		return <button onClick={this.handleOnclick}>click me</button>
    }
  }
  ```

- handleOnclick() {} 선언시 생성자에서 바인딩 필요

  ```javascript
  class MyComponent extends React.Component {
  
    constructor(props) {
      super(props)
      this.handleOnclick = this.handleOnclick.bind(this)
    }
    
    handleOnclick() {
      console.log(this)
    }
    
    render() {
      return <button onClick={this.handleOnclick}>click me!</button>
    }
  }
  ```

  

### Props

- 읽기 전용

- `this.props.data` 값은 우선순위 존재 여부에 따라 다르게 적용할 수 있음

  - 우선순위1. `<DisplayName name="Andy"/>`
  - 우선순위2. `DisplayName.defaultProps`
  - 우선순위3. `static defaultProps`

  ```javascript
  class DisplayName extends Component {
    static defaultProps = "static default";
    render() {
      return <div>my name is {this.props.name}</div>;
    }
  }
  DisplayName.defaultProps = { name: "assigned default" };
  
  ReactDOM.render(
    <React.StrictMode>
      <DisplayName name="Andy"/>
    </React.StrictMode>,
    document.getElementById("root")
  );
  ```



### State

- 읽기/쓰기
- Class Component 에서만 사용 가능
- Function Component 에서 사용할 경우 `useState` hook 을 사용



### Context

- global 한 데이터 공유

- 코드가 간결해짐 (props 를 사용하면 컴포넌트 트리를 따라 자식에게 props 를 전달해야 하지만 context 는 중간 노드를 뛰어넘을 수 있음)

- 코드 재사용성이 높아짐 (props 사용하면 모든 컴포넌트에 파라미터가 들어가고 의존성 발생)

- 사용방법

  - 컨텍스트 저장 `/components/ContextComponent.js`, `/pages/App.js`

    여기서 초기값은 컨텍스트 사용시 Provider 를 발견할 수 없을 때 사용 됨

    ```javascript
    import React from 'react'
    const ContextComponent = React.createContext({})
    export default ContextComponent
    ```

    ```javascript
    import React, {Component} from 'react'
    import ContextComponent from `../components/ContextComponent.js`
    
    export default function App() {
      return (
        <ContextComponent.Provider value={{name:'andy'}}>
        <ParentComponent/> // ParentComponent 는 ChildComponen를 자식으로 갖는 경우 가정
        </Context.Component.Provider>
      )
    }
    ```

    

  - 컨텍스트 사용 `/components/ChildComponent.js`

    - 방법1 : Consumer

      ```javascript
      import ContextComponent from '../components/ContextComponent'
      
      export default function ChildComponent() {
        return (
          <ContextComponent.Consumer>
          {
            (context)=><p>name in the context is {context.name}</p>
          }
          </ContextComponent.Consumer>
        )
      }
      ```

      

    - 방법2 : useContext : 코드 간결해짐

      ```javascript
      import ContextComponent from '../components/ContextComponent'
      
      export default function ChildComponent() {
      
        const {name} = useContext(ContextComponent)
        
        return <p>name in the context is {name}</p>
      }
      ```

      

    - 방법3 : contextType : 클래스 컴포넌트에서만 사용 가능

      ```javascript
      import React,{Component} from 'react'
      import ContextComponent from '../components/ContextComponent'
      
      export default class ChildComponent extends Component {
      
        static contextType = ContextComponent
      
        render() {
          return <p>Child Component : {this.context.name}</p>
        }
      } 
      ```

      

### Hook

- `useContext`
  위 Context 방법2

- `useState`
  this.state 와 별도로 state 변수와 이 변수의 set 함수를 정의한다. 함수 컴포넌트에서만 사용할 수 있다.

  ```javascript
  export default function Counter() {
    const [count,setCount] = setState(0);
    
    return <div>
      <p>you clicked {count} times.</p>
    	<button onClick={()=>setCount(count+1)}>click me!</button>
      </div>
  }
  ```

  

- `useEffect`
  
- 컴포넌트 라이프사이클에서 `componentDidMount` `componentDidUpdate` `componentWillUnmount`에 해당하는 이벤트를 정의할 수 있다. 정의한 함수의 리턴값 함수는 `componentWillUnmount` 호출 시점에서 사용된다.
  
  ```javascript
  import React, { useState, useEffect } from 'react';
  
  function Example() {
    const [count, setCount] = useState(0);
  
    // componentDidMount, componentDidUpdate와 비슷합니다
    useEffect(() => {
      // 브라우저 API를 이용해 문서의 타이틀을 업데이트합니다
      document.title = `You clicked ${count} times`;
    });
  
    return (
      <div>
        <p>You clicked {count} times</p>
        <button onClick={() => setCount(count + 1)}>
          Click me
        </button>
      </div>
    );
  }
  ```
  
  - 두번째 파라미터에 종속된 값의 배열을 전달하여 제한적으로 `componentDidUpdate` 에 렌더링 되도록 할 수 있다.
  
    ```javascript
    useEffect(()=>{
      ...
    }, [props.source]) // source 변경시에만 componentDidUpdate 동작
    
    useEffect(()=>{
      ...
    }, []) // componentDidUpdate 에는 동작하지 않음
    ```

- `useReducer`

  <img src="https://miro.medium.com/max/1198/0*CwvI4QU26E-Ww8mb." alt="Image for post" style="zoom:50%;" />
  reducer 라는 핸들러를 이용하여, action dispatcher 에 의해 변화하는 state 생성

  ```javascript
  const initialState = {count : 0}
  
  function reducer(state, action) {  
    switch (action.type) {
      case 'increase':
        return {count : state.count + 1}
      case 'decrease':
        return {count : state.count - 1}
      default:
        throw new Error()
    }
  }
  
  function counter() {
    const [state,dispatch] = useReducer(reducer, initialState)
    
    return <div>
        <p>count : {state.count}</p>
        <button onClick={()=>dispatch({type:'increase'})}>increase</button>
        <button onClick={()=>dispatch({type:'decrease'})}>decrease</button>
      </div>
    )
  }
  ```



### react-router

#### 참고

- https://reactrouter.com/web/example/url-params

#### 설치

```bash
yarn add react-router-dom
```

- Route

  - path

    ```javascript
    <Route path="/" component={Home} />
    <Route path="/about" component={About} />
    <Route path="/about/address" component={Address} /> 
    ```

  - exact

    ```javascript
    <Route exact path="/" component={Home} />
    <Route exact path="/about" component={About} />
    <Route exact path="/about/address" component={Address} /> 
    ```

  - Switch

    ```javascript
    <Switch>
      <Route path="/" component={Home} />
    	<Route path="/about" component={About} />
    	<Route path="/about/address" component={Address} /> 
    </Switch>
    ```

  - component

    - params

      ```javascript
      <Route path="/about/:name" component={About} />
      ```

      ```javascript
      const About = function({match}) {
        return <div>My name is ${match.params.name}.</div>
      }
      ```

    - query-string

      ```javascript
      import queryString from `query-string`
      
      const About = function({location}) {
        const query = queryString.parse(location.search)
        return <div>My name is ${query.name}.</div>
      }
      ```

      

  - Link

    - Link

      ```javascript
      <Link to="/about">go to about</Link>
      ```

    - NavLink

      ```javascript
      <NavLink to="abouot">go to about</NavLink>
      ```

## 그 외

### 성능개선

- React.memo, useCallback 이용하여 메모이제이션으로 성능개선
- 

