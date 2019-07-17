/***************************************************************************************************
*  CD Pipeline Template Builder
*
*  This will build pipeline for Various builds
*  Main input to this job is a json payload
*           L.G 2017
***************************************************************************************************/
/***************************************************************************************************
*
* NOTES:
* This Jenkinsfile is ran from Jenkins with the following Parameters:
* - GEHC-App-Repo-Name
* It will use the repo name to find the correct repo, and download the artifacts.yml file
* It can then use that file to call the CFT Stack Creation and updates.
*
***************************************************************************************************/
////////////////////////////////// START OF PIPELINE ///////////////////////////////////////////////
node("master-shepherd")
{
  // Timestamp the whole proccess
  // This can be tuned from outside the pipeline
  timestamps
  {
    // VAriables that shoujld be passed
    def deployRepo = env.DeployRepo
    def deployOrg = "GEHC-DevOps-Apps"
    def keepAlive

        // Need to split Repo if it has a branch
        def possibleRepoAndBranch = deployRepo.split('/')
        def repoName = possibleRepoAndBranch[0]

      retry(2)
      {
          // Download the repo for scripts
          checkout scm
      }

      // Declare Vars
      def payload
    def masterJobNumber
    def flowDockInfo
    def gitFlowInfo
    def hasSucceeded=1
    def processedVariables
    def buildPipelineId
    def strLabels=""

      // Define the External Method to all the sub routines
      def externalMethod = load("utilities/GroovyUtils.groovy")

    /***************************************************************************************************
    * Process Received Parameters
    ***************************************************************************************************/
    stage("Process-Received-Params")
    {
          retry(2)
          {
              timeout(time: 5, unit: 'MINUTES')
              {
              echo "#### Inside ProcessingReceivedParams ####"

              // Grab env variable from the triggered job
                  masterJobNumber=env.BUILD_NUMBER
                  buildPipelineId="deliverypipe${masterJobNumber}"

              gitFlowInfo=new GitFlowInfo()
              }
          }
    }

    /***************************************************************************************************
    * Download Users artifacts.yml
    ***************************************************************************************************/
    stage("Download-ConfigFile")
    {
          // Download the users repo
          externalMethod.DownloadArtifactsYml()
      }

      /***************************************************************************************************
    * FlowDock Suite
    ***************************************************************************************************/
      stage("Flowdock-Suite")
    {
           /*****************************************
         * Set Flow Room Token
         *****************************************/
         // Set the flowToken
        externalMethod.SetFlowToken("deliverypipe");

          /***************************************************************************************************
        * SetupFlowDockVars -
        *   Grab variable process by the previous stage
        ***************************************************************************************************/
          timeout(time: 5, unit: 'MINUTES')
          {
          echo "#### Inside SetupFlowDockVars ####"

          flowToken=externalMethod.getParamFromSheet(buildPipelineId,"FlowToken")

          flowDockInfo=              new FlowDockMsg()
          processedVariables=             new ProcessedVariables()
          flowDockInfo.body=                 externalMethod.getParamFromSheet(buildPipelineId,"Body")
          processedVariables.flowToken=       flowToken // this is built in step 2 and pushed to env
          flowDockInfo.labels=           externalMethod.getParamFromSheet(buildPipelineId,"Labels")
          flowDockInfo.statuscolor=         externalMethod.getParamFromSheet(buildPipelineId,"StatusColor")
          flowDockInfo.statusvalue=         externalMethod.getParamFromSheet(buildPipelineId,"StatusValue")
          processedVariables.branch=        externalMethod.getParamFromSheet(buildPipelineId,"Branch")//
          flowDockInfo.threadbody=         externalMethod.getParamFromSheet(buildPipelineId,"ThreadBody")
          flowDockInfo.threadexternalurl=     externalMethod.getParamFromSheet(buildPipelineId,"ThreadExternalUrl")
          flowDockInfo.threadtitle=         externalMethod.getParamFromSheet(buildPipelineId,"ThreadTitle")
          flowDockInfo.title=           externalMethod.getParamFromSheet(buildPipelineId,"Title")
          }

          /***************************************************************************************************
           *  Notifying flowdock with a begin message
           ***************************************************************************************************/
          retry(2)
          {
              timeout(time: 5, unit: 'MINUTES')
              {
              echo "#### Inside NotifyFlowdock ####"

              flowDockInfo.flowToken=flowToken
              flowDockInfo.author="GlaDOS"
              flowDockInfo.avatar="http://i.imgur.com/GT4xpky.png"
              flowDockInfo.externalthreadid=masterJobNumber
              flowDockInfo.body="Running AWS CD Pipeline for: " + deployRepo
              flowDockInfo.labels=strLabels
              flowDockInfo.statuscolor="blue"
              flowDockInfo.statusvalue="Building"
              flowDockInfo.threadbody="Running AWS CD Pipeline for: " + deployRepo
              flowDockInfo.threadexternalurl="http://internal-jenkins-elb-340832960.us-east-1.elb.amazonaws.com/job/" + env.JOB_NAME + "/" + env.BUILD_NUMBER
              flowDockInfo.threadtitle="AWS CD BUILD " + deployRepo
              flowDockInfo.title="AWS CD BUILD: " + deployRepo

              ///////////////////////////////////////////////////////
              // These are pulled from the inital call from GlaDOS //
              ///////////////////////////////////////////////////////
              strLabels=""+
                "Repository:"+gitFlowInfo.gitRepository+"|"+
                //////////////////////////////
                // Pulled from FlowdockStep //
                //////////////////////////////

                "FlowToken:"+flowDockInfo.flowToken

              flowDockInfo.labels=strLabels

              // building the seed job
              //def seedjob= build job: 'Template_Notification'
              //echo "Seed notification job creation status: ${seedjob.result}"
                  def seedjob  = build job: 'Notify-Flowdock', parameters: [string(name: 'Author', value: flowDockInfo.author), string(name: 'Avatar', value: flowDockInfo.avatar), string(name: 'Body', value: flowDockInfo.body), string(name: 'ExternalThreadId', value: flowDockInfo.externalthreadid), string(name: 'FlowToken', value: flowToken), string(name: 'Labels', value: flowDockInfo.labels), string(name: 'StatusColor', value: flowDockInfo.statuscolor), string(name: 'StatusValue', value: flowDockInfo.statusvalue), string(name: 'Thread_Body', value: flowDockInfo.threadbody), string(name: 'Thread_ExternalUrl', value: flowDockInfo.threadexternalurl), string(name: 'Thread_Title', value: flowDockInfo.threadtitle), string(name: 'Title', value: flowDockInfo.title)]
                echo "Dynamic sendnotification job status: ${seedjob.result}"
              }
          }
      }

      /***************************************************************************************************
    *  Validate project
    ***************************************************************************************************/
    stage("Validate-Create-Run-Pipeline")
    {
          // Run the validator
          externalMethod.ValidateJenkinsProjectCD(deployOrg,repoName)

          //set build description
          externalMethod.SetJenkinsJobDescription(deployOrg,repoName)

        /***************************************************************************************************
        *  Build and Validate
        ***************************************************************************************************/
        echo "#### Inside Create-Run-CD-Pipeline ####"
      // Run The Step
          def seedJob
      def cdJobName="${repoName}-cd"
          try
      {
              // Kick the job off
        echo "Attempting to build ${cdJobName}"
          seedJob=build job: cdJobName, propagate: false, parameters: [string(name: 'OriginalMasterJob', value: buildPipelineId), string(name: 'PipelineBranch', value: env.PipelineBranch)]
        echo "First try default repo build for ${cdJobName} RESULT: ${seedJob.result}"
              if (!seedJob.result.equals("SUCCESS")) {
                  sh "exit 1" // fail the stage
              }
      }
      catch(all)
      {
          echo "failed to build ${cdJobName}"
        hasSucceeded=0
      }
          finally
          {
              // Update build description with link to job
              externalMethod.SetJenkinsJobDescription(deployOrg, repoName, seedJob.getAbsoluteUrl(), seedJob.getNumber())
          }
      }

    /***************************************************************************************************
    *  Notifying flowdock with an end message
    ***************************************************************************************************/
    stage("Notify-Flowdock-End")
    {
          retry(2)
          {
              timeout(time: 5, unit: 'MINUTES')
              {
              flowDockInfo.labels=strLabels
              if(hasSucceeded)
              {
                flowDockInfo.statuscolor = "green"
                flowDockInfo.statusvalue = "SUCCESS"
              }
              else
              {
                flowDockInfo.statuscolor = "red"
                flowDockInfo.statusvalue = "FAILURE"
              }

              def seedjob  = build job: 'Notify-Flowdock', parameters: [string(name: 'Author', value: flowDockInfo.author), string(name: 'Avatar', value: flowDockInfo.avatar), string(name: 'Body', value: flowDockInfo.body), string(name: 'ExternalThreadId', value: flowDockInfo.externalthreadid), string(name: 'FlowToken', value: flowToken), string(name: 'Labels', value: flowDockInfo.labels), string(name: 'StatusColor', value: flowDockInfo.statuscolor), string(name: 'StatusValue', value: flowDockInfo.statusvalue), string(name: 'Thread_Body', value: flowDockInfo.threadbody), string(name: 'Thread_ExternalUrl', value: flowDockInfo.threadexternalurl), string(name: 'Thread_Title', value: flowDockInfo.threadtitle), string(name: 'Title', value: flowDockInfo.title)]
              echo "Dynamic sendnotification job status: ${seedjob.result}"

              if(!hasSucceeded)
                  {
                sh "echo 'Failed to build job' && exit 911"
              }
           }
         }
      }
  }
}
////////////////////////////////// END OF PIPELINE /////////////////////////////////////////////////
/***************************************************************************************************
****************************************************************************************************
*  These are helper methods
*  Should go somewhere else eventually
****************************************************************************************************
***************************************************************************************************/
////////////////////////////////////////////////////////////////
//// SUB parseText /////////////////////////////////////////////
@NonCPS
def parseText(jsonpayload)
{
   jp  =  new groovy.json.JsonSlurper().parseText(jsonpayload)
   gfi  =  new GitFlowInfo()
   gfi.gitRepository = jp.payload.repository;
   jp = null
   return gfi
}
////////////////////////////////////////////////////////////////
//// SUB parsePropertySheet ////////////////////////////////////
@NonCPS
def parsePropertySheet(jsonpayload)
{
   jp  =  new groovy.json.JsonSlurper().parseText(jsonpayload)
   psh  =  new PropertySheet()
   psh.data = jp.data;
   psh.message = jp.message;
   jp = null
   return psh;
}
////////////////////////////////////////////////////////////////
//// CLASS GitFlowInfo /////////////////////////////////////////
class GitFlowInfo implements Serializable
{
   String gitRepository;
}
////////////////////////////////////////////////////////////////
//// CLASS PropertySheet ///////////////////////////////////////
class PropertySheet implements Serializable
{
   String data;
   String message;
}
////////////////////////////////////////////////////////////////
//// CLASS FlowDockMsg /////////////////////////////////////////
class FlowDockMsg implements Serializable
{
  // Flowdock Vars
    String author
    String avatar
    String body
    String externalthreadid
    String flowToken
    String labels
    String statuscolor
    String statusvalue
    String threadbody
    String threadexternalurl
    String threadtitle
    String title
}
////////////////////////////////////////////////////////////////
//// CLASS ProcessedVariables //////////////////////////////////
class ProcessedVariables implements Serializable
{
  String flowToken
  String artifactVersion
  String branch
}
