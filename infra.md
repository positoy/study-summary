# 개발인프라 구축

- 소나큐브
  - 정적분석 자동화
  - GitHub pr/merge → hook → Jenkins 에서 lint, sonarqube 동작 → sonarqube 리포트 → GitHub 에 결과 코멘트
  - hook 과 함께 GitHub 앱을 이용할 수 있음
- ESLint + Typescript + Prettier
  - 두가지 솔루션이 있음
    - [prettier-eslint-cli](https://github.com/prettier/prettier-eslint-cli) prettier 먼저 적용 후 eslint --fix 적용
    - [eslint-plugin-prettier](https://github.com/prettier/eslint-plugin-prettier) + [eslint-config-prettier](https://github.com/prettier/eslint-config-prettier) eslint 에서 문제점을 알려줌
  - 두가지 모두 적용하면 prettier 를 강제하고, 혹시 빠진 것이 있더락도 소나큐브에서 알려주므로 완벽
  - 스타일 교정, 정적분석
  - js 의 경우 코드 분석기인 eslint 와 formatter인 prettier 적용 가능
  - 마찬가지로 GitHub pr/merge 시 hook 을 이용하여 Jenkins 빌드하여 자동화

```bash
# 프로젝트 설정
yarn init

yarn add -D typescript eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin prettier eslint-plugin-prettier eslint-config-prettier prettier-eslint

vim .eslintrc.json
```

```json
// .eslintrc.json
{
  "parser": "@typescript-eslint/parser",
  "parserOptions": {
    "project": "./tsconfig.json"
  },
  "env": {
    "node": true
  },
  "extends": [
    "airbnb-base",
    "plugin:@typescript-eslint/recommended", // typescript
    "plugin:prettier/recommended", // prettier plugin(설정) + config(충돌제거)
    "prettier/@typescript-eslint" // typescript 충돌제거
  ]
}
```

```bash
# 실행
npx eslint --ext .js,.ts src
npx eslint src/**/*
```

```json
// vscode eslint 플러그인 설치 후 설정
{
  "eslint.validate": [
    { "language": "typescript", "autoFix": true },
    { "language": "typescriptreact", "autoFix": true }
  ]
}

// vscode prettier 플러그인 설치 후 설정
{
  "javascript.format.enable": false,
  "typescript.format.enable": false,
  "prettier.eslintIntegration": true
}
```

```json
// .prettierrc
{
    "printWidth": 120,
    "tabWidth": 4,
    "semi": false,
    "singleQuote": true,
    "trailingComma": "all",
    "jsxBracketSameLine": true,
    "bracketSpacing": true
}
```



