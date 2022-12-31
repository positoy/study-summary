### openssl

- 대칭암호화 (aes, des)

  ```bash
  sudo openssl aes-256-cbc -salt -in file -out file.enc
  sudo openssl aes-256-cbc -d -in file.enc -out file
  ```

  

- 비대칭암호화 (rsa)

  ```bash
  // 개인키 생성
  openssl genrsa -out private.pem 1024
  
  // 공개키 생성
  openssl rsa -in private.pem -out public.pem -outform PEM -pubout
  
  // 암호화
  openssl rsautl -encrypt -inkey public.pem -pubin -in file -out file.enc
  
  // 복호화
  openssl rsautl -decrypt -inkey private.pem -in file.enc -out file
  ```



### bash string

```bash
# 빈칸을 delimiter 로 분리하여 두번째 field 만 출력
cat ./file.txt | cut -d' ' -f2

# 압축파일 내부의 내용 검색
zgrep "text" encr*gz

# 입력을 record 로 취급하여, 입력 길이 10 이상이면 3,4,5번 필드를 출력
awk 'length($0) > 10 { print $3, $4, $5}' ./file.txt
```



