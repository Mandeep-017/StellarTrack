pipeline {
    agent any
    environment {
        NGINX_PATH = 'C:\\nginx\\html\\stellartrack'
    }
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/rishabkm/StellarTrack.git', 
                     branch: 'main'
            }
        }
        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    bat 'terraform init'
                }
            }
        }
        stage('Deploy') {
            steps {
                dir('terraform') {
                    bat 'terraform apply -auto-approve'
                }
            }
            post {
                failure {
                    bat 'powershell -File terraform\\rollback.ps1'
                    script {
                        // Trigger rollback in Jenkins if deployment fails
                        def buildUrl = "http://localhost:8080/job/automation/${BUILD_NUMBER}/rebuild"
                        sh "curl -X POST ${buildUrl}"
                    }
                }
            }
        }
        stage('Restart NGINX') {
            steps {
                bat '''
                    taskkill /F /IM nginx.exe || echo "NGINX not running"
                    start "" "C:\\nginx\\nginx.exe"
                '''
            }
        }
    }
}
