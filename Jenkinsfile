pipeline {
    agent any
    
    tools{
        jdk "jdk"
        maven "maven"
        
    }
    
    environment{
        SCANNER_HOME= tool 'sonar-scanner'
    }

    stages {
        stage('Git Checkout') {
            steps {
                echo "Git "
                git branch: 'devsecops', changelog: false, poll: false, url: 'https://github.com/17J/bookstore_spring_boot_project.git'
            }
        }
        stage('Trivy Repo Scan') {
            steps {
                sh 'trivy repo --format table -o repo-report.html https://github.com/17J/bookstore_spring_boot_project.git'
            }
        }
        stage('Compile') {
            steps {
                dir('/var/lib/jenkins/workspace/BookStore/bookStore/') {
                sh 'mvn compile'
               }
            }
        }
        stage('Test') {
            steps {
                dir('/var/lib/jenkins/workspace/BookStore/bookStore/') {
                sh 'mvn test -DskipTests=true'
               }
            }
        }
        stage('Code Analysis') {
            steps {
                withSonarQubeEnv('sonar-scanner') {
                    
                    sh ''' $SCANNER_HOME/bin/sonar-scanner  -Dsonar.projectName=bookstore \
                           -Dsonar.java.binaries=.\
                           -Dsonar.projectKey=bookstore '''
   
                    }
   
                    }
            }
        
        stage('Quality Gate') {
            steps {
                script{

                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-cred'
               }
            }
        }
        stage('Build') {
            steps {
               dir('/var/lib/jenkins/workspace/BookStore/bookStore/') {
                sh 'mvn package -DskipTests=true'
               }
            }
        }
        stage('Build Docker Image') {
            steps {
                script{
                    withDockerRegistry(credentialsId: 'docker-cred') {
                    dir('/var/lib/jenkins/workspace/BookStore/bookStore/') {
                     sh 'docker build -t bookstore .'
                      }
                    
                  }
                }
            }
        }
        stage('Trivy Docker Image Scan') {
            steps {
                sh 'trivy image --format table -o image-report.html bookstore '
            }
        }
        stage('Push Docker push ') {
            steps {
                script{
                    withDockerRegistry(credentialsId: 'docker-cred') {
                    
                     sh 'docker tag bookstore 17rj/mybook'
                     sh 'docker push  17rj/mybook'
                  }
                }
            }
        }
        stage('Deploy To K8s ') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'main-eks17', contextName: '', credentialsId: 'kube-cred', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://83EBF1F40997BF0376036EC15290F6BB.sk1.us-east-1.eks.amazonaws.com') {
                dir('/var/lib/jenkins/workspace/BookStore/bookStore/') {
                  sh 'kubectl apply -f db.yaml -n webapps'
                  sh 'kubectl apply -f frontend-deployment.yml -n webapps'
                  sh 'kubectl apply -f frontend-service.yml -n webapps'
                  sleep 60
                  
               }
               }
            }
        }
        stage('Verify To K8s ') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'main-eks17', contextName: '', credentialsId: 'kube-cred', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://83EBF1F40997BF0376036EC15290F6BB.sk1.us-east-1.eks.amazonaws.com') {
                
                  sh 'kubectl get pods  -n webapps'
                  sh 'kubectl get svc -n webapps'                  
                  
                  
               
               }
            }
        }
    }
}
