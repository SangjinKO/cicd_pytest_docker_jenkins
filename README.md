# cicd_pytest_docker_jenkins

## Goal: Create a CI/CD pipeline including an automated test(QA)

## Tools: Github, Jenkins, Pytest, Docker(docker-compose)

## Why
 
테스트를 손으로 실행하면 언젠가 빠뜨린다. 빠뜨리면 깨진 채로 배포된다.
 
GitHub에 push하는 순간 테스트가 자동으로 돌고, 통과해야만 배포되는 파이프라인을 만들었다. Jenkins · Pytest · Docker를 조합해 테스트-배포 순서를 코드로 강제한다.
 
---
 
## Architecture
 
```
GitHub push
      ↓
Webhook → Jenkins 트리거
      ↓
Stage 1: Checkout          (GitHub → 워크스페이스)
      ↓
Stage 2: Set Up Python Env (python:3.11-alpine / venv + pip install)
      ↓
Stage 3: Run Pytest        (python:3.11-alpine / pytest + JUnit XML 생성)
      ↓ 통과해야만
Stage 4: Deploy            (호스트 / docker compose up --build)
      ↓
post:   JUnit Report       (호스트 / Jenkins UI에 결과 표시, 항상 실행)
```
 
| Stage | 실행 환경 | 역할 |
|---|---|---|
| Checkout | 호스트 (docker-node) | GitHub에서 코드 수신 |
| Set Up Python Env | python:3.11-alpine | venv 생성 + 의존성 설치 |
| Run Pytest | python:3.11-alpine | 테스트 실행 + JUnit XML 생성 |
| Deploy | 호스트 (docker-node) | `docker compose up --no-deps --build myapp` |
| JUnit Report | 호스트 (docker-node) | 테스트 결과 Jenkins UI 표시 (성공·실패 무관) |
 
---
 
## Key Design Decisions
 
**Jenkins를 Docker로 띄운다**
`docker compose up` 한 줄로 Jenkins 서버와 앱 컨테이너가 함께 올라온다. Jenkins 환경 자체를 `Jenkins.Dockerfile`과 `docker-compose.yml`로 코드화했다.
 
**Pytest를 `python:3.11-alpine` 컨테이너 안에서 실행한다**
Jenkins 호스트에 Python을 설치하지 않아도 된다. `reuseNode true`로 venv를 스테이지 간에 공유해서 매 스테이지마다 재생성하지 않는다.
 
**Deploy 스테이지는 반드시 호스트(docker-node)에서 실행한다**
`docker compose`는 호스트 Docker 데몬에 접근해야 한다. Python 스테이지처럼 컨테이너 안에서 돌리면 `docker` 명령을 찾지 못한다.
 
**`post { always { junit } }`**
테스트가 실패해도 JUnit 리포트는 항상 생성한다. 실패했을 때 "왜 실패했는지"를 Jenkins UI에서 바로 확인할 수 있어야 하기 때문이다.
 
**`disableConcurrentBuilds()`**
동시에 같은 잡이 두 번 실행되면 워크스페이스가 `workspace@2`로 분리된다. venv 경로가 꼬여 `pip install`한 패키지를 `pytest`가 못 찾는다. 동시 실행 자체를 막아서 해결했다.
 
**`docker.sock` 마운트**
Jenkins 컨테이너 안에서 호스트 Docker 데몬에 접근하기 위해 `/var/run/docker.sock`을 컨테이너에 마운트한다. 없으면 Jenkins 안에서 `docker` 명령이 동작하지 않는다.
 
---
 
## Tech Stack
 
| 항목 | 도구 |
|---|---|
| Language | Python 3.10+ |
| Test Framework | Pytest |
| CI Server | Jenkins (Docker로 실행) |
| Containerization | Docker, docker-compose |
| Test Report | JUnit XML |
| Trigger | GitHub Webhook |
 
---
 
## Repository Structure
 
```text
cicd_pytest_docker_jenkins/
├── Jenkinsfile              # 파이프라인 정의 (Checkout → Test → Deploy → Report)
├── Dockerfile               # 앱 컨테이너 이미지
├── Jenkins.Dockerfile       # Jenkins + Docker CLI 이미지
├── docker-compose.yml       # Jenkins + 앱 서비스 정의
├── app_loop.py              # 앱 소스 (add, subtract 함수)
├── requirements.txt         # pytest
└── tests/
    └── test_sample.py       # Pytest 테스트 케이스
```
 
---
 
## How to Run
 
### 1. Jenkins + 앱 컨테이너 실행
 
```bash
docker compose up -d
```
 
Jenkins UI: http://localhost:8080
 
### 2. Jenkins 초기 설정
 
```bash
# 초기 비밀번호 확인
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```
 
- Jenkins UI 접속 → 초기 비밀번호 입력 → 플러그인 설치 (기본 권장 설치)
- `docker-node` 라벨의 노드 설정 (Jenkins 내장 노드에 라벨 추가)
### 3. GitHub Webhook 설정
 
- GitHub 리포 → Settings → Webhooks → Add webhook
- Payload URL: `http://<Jenkins_IP>:8080/github-webhook/`
- Content type: `application/json`
- Trigger: `Just the push event`
### 4. Jenkins 잡 생성
 
- New Item → Pipeline
- Pipeline script from SCM → Git → 리포 URL 입력
- Script Path: `Jenkinsfile`
- GitHub hook trigger for GITScm polling 체크
### 5. 파이프라인 실행 확인
 
```bash
# 코드 변경 후 push
git add . && git commit -m "test" && git push
```
 
→ Jenkins 잡 자동 트리거 → Pytest 실행 → 통과 시 배포 → JUnit 리포트 확인

<img width="971" height="328" alt="image" src="https://github.com/user-attachments/assets/90b61272-fa08-45c1-91ff-b6d175ea2669" />
