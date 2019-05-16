import groovy.json.JsonSlurper
import groovy.json.JsonOutput
def jsonSlurper = new JsonSlurper()
def jsonOutput = new JsonOutput()
import hudson.FilePath
import hudson.*
hudson.FilePath workspace = hudson.model.Executor.currentExecutor().getCurrentWorkspace()

String DaiichiDirectory = 'daiichi-deployment'
String GITrepoLink = "https://github.com/reancloud/daiichi-landing-zone.git"
String GITBranch = "*/DCH-162"

folder DaiichiDirectory
freeStyleJob("$DaiichiDirectory"+"/"+'git_to_codecommit_sync'){

wrappers {
        preBuildCleanup()
         }  
   
scm {
	git {
			branch("$GITBranch")
			remote 
			{ 
			url("$GITrepoLink") 
			credentials('daiichi-github-service-account')
			}
        }
    }
    
triggers 
    {
    scm('* * * * *')
    }
 deliveryPipelineConfiguration('git_to_codecommit_sync')
steps 
   {
              
def shell_script_string = """\
#!/bin/bash 
git config --global credential.helper '!aws codecommit credential-helper \$@' 
git config --global credential.useHttpPath true 
src_git_url='https://github.com/reancloud/daiichi-landing-zone.git' 
dest_git_url='https://git-codecommit.us-east-1.amazonaws.com/v1/repos/daiichi-landing-zonesss' 
git clone \$src_git_url 
cd devops 
git checkout  master 
git pull origin master 
git push \$dest_git_url master:master 
	"""
shell(shell_script_string)
   }
}

listView('dsl') {
    jobs {
        name('seed-job')
    }
   columns {
        status()
        weather()
        name()
        lastSuccess()
        lastFailure()
        lastDuration()
        buildButton()
    }
}
