## 어노테이션

### @ExceptionHandler

Controller 내부에서 발생한 예외를 별도의 메소드에서 처리할 수 있게 해 준다

```java
@RestController
public class MyRestController {
  
  @GetMapping("/hello")
  public String hello() {
    return new NullPointerException("random throw");
  }

  @ExceptionHandler(NullPointerException.class)
  public Object nullex(Exception e) {
    System.err.println(e.getClass());
    return "error occurred";
  }
}
```



### @ControllerAdvice

모든 Controller, 또는 선언한 Cotnroller 에서 발생한 예외를 별도의 메소드에서 처리할 수 있게 해 준다.

`@RestControllerAdvice`는 `@ResponseBody`를 같이 선언해주는 효과가 있다 

```java
@ControllerAdvice(basePackageClasses = {CouponConfigController.class})
public class ApiExceptionHandler {
  
  @RestExceptionHandler(HttpMessageNotReadableException.class)
  public RemoteResponse resolveHttpMessageNotReadableException(HttpServletResponse response, Exception ex) {
    ...
      return "not readable";
  }
  
  @RestExceptionHandler(InvalidRequestBodyException.class)
  @ResponseStatus(HttpStatus.BAD_REQUEST)
  public RemoteResponse resolveInvalidRequestBodyException(InvalidRequestBodyException ex) {
    ...
      return "invalid request body";
  }
}
```



## 자바

### ThreadLocal

스레드에 Generic Type 으로 변수를 저장할 수 있는 클래스. get(), set(), remove() 메소드를 사용한다.
요청 당 하나의 스레드가 처리하는 점을 이용하여 요청 단위의 변수 관리가 가능하다. filter 에서 비즈니스 로직에 필요한 도메인 오브젝트를 ThreadLocal 에 저장해놓고 Controller 에서 처리하는 식. 참고로, 동일한 타입을 여러개 관리하고 싶을 수도 있으니 NamedThreadLocal 을 제공한다.

```java
public abstract class Domain {
	private static final ThreadLocal<ServiceDomain> threadLocal = new NamedThreadLocal<ServiceDomain>("ServiceDomain");

	public static ServiceDomain get() {
		return threadLocal.get();
	}
```



### CollectionUtils

empty 확인 시 null 체크를 피하기 위해 사용

```java
if (CollectionUtils.isNotEmpty(obj)) {
  ///
}
```

- 