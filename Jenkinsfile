#!/usr/bin/groovy

@Library(['github.com/indigo-dc/jenkins-pipeline-library@1.2.3']) _

pipeline {
    agent {
        label 'docker-build'
    }

    environment {
        dockerhub_repo = "deephdc/deep-oc-semseg_vaihingen"
        base_cpu_tag = "1.12.0"
        base_gpu_tag = "1.12.0-gpu"
    }

    stages {
        stage('Validate metadata') {
            steps {
                checkout scm
                sh 'deep-app-schema-validator metadata.json'
            }
        }
        stage('Docker image building') {
            when {
                anyOf {
                   branch 'master'
                   branch 'test'
                   buildingTag()
               }
            }
            steps{
                checkout scm
                script {
                    // build different tags
                    id = "${env.dockerhub_repo}"

                    if (env.BRANCH_NAME == 'master') {
                       // CPU (aka latest, i.e. default)
                       id_cpu = DockerBuild(id,
                                            tag: ['latest', 'cpu'], 
                                            build_args: ["tag=${env.base_cpu_tag}",
                                                         "pyVer=python",
                                                         "branch=master"])
                       // Check that default CMD is correct by starting the image
                       sh "bash ./check_docker_start.sh ${env.dockerhub_repo}"

                       // GPU
                       id_gpu = DockerBuild(id,
                                            tag: ['gpu'], 
                                            build_args: ["tag=${env.base_gpu_tag}",
                                                         "pyVer=python",
                                                         "branch=master"])
                    }

                    if (env.BRANCH_NAME == 'test') {
                       // CPU
                       id_cpu = DockerBuild(id,
                                            tag: ['test', 'cpu-test'], 
                                            build_args: ["tag=${env.base_cpu_tag}",
                                                         "pyVer=python",
                                                         "branch=test"])
                       // Check that default CMD is correct by starting the image
                       sh "bash ./check_docker_start.sh ${env.dockerhub_repo}:test"

                       // GPU
                       id_gpu = DockerBuild(id,
                                            tag: ['gpu-test'], 
                                            build_args: ["tag=${env.base_gpu_tag}",
                                                         "pyVer=python",
                                                         "branch=test"])
                    }

                }
            }
            post {
                failure {
                    DockerClean()
                }
            }
        }



        stage('Docker Hub delivery') {
            when {
                anyOf {
                   branch 'master'
                   branch 'test'
                   buildingTag()
               }
            }
            steps{
                script {
                    DockerPush(id_cpu)
                    DockerPush(id_gpu)
                }
            }
            post {
                failure {
                    DockerClean()
                }
                always {
                    cleanWs()
                }
            }
        }
        stage("Render metadata on the marketplace") {
            when {
                allOf {
                    branch 'master'
                    changeset 'metadata.json'
                }
            }
            steps {
                script {
                    def job_result = JenkinsBuildJob("Pipeline-as-code/deephdc.github.io/pelican")
                    job_result_url = job_result.absoluteUrl
                }
            }
        }
    }
}
