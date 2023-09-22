# jetty_public Jetty in Public Cloud

### Overview
- 기존의 3Tier 구성의 어플리케이션을 하이브리드 클라우드에서 사용하기 위해
<img width="625" alt="스크린샷 2023-09-19 오후 11 48 09" src="https://github.com/Dr-pep4/jetty_public/assets/102319207/9b1ed93f-77db-4d6f-88de-4c2494b00e45">

#### 3Tier-backend

|function|file|Role|
|:-:|:-:|:-:|
|backend|main.jsp|메인페이지|
|backend|detail.jsp|상세페이지|
|backend|login.jsp|로그인|
|backend|register.jsp|회원가입|
|backend|admin_main.jsp|관리 페이지|
|backend|enroll.jsp|물품 등록|
|backend|delete.jsp|물품 삭제|
|Deployment|Dockerfile|이미지 배포|
|Git-Action|Openshift.yml|이미지 자동 배포|
|Git-Action|slack.yaml|슬랙 알림|
