# cicd_pytest_docker_jenkins

## Goal: Create a CI/CD pipeline including an automated test(QA)

## Tools: Github, Jenkins, Pytest, Docker(docker-compose)

## Workflow

### Step 1. Run a docker-compose (.yml)
- Run a Jenkins server
- Run a App (build > deploy)
  
### Step 2. Create a job on Jenkins
- Trigger the job for Github push (Github webhook)

### Step 3. Run a Jenkins job
- 3.1 Checkout (Github)
- 3.2 Set up Env (Python, venv)
- 3.3 Test (Pytest)
- 3.4 Deploy (docker-compose)
- - Download from SCM(github repo.) > Build > Deploy 
- 3.5 Test Result Report (JUnit) 

<img width="971" height="328" alt="image" src="https://github.com/user-attachments/assets/90b61272-fa08-45c1-91ff-b6d175ea2669" />
