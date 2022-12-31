# Redux

## summary

`postsSlice.js`

```tsx
import {createSlice} from '@reduxjs/toolkit'

const initialState = [{id:'1', title:'hello', content:'world!'}] 
const postsSlice = createSlice({
  name : 'posts',
  initialState,
  reducers:{
    postAdded(state, action) {
      state.push(action.payload)
    }    
  }    
})

export const {postAdded} = postsSlice.actions
export default postsSlice.reducer
```

- reducer prepare 사용시

```tsx
import {createSlice, nanoid} from '@reduxjs/toolkit'

const initialState = [{id:'1', title:'hello', content:'world!'}] 
const postsSlice = createSlice({
  name : 'posts',
  initialState,
  reducers:{
    postAdded : {
      reducer(state, action) {
        state.push(action.payload)
      },
      prepare(title, content) {
        return {
          payload : {
            id : nanoid(),
            title,
            content
          }
        }
      }
    }    
  }    
})

export const {postAdded} = postsSlice.actions
export default postsSlice.reducer
```



`store.js`

```tsx
import {configureStore} from '@reduxjs/toolkit'
import postsReducer from '../features/postsSlice'

export default configureStore({
  reducer:{
    posts: postsReducer
  }
})
```

`index.js`

```tsx
import {Provider} from 'react-redux'

ReactDOM.render(
  <React.StrictMode>
    <Provider store={store}>
      <App>
      </App>
    </Provider>
  </React.StrictMode>,
  document.getElementById('root')
)
```

`PostsList.js`, `AddPostForm.js`

```tsx
// read
import {useSelector} from 'react-redux'

export const PostsList = ()=>{
  const posts = useSelector(state => state.posts)
  return posts.map(post =>
                   <Article>
                     <Title>{post.title}</Title>
                     <Content>{post.content}</Content>
                   </Article>)
}

// write
import {useDispatch} from 'react-redux'
import {postAdded} from 'postsSlice'

export const AddPostForm = ()=>{
  const dispatch = useDispatch()

  const [title, setTitle] = useState('')    
  const [content, setContent] = useState('')
  
  const onTitleChanged = e=>setTitle(e.target.value)
  const onContentChanged = e=>setContent(e.target.value)
  const onSavePostClicked = ()=>{
    dispatch(postAdded({
      id : nanoid(),
      title,
      content
    }))
    setTitle('')
    setContent('')
  }
  
  return <section>
      <h2>Add a New Post </h2>
      <form>
        <label htmlFor="postTitle">Post Title:</label>
        <input
          type="text"
          id="postTitle"
          name="postTitle"
          value={title}
          onChange={onTitleChanged}
        />
        <label htmlFor="postContent">Content:</label>
        <textarea
          id="postContent"
          name="postContent"
          value={content}
          onChange={onContentChanged}
        />
        <button type="button" onClick={onSavePostClicked}>
          Save Post
        </button>
      </form>
    </section>
}
```

- reducer prepare 사용시

```tsx
const onSavePostClicked = ()=> {
  if (title && content) {
    dispatch(postAdded(title, content))
    setTitle('')
    setContent('')
  }
}
```



## Redux Tookit

### usage guide



## react-redux

`action` creator

```tsx
function postAdded(id, title, content) {
  return {
    type: 'posts/postAdded',
    payload : { id, title, content }
  }
}
```

`payload`

`reducer`

## tutorials

### essentials

1. overview and concept

   - goal : predictable action, global state

   - pros & cons : high cohesion, higher complexity

   - libaraires : redux, react-redux, redux toolkit

   - terms

     - Actions

       ```js
       {
         type : 'todos/todoAdded',
         payload : 'milk'
       }
       ```

     - Reducers : (state, action) => newState

       ```js
       function counterReducer(state = initialState, action) {
         if (action.type === 'counter/increment') {
           return {
             ...state,
             value: state.value + 1
           }
         }
         return state
       }
       ```

       - calculate new state value only based on the `state` and `action`
       - immutable update
       - must not be async, random value calc, make side effects

     - Store

       ```js
       import { configureStore } from '@reduxjs/toolkit'
       const store = configureStore({ reducer: counterReducer })
       console.log(store.getState()) // {value:0}
       ```

     - Dispatch

       ```js
       store.dispatch({type:'counter/increment'})
       console.log(store.getState()) // {value:1}
       ```

     - Selectors

       ```js
       const selectCounterValue = state => state.value
       console.log(selectCounterValue(state.getState()))
       ```

   - Data Flow

     - initial setup : reducer runs → initial state → first render
     - updates : event happens → dispatch(action) → reducer(state, action) → notify subscribed UI components → UI updates

