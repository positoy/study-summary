# CSS 레이아웃



### CSS 설계기법

- 레이아웃에 적용되는 셀렉터를 어떻게 정의할 것인가

- 여덟가지 포인트
  (프로그래밍 원칙과 유사합니다. 재사용 가능하게! 이해하기 쉽게!)
  
  - Readability
    - 클래스 이름에서 영향 범위를 유추할 수 있다
    - 클래스 이름에서 형태, 기능, 역할을 유추할 수 있다
    - 특성에 따라 CSS를 분류한다
  - Reusability
    - HTML과 스타일링을 느슨하게 결합한다
    - 영향범위를 지나치게 넓히지 않는다
    - 특정한 콘텍스트에 지나치게 의존하지 않는다
    - 상세도를 지나치게 높이지 않는다
    - 확장하기 쉽다
  
- 기반한 설계방식 5가지
  - OOCSS
  - SMACSS
  - BEM
  - PRECSS

- 2가지만 살펴보기
  - OOCSS (Object-Oriented CSS)

    - 스트럭처와 스킨 분리

      ```html
      <main id="main">
        <button class="btn general">기본버튼</button>
        <button class="btn warning">취소버튼</button>
      </main>
      ```

      ```css
      <!-- 스트럭처(부피?!) : width, height, padding, margin -->
      #main .btn {
        display:inline-block;
        width: 300px;
        max-width: 100%;
        padding: 20px 10px;
        font-size: 18px;
      }

      <!-- 스킨(색과 모양) : color, font, background, box-shadow, text-shadow -->
      #main .general {
        background-color : black;
        color : yellow;
      }

      #main .warning {
        background-color : gray;
        color : red;
      }
      ```

    - 컨테이너와 콘텐츠 분리

      - 모듈을 특정 영역에 의존하지 않도록 함

        ```html
        <main id="main">
          <button class="btn general">기본버튼</button>
          <button class="btn warning">취소버튼</button>
        </main>
        <footer>
          <button class="btn general">기본버튼</button>    
        </footer>
        ```

      - 위 예시에서 컨테이너는 `#main` 컨텐츠는  `.btn` 
      - 모든 셀렉터에서 컨테이너를 제거

  - BEM

    - Block, Element, Modifier

    - 클래스 셀렉터만 사용. Kebab 명명법 사용

    - Block : 재사용 가능한 부품, 레이아웃 설정이 들어가면 안됨 (color, position)

      - `{block}`

        ```html
        <div class="global-nav"></div>
        ```

    - Element : Block 을 구성

      -  `{block}__{element}`

        ```html
        <ul class="global-nav">
          <li class="global-nav__li">
            <a class="global-nav__link" href="tab1/">Tab 1</a>
          </li>
          <li class="global-nav__li">
            <a class="global-nav__link" href="tab2/">Tab 2</a>
          </li>
        </ul>
        ```

    - Modifer : Block, Element 의 모습이나 상태, 움직임을 정의하는 것 (단독 사용 불가)

      - `{block,element}_상태`

        ```html
        <ul class="global-nav">
          <li class="global-nav__li">
            <a class="global-nav__link" href="tab1/">Tab 1</a>
          </li>
          <li class="global-nav__li">
            <a class="global-nav__link global-nav__link_activated" href="tab2/">Tab 2</a>
        </li>
        </ul>
        ```

      - `{block,element}_상태 상태 상태`: 상태 이름에서 추론할 수 있도록

        ```html
        <a class="button button_size_s button_bg_color_red">red button</a>
        <a class="button button_size_s button_bg_color_green">green button</a>
        ```




- 소감과 결론 : 머리가 아프다. (톡톡처럼) SASS 를 사용하면 고민이 줄어든다. SASS를 배우자.
  
  - 레이아웃 계층으로 Nesting 가능 (중복과 실수의 우려가 적음)
  - (재사용성은 떨어지지만) 레이아웃의 구조 파악이 용이하고 유지보수가 용이하다. 스타일의 충돌은 피할 수 있다.
  - bootstrap 처럼 목적이 재사용에 있는 경우는 위의 설계기법이 유용할 것 같음
  - OOCSS 원칙은 scss 에서도 유효 `&.modifer`
    - https://sass-lang.com/guide



### 레이아웃 그려보기

#### 리셋 CSS

- 브라우저의 스타일 기본값을 제거하기 위해 사용
- https://codepen.io/ncerminara/pen/RLMwmy

#### Live Server

- vscode 에서 변경사항 바로 보기 플러그인

- https://marketplace.visualstudio.com/items?itemName=ritwickdey.LiveServer



### 레이아웃

#### (전통적인) 레이아웃

- 상자를 재귀적인 tree 형태로 배치
- 각 상자의 padding, margin, size 등을 명시하여 레이아웃 구성
  - 3단 구성 (header, content, footer)
  - 그 밖에 다양한 기능 영역들 ([GNB, LNB, SNB, FNB](https://chlolisher.tistory.com/62)) - 웹표준 아님 주의



#### (보다 똑똑한) Flexbox, Grid 레이아웃

- Flexbox

  - `display : grid;`

  - 컨테이너 안에서 아이템들이 정렬/나열되는 지배적인 법칙을 변경 (마치 중력처럼)

    - flex-direction 는 나열하는 방향을 정의하고,
    - justify-content 는 나열 방향에서의 정렬상태
    - align-items 는 쌓이는 방향의 정렬상태
    - 단, order 는 아이템에 적용

  - 정렬규칙

    - 가로정렬 `justify-content` : flex-start, center, flex-end, space-between, space-around

    - 세로정렬 `align-items` : flex-start, center, flex-end, baseline, stretch
      - 홀로세로정렬 `align-self`
    - 나열방향 `flex-direction` : row, row-reverse, column, column-reverse
    - 순서 `order`: {integer}
    - `flex-wrap`:nowrap, wrap, wrap-reverse
    - `flex-flow`: {row, row-reverse, column, column-reverse} + {nowrap, wrap, wrap-reverse}
    - `align-content`: 줄 간격을 조절. 한 줄만 있을 때에는 align-content 가 효과 없음.

  - [Flexbox froggy](http://flexboxfroggy.com/)

- Grid

  - `display : grid;`

  - 컨테이너의 그리드 구조를 정의하고,

    - `grid-template-columns`: px,em,% 또는 repeat(x, y%), fr
    - `grid-template-rows`: px,em,% 또는 repeat(x, y%)
    - `grid-template`

  -  아이템의 위치,길이를 정의

    - `grid-column-start`, `grid-column-end`

    - `grid-row-start`, `grid-row-end`

    - `span`

    - `grid-column`

    - `grid-row`

    - `grid-area`

    - `order`

      ![image-20210406233730496](/Users/positoy/Library/Application Support/typora-user-images/image-20210406233730496.png)

  - [Grid garden](https://codepip.com/games/grid-garden/)

