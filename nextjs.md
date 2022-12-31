

# Next

## Getting Started

React UI Component 기반의 페이지를 static/dynamic 하게 렌더링해주는 서버 프레임워크

- Fast Refresh
  웹소켓 이용하여 pre-rendering 된 static 리소스가 변경되면 페이지에 즉시 반영됨

- Link
  next/link 로 제공되는 컴포넌트로, a 대신 Link 태그를 사용하면 백그라운드로 함께 로딩 됨. 속도 빠르고 dom 객체의 컨텍스트가 유지되는 client side navigation 가능.

- 렌더링

  - pre-rendering (default)
    빌드타임 렌더링하여 static 페이지 생성. 하지만 getStaticProps, getStaticPaths 이용해서 빌드 타임에 동적인 내용의 페이지를 생성할 수도 있음.
  - server-side rendering
    getServerSidePros 이용해서 요청마다 새롭게 페이지 렌더링.

- CSS

  - CSS-in-JS library (styled-jsx)

    - js 파일 안에 파일의 scope로 제한되는 css 정의 가능

    ```javascript
    <style jsx>{` ... `}</style>
    ```

  - CSS Modules

    - css 를 통째로 오브젝트 import 가능
    - 클래스 이름을 자동으로 생성

    ```javascript
    import styles from './layout.module.css'
    
    export default function Layout({children}) {
      return <div className={styles.container}>{children}</div>
    }
    ```

    - Global Styles
      `pages/_app.js` 에 모든 component 가 참조할 수 있는 App Component 를 선언하여, context 나 global css를 적용할 수 있다.

      ```javascript
      import '../styles/global.css'
      
      export default function App({Copmonent, pageProps}) {
        return <Component {...pageProps}/>
      }
      ```


- Pre-rendering and fetch data

  - 속도가 좋아지고 Search Engine Optimization 할 수 있음

  - javascript 없이도 Link 되지 않은 페이지들이 정상 로드 됨

  - 2가지

    - static generation without data

      ```javascript
      
      function getPostsData() {
        // read fs
        // fetch remote data
        // query database
        
        return allPostsData
      }
      
      export async function getStaticProps() {
        const allPostsData = getPostsData()
        return {
          props : {
            allPostsData
          }
        }
      }
      
      export default function Home({allPostsData}){
        return (
          <Layout Home>
          	<ul>
            {
          		allPostsData.map({id, date, title} => {
        				<li key={id}>{title}<br/>{id}<br/>{date}</li>
              })
            }
            </ul>
          </Layout>
        )
      }
      ```

      

    - server-side rendering

      ```javascript
      export async function getServerSideProps(context) { // called at all request time
        return {
          props : {
            
          }
        }
      }
      ```

      

    - client-side rendering (like react.js)

      사용자가 static 페이지를 로드한 후에 데이터를 fetch 하여 클라이언트에서 추가로 렌더링 하는 방식.
      [SWR](swr.vercel.app) 라이브러리 사용

      ```javascript
      import useSWR from
      'swr'
      
      function profile() {
        const {data, error} = useSWR('/api/user', fetch)
        if (error) return <div>failed to load</div>
        if (!data) return <div>loading...</div>
        return <div>hello {data.name}!</div>
      }
      
      ```

- Dynamic Routes

  /page/posts/`[id].js`

  ```javascript
  export default function Post() {
    return <Layout>...</Layout>
  }
  
  export async function getStaticPaths() {
    // Return a list of possible value for id
    
    const paths = fs.readDirSync(postsDirectory).map(fileName => {
      return {
        params : {
          id : fileName.replace(/\.md$/, '')
        }
      }
    })
    
    return {
      paths,
      fallback : false
    }
  }
  
  export async function getStaticProps({ params }) {
    // Fetch necessary data for the blog post using params.id
    const paths = fs.read(process.cwd() + '/posts/' + params.id + '.md')
    
    return {
      props : {
        data : content
      }
    }
  }
  ```

  

- API Routes

## 그 외

### NextPage