2. [app structure](https://redux.js.org/tutorials/essentials/part-2-app-structure)

   - `configureStore`

     - we can pass in all of the different reducers in an object. The key names in the object will define the keys in our final state value.
     - `configureStore` automatically adds several middleware to the store setup by default to provide a good developer experience, and also sets up the store so that the Redux DevTools Extension can inspect its contents.

     ```js
     import {configureStore} from '@reduxjs/toolkit' 
     import counterReducer from '../features/counter/counterSlice'
     const store = configureStore({
       reducer: {
         counter: counterReducer
       }
     })
     ```

   - `createSlice`

   - - `Slice` is a collection of Redux reducer logic and actions for a single feature.
     - `createSlice`, which takes care of the work of generating action type strings, action creator functions, and action objects. 
     - name, initialState, action names with each reducers
     - counterSlice.reducer({value : 1}, counterSlice.actions.incrementByValue(10)) // 11

     ```js
     import { createSlice } from '@reduxjs/toolkit'
     
     export const counterSlice = createSlice({
       name: 'counter',
       initialState: {
         value: 0
       },
       reducers: {
         increment: state => {
           // Redux Toolkit allows us to write "mutating" logic in reducers. It
           // doesn't actually mutate the state because it uses the immer library,
           // which detects changes to a "draft state" and produces a brand new
           // immutable state based off those changes
           state.value += 1
         },
         decrement: state => {
           state.value -= 1
         },
         incrementByAmount: (state, action) => {
           state.value += action.payload
         }
       }
     })
     
     export const { increment, decrement, incrementByAmount } = counterSlice.actions
     
     export default counterSlice.reducer
     
     ```

   - immutability

     - handwritten update for immutable update

       ```js
       const obj = {
         a: {
           // To safely update obj.a.c, we have to copy each piece
           c: 3
         },
         b: 2
       }
       
       const obj2 = {
         // copy obj
         ...obj,
         // overwrite a
         a: {
           // copy obj.a
           ...obj.a,
           // overwrite c
           c: 42
         }
       }
       
       const arr = ['a', 'b']
       // Create a new copy of arr, with "c" appended to the end
       const arr2 = arr.concat('c')
       
       // or, we can make a copy of the original array:
       const arr3 = arr.slice()
       // and mutate the copy:
       arr3.push('c')
       ```

     - easier with `immer` library

       ```js
       function reducerWithImmer(state, action) {
         state.first.second[action.someId].fourth = action.someValue
       }
       ```

     - Even more easier with `createSlice` (and `createReducer`)

       ```js
       const slice = createSlice({
         name :'counter',
         initialState: {
       		value:0
         },
         reducers : {
           increment : state => {
             state.value += 1;
           },
           incrementByAmount : (state, action) => {
             state.vallue += action.payload
           }
         }
       })
       ```

   - Thunk

     - A **thunk** is a specific kind of Redux function that can contain asynchronous logic.
     - using thunks requires that the `redux-thunk` *middleware* (a type of plugin for Redux) be added to the Redux store when it's created. Fortunately, Redux Toolkit's `configureStore` function already sets that up for us automatically, so we can go ahead and use thunks here.

     ```js
     // the outside "thunk creator" function
     const fetchUserById = userId => {
       // the inside "thunk function"
       return async (dispatch, getState) => {
         try {
           // make an async call in the thunk
           const user = await userAPI.fetchById(userId)
           // dispatch an action when we get the response back
           dispatch(userLoaded(user))
         } catch (err) {
           // If something went wrong, handle it here
         }
       }
     }
     
     store.dispatch(fetchUserById('redux_lover'))
     ```

   - react-redux

     - useSelector extract only needed part from the state
     - useDispatch gives dispatch method without access to the store

     ```js
     export const selectCount = state => state.counter.value
     ```

     ```js
     import { useSelector, useDispatch } from 'react-redux'
     import {
       ...,
       selectCount
     } from './counterSlice'
     
     export function Counter() {
       const count = useSelector(selectCount)
       const dispatch = useDispatch()
       ...
     ```

   - store

     ```js
     import { Provider } from 'react-redux'
     
     ReactDOM.render(
       <Provider store={store}>
         <App />
       </Provider>,
       document.getElementById('root')
     )
     
     ```

3. Basic Redux Data Flow




## core redux

```bash
yarn add redux
```

```js
function myReducer(state, action) {
  switch (action.type) {
    case "plus":
      return { value: state.value + 1 };
    case "minus":
      return { value: state.value - 1 };
    default:
      return state;
  }
}

const store = createStore(myReducer);
store.subscribe(() => console.log(store.getState()));

return (
  <div>
    <button onClick={() => store.dispatch("plus")}>+</button>
    <button onClick={() => store.dispatch("minus")}>-</button>
  </div>
);
```

## redux toolkit

```bash
// existing project
yarn add @reduxjs/toolkit

// new project
npx create-react-app {my-app} --template redux-typescript
```

```js
import { createSlice, configureStore } from "@reduxjs/toolkit";

const counterSlice = createSlice({
  name: "counter",
  initialState: {
    value: 0,
  },
  reducers: {
    incremented: (state) => {
      state.value += 1;
    },
    decremented: (state) => {
      state.value -= 1;
    },
  },
});

const { incremented, decremented } = counterSlice.actions;
const store = configureStore({
  reducer: counterSlice.reducer,
});
store.subscribe(() => console.log(store.getState()));

const App = () => (
  <div>
    <button onClick={() => store.dispatch(incremented())}>+</button>
    <button onClick={() => store.dispatch(decremented())}>-</button>
  </div>
);

export default App;
```

```javascript
import { Provider } from "react-redux";
import { createStore } from "redux";

function reducer(weight, action) {
  if ((action = "minus")) {
    weight--;
  } else if ((action = "plus")) {
    weight++;
  }
  return weight;
}

let store = createStore(reducer);

ReactDOM.render(
  <React.StrictMode>
    <Provider store={store}>
      <App />
    </Provider>
  </React.StrictMode>
);
```

`App.tsx`

```javascript
import "./App.css";
import { useSelector } from "react-redux";

function App() {
  const weight = useSelector((weight) => weight);
  return (
    <div className="App">
      <p>your miserable weight : {weight}</p>
    </div>
  );
}

export default App;
```

