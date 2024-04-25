# service account

```
https://console.cloud.google.com/apis/dashboard
1. 새프로젝트
2. 상단 Api및 서비스 사용설정 -> google drive, google sheet(gsheet)
3. 상단 사용자 인증 정보 만들기 -> 서비스계정
3-1. 2 이 서비스 계정에 대한 엑세스 권한 .. 소유자 선택
4. 서비스 계정관리 -> 키 -> 키추가(json) 다운로드
```

# Need

```
a.json - google credential
.env - IS_DEV=true / ROBOT_ID=XX
```