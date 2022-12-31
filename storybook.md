# Storybook

- 시작

  ```bash
  $ npx sb init
  $ yarn install
  $ yarn storybook
  $ yarn build-storybook
  ```

- main.js

  - stories 와 addon 설정

- {Component}.stories.tsx

  - component
    - Component, title 명시
    - `export default { title:"Examples/Header", component:Header }`

  - stories
    - state에 따른 component 표시
    - Template을 이용하여 state 형식을 규정
    - `export const LoggedIn = Template.bind({}); LoggedIn.args = { ... }`
    - control, action 등을 사용하여 storybook 에서 직접 조작하고 반응을 확인할 수 있는 등 기능 제공

  

