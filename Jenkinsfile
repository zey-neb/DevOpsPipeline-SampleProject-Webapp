pipeline 
{
    agent 
    {

        label "master"

    }

    environment 
    {


        NEXUS_VERSION = "nexus3"


        NEXUS_PROTOCOL = "http"


        NEXUS_URL = "127.0.0.1:8081"


        NEXUS_CREDENTIAL_ID = "nexus"
    }  

    stages 
    {

        stage('Build') 
        { 
            parallel
            {
                stage('Backend')
                {
                    steps 
                    {
                       
                            sh 'mvn clean install'
                       
                    }
                }
                stage('Frontend')
                {
                    steps 
                    {
                       
                            sh 'echo Frontend Build ...'
                       
                    }
                }

            }
                    
        }

         stage('Sonarqube') 
        {
             environment
            {
                scannerHome = tool 'sonarQube Scanner'
            }    
            steps 
            {
               
                    withSonarQubeEnv('Mysonarqube') 
                    {
                            sh "mvn sonar:sonar"
                    }    
                
            }
        }
         stage('Build Docker image')
                {
                
                    steps 
                    {
                        sh 'docker build --no-cache -t webapp:${BUILD_NUMBER} .'             
                    }
                }
          stage('Nexus')
          {
              parallel
              {
                stage("publish  war file on nexus") 
                {
                    steps 
                    {
                        script 
                        {
                            // Read POM xml file using 'readMavenPom' step , this step 'readMavenPom' is included in: https://plugins.jenkins.io/pipeline-utility-steps
                            pom = readMavenPom file: "pom.xml";
                            
                            // Find built artifact under target folder
                            filesByGlob = findFiles(glob: "target/*.war");
                            
                          
                            // Extract the path from the File found
                            artifactPath = filesByGlob[0].path;
                            
                            // Assign to a boolean response verifying If the artifact name exists
                            artifactExists = fileExists artifactPath;
                            
                            if(artifactExists) 
                            {
                                echo "*** File: ${artifactPath}, group: ${pom.groupId}, packaging: ${pom.packaging}, version ${pom.version}";
                                nexusArtifactUploader(
                                
                                nexusVersion: NEXUS_VERSION,
                                protocol: NEXUS_PROTOCOL,
                                nexusUrl: NEXUS_URL,
                                groupId: pom.groupId,
                                version: pom.version,
                                repository: "WebApp",
                                credentialsId: NEXUS_CREDENTIAL_ID,
                                
                                artifacts: [
                                
                                // Artifact generated such as .jar, .ear and .war files.
                                [artifactId: pom.artifactId,
                                classifier: '',
                                file: artifactPath,
                                type: 'war'],
                                
                                
                                ]
                                );
                            } 
                            else 
                            {
                                error "*** File: ${artifactPath}, could not be found";
                            }
                        }
                    }
                }
                 stage('Publish Docker image on Nexus')
                {
                    steps
                    {
                       sh 'docker login -u admin -p vneuron 127.0.0.1:8083; docker tag webapp:${BUILD_NUMBER} 127.0.0.1:8083/webapp:${BUILD_NUMBER}; docker push 127.0.0.1:8083/webapp:${BUILD_NUMBER}'

                    }
                }

              
            }
        }
     
               
             
               
              
            stage('Ansible-Start and run container')
                {
                    steps
                    {
                        sh'bash ./shutdown.sh 1238'
                       ansiblePlaybook( 
                            colorized: true, 
                            inventory: 'hosts',
                            playbook: 'tomcat_playbook.yml',
                            extras: "--extra-vars 'ansible_become_pass=toor image=webapp:${BUILD_NUMBER}'"
                        )
                    }
                }

             stage('Katalon')
                {
                    steps
                    {
                        sh'bash ./Katalon.sh'
                    }
                }
            stage('Nagios')
                {
                    steps
                    {
                        sh'echo Nagios'
                    }
                }
            
        }
    
}