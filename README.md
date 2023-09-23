# jetty_public Jetty in Public Cloud

### Overview
기존의 3Tier 구성의 어플리케이션을 하이브리드 클라우드에서 사용하기 위해 backend의 기능을 분리하였다.
user들의 접근이 많은 페이지를 Public-cloud, data의 읽기 쓰기가 가능한 페이지들은 Private-cloud에 분리하여
Public-cloud는 트래픽 감당, Private-cloud는 데이터의 보안의 역할을 부여했다.

<img width="625" alt="스크린샷 2023-09-19 오후 11 48 09" src="https://github.com/Dr-pep4/jetty_public/assets/102319207/9b1ed93f-77db-4d6f-88de-4c2494b00e45">

<br>
 
#### 기존 구성 3Tier - backend

- 3 tier에서는 frontend에서 Nginx를 사용하고 Nginx의 index.html에서 바로 회원가입 후 로그인하여 backend인 Jetty에 접속하게 하였다.
- backend에서 동작할 어플레이케이션 JSP파일과, 배포를 위해 Dockerfile, RDS와의 연결을 위한 JDBC설정 파일, CI/CD를 위한 .yml파일로 구성되어 있다.

<br>

<br>

|function|file|Role|
|:-:|:-:|:-:|
|backend|main.jsp|메인페이지|
|backend|detail.jsp|상세페이지|
|backend|login.jsp|로그인|
|backend|register.jsp|회원가입|
|backend|admin_main.jsp|관리 페이지|
|backend|enroll.jsp|물품 등록|
|backend|delete.jsp|물품 삭제|
|database|jdbc-config.xml|RDS연결|
|Deployment|Dockerfile|이미지 배포|
|Git-Action|Openshift.yml|이미지 자동 배포|
|Git-Action|slack.yml|슬랙 알림|

<line>
<br>
   
    
#### 변형된 구성 HybridCloud - backend

- 기존의 3tier 구성에서 hybrid-cloud 구조에서 Public-cloud에서 사용하기 위해 구성을 변경하였다.
- public-cloud에서 유저들이 접속가능하며 상품 데이터를 읽기만 하는 메인페이지와 상세페이지를 분리시켰다.
- Public-cloud, Private-cloud 에서 공통적으로  Git-Action, JDBC, Dockerfile이 사용된다
    Git-Action에 사용되는 workflow는 할당되는 변수 값에만 약간의 변화가 있고, JDBC는 동일하며, Dockerfile은 jsp파일 의 구성이 다르다
  
<br>

|function|file|Role|
|:-:|:-:|:-:|
|backend|user_main.jsp|메인페이지|
|backend|user_detail.jsp|상세페이지|
|database|jdbc-config.xml|RDS연결|
|Deployment|Dockerfile|이미지 배포|
|Git-Action|Openshift.yml|이미지 자동 배포|
|Git-Action|slack.yaml|슬랙 알림|

<br>

## Deployment - Dockerfile

<line>

```
# Use the official Ubuntu base image
FROM ubuntu:22.04

# Set environment variables
ENV JETTY_VERSION=9.4.43.v20210629 \
    JETTY_HOME=/opt/jetty

# Install Java and Jetty
RUN apt-get update && \
    apt-get install -y openjdk-11-jre-headless curl && \
    rm -rf /var/lib/apt/lists/*

# Download and install Jetty
RUN mkdir -p ${JETTY_HOME} && \
    curl -SL "https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/${JETTY_VERSION}/jetty-distribution-${JETTY_VERSION}.tar.gz" | tar -xzC ${JETTY_HOME} --strip-components=1

# application contents
RUN mkdir -p ${JETTY_HOME}/webapps/ROOT

# Public cloud에서 사용할 메인페이지와 상세페이지
COPY user_main.jsp ${JETTY_HOME}/webapps/ROOT/user_main.jsp
COPY user_detail.jsp ${JETTY_HOME}/webapps/ROOT/user_detail.jsp



# configure file - RDS와 연동할 JDBC의 설정파일과 기본 index.jsp
COPY ./configure/jdbc-config.xml  ${JETTY_HOME}/etc/jdbc-config.xml
COPY ./configure/index.jsp /opt/jetty/webapps/ROOT/index.jsp





RUN apt-get update && \
    apt install dpkg
RUN apt-get update && \
    apt install wget


# MySQL connector 다운로드 후 lib로 복사

WORKDIR ${JETTY_HOME}
RUN wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j_8.1.0-1ubuntu22.04_all.deb
RUN dpkg -i mysql-connector-j_8.1.0-1ubuntu22.04_all.deb

RUN cp /usr/share/java/mysql-connector-j-8.1.0.jar ${JETTY_HOME}/lib/ext/mysql-connector-j-8.1.0.jar


# Expose the default Jetty port
EXPOSE 8080

# Set the working directory to Jetty's base directory
WORKDIR ${JETTY_HOME}
# Start Jetty
CMD ["java", "-jar", "start.jar"]

```
<line>
 
<br>

<line>
 
## Git-Action

<line>

<br>

### 1.openshift.yml

```
name: Restart OpenShift Build

on:
  push:
    branches:
      - main  # 트리거할 브랜치




jobs:
  restart_build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout jetty Repository
        uses: actions/checkout@v2
       

      - name: Set up OpenShift CLI
        uses: redhat-actions/oc-installer@v1
        with:
          openshift_server_url: ${{ secrets.OPENSHIFT_SERVER_URL }}
          openshift_token: ${{ secrets.OPENSHIFT_TOKEN }}
          
          
      - name: Set up OpenShift Configuration
        run: |
          mkdir -p $HOME/.kube
          echo "$OPENSHIFT_CONFIG" > $HOME/.kube/config
        env:
          OPENSHIFT_CONFIG: ${{ secrets.OPENSHIFT_CONFIG }}

      - name: Log into OpenShift Cluster
        run: oc login ${{ secrets.OPENSHIFT_API_ENDPOINT}} --username ${{secrets.ROSA_ID}} --password ${{secrets.ROSA_PASSWORD}}


      - name: Restart OpenShift Admin Build
        run: oc start-build jetty-public --from-dir=$GITHUB_WORKSPACE -n front

```

<line>

<br>

### 2.slack.yml

```
name: Slack Notification

on:
  push:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Set event timestamp
        id: event_timestamp
        run: echo "::set-output name=timestamp::$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
      
      - name: action-slack
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          author_name: You can get this as a pull request later
          fields: repo,commit,action,eventName,timestamp
          if_mention: failure, canceled
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK_URL }}
        if: always()
```
