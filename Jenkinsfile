pipeline 
{
       agent {

        label "master"

    }

    environment 
    {


        NEXUS_VERSION = "nexus3"


        NEXUS_PROTOCOL = "http"


        NEXUS_URL = "127.0.0.1:8081"


        NEXUS_CREDENTIAL_ID = "adminnexus"
    }  

    stages 
    {

        stage('Build') 
        { 
            parallel
            {
                stage ('Backend')
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
                        sh'echo this is frontend Build'
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
  stage('Nexus & Docker'){
  parallel{
        stage("publish  war file on nexus") 
        {
            steps 
            {
                script 
                {
                    // Read POM xml file using 'readMavenPom' step , this step 'readMavenPom' is included in: https://plugins.jenkins.io/pipeline-utility-steps
                    pom = readMavenPom file: "pom.xml";
                    
                    // Find built artifact under target folder
                    filesByGlob = findFiles(glob: "*.war");
                    
                  
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

           stage('Build Docker image')
            {
            
                steps 
                {
                    sh 'docker build --no-cache -t webapp:${BUILD_NUMBER} .'             
                }
            }
        }
        }
     
                stage('Publish Docker image on Nexus')
                {
                    steps
                    {
                       sh 'docker login -u admin -p kerro1235 127.0.0.1:8083; docker tag webapp:${BUILD_NUMBER} 127.0.0.1:8083/webapp:${BUILD_NUMBER}; docker push 127.0.0.1:8083/webapp:${BUILD_NUMBER}'

                    }
                }
                stage('Katalon')
                {
                    steps
                    {
                        sh'echo integratrion tests'
                    }
                }
                stage ('Start and run container')
                {
                    steps
                    {
                        sh'docker run --name webapp_${BUILD_NUMBER} webapp_${BUILD_NUMBER}'
                    }
                }
            stage('Ansible')
                {
                    steps
                    {
                        sh'echo ansible'
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