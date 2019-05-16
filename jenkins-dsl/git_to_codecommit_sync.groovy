import groovy.json.JsonSlurper
import groovy.json.JsonOutput
def jsonSlurper = new JsonSlurper()
def jsonOutput = new JsonOutput()
import hudson.FilePath
import hudson.*
hudson.FilePath workspace = hudson.model.Executor.currentExecutor().getCurrentWorkspace()

String DaiichiDirectory = 'Daiichi-Deployment'
String GITrepoLink = "https://github.com/amiviju/devops.git"
String GITBranch = "*/master"

folder DaiichiDirectory
freeStyleJob("$DaiichiDirectory"+"/"+'Daiichi-Git-CodeCommit-Sync-Job'){

wrappers {
        preBuildCleanup()
         }  
   
scm {
	git {
			branch("$GITBranch")
			remote 
			{ 
			url("$GITrepoLink") 
			credentials('git-key')
			}
        }
    }
    
triggers 
    {
    scm('* * * * *')
    }
 deliveryPipelineConfiguration('Daiichi-Git-CodeCommit-Sync-Job')
steps 
   {
              
def shell_script_string = """\
#!/bin/bash 
git config --global credential.helper '!aws codecommit credential-helper \$@' 
git config --global credential.useHttpPath true 

src_git_url='https://github.com/amiviju/devops' 
dest_git_url='https://git-codecommit.us-east-1.amazonaws.com/v1/repos/rc-daii' 
git clone \$src_git_url 
cd devops 
git checkout  master 
git pull origin master 
git push \$dest_git_url master:master 
	"""
shell(shell_script_string)
   }
}

deliveryPipelineView('dsl-pipeline') {
	pipelines {
		component('name',"$DaiichiDirectory"+"/"+'Daiichi-Git-CodeCommit-Sync-Job')
	}
}
