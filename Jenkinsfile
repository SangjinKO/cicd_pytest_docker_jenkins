pipeline {
  agent none
  options { disableConcurrentBuilds() } // 동시 실행 방지 (워크스페이스 @2 꼬임 예방)
  environment { PYTHONPATH = "${WORKSPACE}" }

  stages {
    stage('Checkout') {
      agent { label 'docker-node' }  // 컨트롤러(도커 있는 곳)에서
      steps { checkout scm }
    }

    stage('Set Up Python Environment') {
      agent {
        docker {
          image 'python:3.11-alpine'
          reuseNode true              // 같은 워크스페이스 유지
        }
      }
      steps {
        sh '''
          python3 -m venv venv
          . venv/bin/activate
          pip install --upgrade pip
          pip install -r requirements.txt
        '''
      }
    }

    stage('Run pytest') {
      agent {
        docker {
          image 'python:3.11-alpine'
          reuseNode true
        }
      }
      steps {
        sh '''
          . venv/bin/activate
          pytest tests/ --junitxml=pytest-report.xml
        '''
      }
    }

    stage('Deploy') {
      agent { label 'docker-node' }   // 🔒 반드시 컨트롤러에서
      steps {
        sh 'echo NODE_NAME=$NODE_NAME || true'
        sh 'whoami; hostname; echo PATH=$PATH'
        sh 'ls -l /var/run/docker.sock || true'
        sh 'which docker || (echo "no docker"; exit 1)'
        sh 'docker version'
        sh 'docker compose up -d --no-deps --build myapp'
      }
    }
  }

  post { 
    always { 
      node('docker-node') {   // ← docker-node 라벨(혹은 built-in)로 지정
        junit 'pytest-report.xml'
      }
    } 
  }
}
