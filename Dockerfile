FROM python:3.10-alpine

# 필수 패키지 설치 (selenium 실행을 위한 chromium, webdriver 등)
# RUN apk update && apk add chromium chromium-chromedriver

# 작업 디렉터리 지정
WORKDIR /app

# 의존성 패키지 설치
# COPY requirements.txt .
# RUN pip install --upgrade pip
# RUN pip install -r requirements.txt

# 소스 코드 복사
COPY . .

# 로그 버퍼링 해제
ENV PYTHONUNBUFFERED=1

# pytest 자동 실행 (컨테이너가 실행될 때 자동으로 테스트를 수행)
CMD ["python", "-u", "app_loop.py"]
