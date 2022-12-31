# DOM

## 1. 노드개요

- nodeType

  HTML document 트리를 구성하는 노드 타입들의 차이는 서로 다른 nodeType 상수를 갖는다는 것.

  ```js
  for (var key in Node)
    console.log(key, " : ", Node[key])
  
  // ELEMENT_NODE :  1
  // ATTRIBUTE_NODE :  2
  // TEXT_NODE :  3
  // CDATA_SECTION_NODE :  4
  // ENTITY_REFERENCE_NODE :  5
  // ENTITY_NODE :  6
  // PROCESSING_INSTRUCTION_NODE :  7
  // COMMENT_NODE :  8 ;주석
  // DOCUMENT_NODE :  9 ; window.document
  // DOCUMENT_TYPE_NODE :  10 ; <!DOCTYPE html>
  // DOCUMENT_FRAGMENT_NODE :  11
  // NOTATION_NODE :  12
  ```

- 상속
  Object ← Node ← Element ← HTMLElement ← HTMLAnchorElement

- nodeName, nodeType
  ```html
  <!DOCTYPE html>
  <html>
    <a href='http://naver.com'>hello world</a>  
  </html>
  ```

  - document.doctype.nodeName/nodeType = 'html'/10
  - document.nodeName/nodeType = '#document'/9
  - document.querySelector('a').nodeName/nodeType = 'A'/1(==Node.ELEMENT_NODE)
  - document.querySelector('a').firstChild.nodeName/nodeType = '#text'/3

- nodeValue

  TEXT_NODE, COMMENT_NODE 타입은 node.nodeValue 가 유효하고, 다른 타입의 노드는 null 값을 갖는다.

- createElement, createTextNode

  ```js
  var div = document.createElement('div') // div.tagName == 'DIV'
  var text = document.createTextNode('hello world') // text.nodeValue == 'hello world'
  ```

- document 의 Element,TextNode 를 read/write

  - innerHTML / outerHTML

  - textContent

  - innerText / outerText (비표준확장)

  - insertAdjacentHTML (Element 에만 사용 가능)

    ```js
    var elm = document.getElementById('elm')
    
    elm.insertAdjacentHTML('beforebegin', '<span>hey</span>')
    elm.insertAdjacentHTML('afterbegin', '<span>hey</span>')
    elm.insertAdjacentHTML('beforeend', '<span>hey</span>')
    elm.insertAdjacentHTML('afterend', '<span>hey</span>')
    ```

- appendChild, insertBefore

  ```html
  <ul>
    <li>2</li>
      <li>3</li>
  </ul>
  ```

  ```js
  var ul = document.querySelector('ul')
  
  var four = document.createElement('li')
  one.appendChild(document.createTextNode('4'))
  ul.appendChild(four)
  
  var one = document.createElement('li')
  one.appendChild(document.createTextNode('1'))
  ul.insertBefore(one, ul.firstChild)
  ```

  - Element : prepend, append, before, after

- removeChild, replaceChild

  ```js
  var divA = document.getElementById('A').firstChild
  divA.parentNode.removeChild(divA)
  
  var divB = document.getElementById('B').firstChild
  divB.parentNode.replaceChild(document.createTextNode('hello world'), divB)
  ```

  - 삭제/교체한 노드는 메모리에는 계속 존재하므로 memory leak 주의
  - Element : remove, replaceWith

- cloneNode
  - cloneNode
  - cloneNode(true) // 자식까지 복제
  - 복제할 때 추가된 이벤트 리스너는 복제되지 않음
  - console.log(document.getElementById('divA').cloneNode().constructor) // HTMLDivElement

- NodeList, HTMLCollection

  - document.querySelectorAll('*'), document.selectElementById('ul').childNodes // NodeList
  - document.scripts // HTMLCollection
  - NodeList, HTMLCollection 은 Array.isArray 호출에 false 반환
    - Array.prototype.slice.call(document.getElementById('divA')) // isArray == true
    - prototype.slice 호출로 Array 로 변환하면 forEach, pop, map, reduce 등을 사용할 수 있다.

