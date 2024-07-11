pipeline {
    agent { 
        label "swarm"
    }

    environment {
        PROJECT_NAME = "warehouse"
        PROJECT_ENV = "dev"

        REPOSITORY_AUTH = "gitlab"
        REPOSITORY_URL = "https://github.com/yeqifu/warehouse.git"

        REGISTRY_HOST = "172.16.115.11:5000"
    }

    parameters{
        choice(
            description: 'Docker image Arch?',
            choices: ['amd64', 'arm64', 'amd64,arm64'],
            name: 'arch',
        )
        booleanParam(
            defaultValue: true,
            description: "auto deploy to env?",
            name: 'autodeploy',
        )
        text(
            description: "helm deployment parameter.",
            name: "opts",
            defaultValue: "--set redis.type=internal --set mysql.type=internal --set nacos.type=internal",
        )
    }

    options {
        disableConcurrentBuilds abortPrevious: true
    }

    stages {
        stage('checkout') {
            steps {
                checkout scmGit(branches: [[name: "*/master"]], extensions: [[$class: "RelativeTargetDirectory"]], userRemoteConfigs: [[url: "${env.REPOSITORY_URL}"]])
            
            }
        }

        stage('compile') {
            steps {
                withDockerContainer(image: 'maven:3.5.2', args: '--net host -v m2:/root/.m2') {
                    sh "mvn clean package -Dmaven.test.skip=true"
                }
            }
        }

        stage('image') {
            steps {
                sh 'ls'
                sh label: 'build image', script: "nerdctl build --platform=${params.arch} --output type=image,name=${env.REGISTRY_HOST}/${env.PROJECT_NAME}/warehouse:${BUILD_NUMBER},push=true -f Dockerfile ."
            }
        }

        stage('deploy') {
            steps {
                script{
                    if(autodeploy) {
                        withKubeConfig(caCertificate: '', clusterName: 'kubernetes', contextName: 'default', credentialsId: 'kubeconfig', namespace: 'ruoyi', restrictKubeConfigAccess: false, serverUrl: 'https://172.16.115.11:6443') {
                            sh "helm upgrade -i warehouse --set hub=${env.REGISTRY_HOST}/${env.PROJECT_NAME}/warehouse --set tag=${BUILD_NUMBER} warehouse --create-namespace --namespace ${env.PROJECT_NAME}-${env.PROJECT_ENV}"
                        }
                    }
                }
            }
        }
    }
    // post { 
    //     cleanup{
    //         cleanWs()
    //     }
    // }
}