- 관계노드 선택 (TEXT_NODE, COMMENT_NODE 를 제외한 Element 선택)

  ```html
    <ul id="ul"> // document.getElementById('A').parentElement
      <li id="A">a</li> // document.getElementById('ul').firstElementChild
      <li id="B">b</li> // document.getElementById('A').nextElementSibling
      <li id="C">c</li>
      <li id="D">d</li> // document.getElementById('E').previousElementSibling
      <li id="E">e</li> // document.getElementById('ul').lastElementChild
    </ul>
  ```

  

  - parentNode (parentElement)
  - childNodes (children)
  - firstChild (firstElementChild)
  - lastChild (lastElementChild)
  - nextSibling (nextElementChild)
  - previousSibling (previousElementChild)

- Node 위치 확인

  - document.getElementById('B').contains(document.getElementById('A')) // true
    ```js
    for (var key in Node)
      console.log(key," : ",Node[key])
    // DOCUMENT_POSITION_DISCONNECTED :  1
    // DOCUMENT_POSITION_PRECEDING :  2
    // DOCUMENT_POSITION_FOLLOWING :  4
    // DOCUMENT_POSITION_CONTAINS :  8
    // DOCUMENT_POSITION_CONTAINED_BY :  16
    // DOCUMENT_POSITION_IMPLEMENTATION_SPECIFIC :  32
    ```

- isEqualNode
  ```html
    <body>
      <input type="text" />
      <input type="text" />
    </body>
  ```

  ```js
  var inp = document.querySelectorAll('input')
  inp[0]===inp[0] // true
  inp[0].isEqualNode(inp[1]) // true, but inp[0]!==inp[1], inp[0]!=inp[1]
  ```



## 2. Document 노드

- document === window.document
  
- document !== (Document Element)
  
- 도큐먼트는 도큐먼트 문서에 대한 바로가기와 도구들을 제공한다
  
  ```js
  // 생성자
  // window.document.nodeType == NodeType.DOCUMENT_NODE
  window.document.constructor // 브라우저에 로드되는 문서 생성
  window.document.implementation.createHTMLDocument // 브라우저와 별도의 문서 생성
  
  // window.document === document
  document.title
  document.url
  document.referrer
  document.cookie
  document.activeElement // 포커스를 가진 노드
  document.hasFocus() // 문서에 포크삭 있는지 여부
  document.defaultView // window
  document.ownerDocument === null
  document.head.ownerDocument === document
  
  document.doctype // <!DOCTYPE>, document.childNodes[0]
  document.documentElement // <html>...</html>, document.childNodes[1]
  document.head // <head>...</head>
  document.body // <body>...</body>
  ```
  



## 3. Element 노드

- 생성자
  ```js
  docuement.querySelector('a').constructor === window.HTMLAnchorElement
  ```

- 태그로 Element 생성
  ```js
  document.body.appendChild(document.createElement('textarea'))
  document.querySelector('textarea').tagName // TEXTAREA
  document.querySelector('textarea').nodeName // TEXTAREA
  ```

- attributes
  ```js
  document.querySelector('a').attributes // live 상태
  document.querySelector('a').hasAttribute('href')
  document.querySelector('a').setAttribute('href', '#')
  document.querySelector('a').getAttribute('href')
  document.querySelector('a').removeAttribute('href')
  ```

- Class attributes

  ```js
  document.querySelector('div').attributes["class"]
  
  document.querySelector('div').className // "clicker on"
  document.querySelector('div').classList // ["clicker", "on"]
  document.querySelector('div').classList.add("warning") 
  document.querySelector('div').classList.remove("warning") 
  document.querySelector('div').classList.toggle("warning")
  document.querySelector('div').classList.contains("warning")
  ```

- Data attributes

  ```js
  document.querySelector('div').attributes["data-foo-bar"]
  document.querySelector('div').removeAttributes('data-foo-bar')
  
  document.querySelector('div').dataset
  // {"fooBar" : "hello world" }, 'data-' 와 dash 를 제거하고 camelCase 로 표현됨
  delete document.querySelector('div').dataset.fooBar
  ```

  
